# SPDX-License-Identifier: AGPL-3.0-only
#
# Guarded so it only compiles when `absinthe_graphql_ws` is on the path (i.e.
# WITH_API_GRAPHQL builds). Lives in the main app, not bonfire_api_graphql,
# since that extension doesn't declare the dep.
if Code.ensure_loaded?(Absinthe.GraphqlWS.Socket) do
  defmodule Bonfire.API.GraphQL.GraphqlWSSocket do
    @moduledoc """
    `graphql-transport-ws` websocket transport for GraphQL subscriptions
    (the protocol Ferry / graphql-ws clients speak), separate from the
    Phoenix-channels `Absinthe.Phoenix.Socket` at `/api/socket`.

    Auth: the client sends its bearer token in the `connection_init` payload
    (graphql-ws `connectionParams`); we verify it and put `current_user` into
    the Absinthe context so subscriptions can scope to the viewer.
    """
    use Absinthe.GraphqlWS.Socket, schema: Bonfire.API.GraphQL.Schema

    alias Bonfire.API.GraphQL.Auth
    import Untangle

    @impl true
    def handle_init(payload, socket) when is_map(payload) do
      context =
        with token when is_binary(token) <- bearer(payload),
             {:ok, ids} <- Auth.token_verify(token),
             %{} = user <- Auth.user_by(ids) do
          account = Bonfire.API.GraphQL.current_account(user)

          %{
            current_user: user,
            current_account: account,
            # the account's id (matches the HTTP context plug), NOT the user id
            current_account_id: Bonfire.Common.Enums.id(account)
          }
        else
          other ->
            debug(other, "graphql-ws: unauthenticated connection_init")
            %{}
        end

      {:ok, %{}, assign_context(socket, context)}
    end

    def handle_init(_payload, socket), do: {:ok, %{}, socket}

    # accept the token under any common connectionParams key, with/without a "Bearer " prefix
    defp bearer(payload) do
      raw =
        payload["token"] || payload["authToken"] || payload["Authorization"] ||
          payload["authorization"]

      case raw do
        "Bearer " <> t -> t
        "bearer " <> t -> t
        t when is_binary(t) and t != "" -> t
        _ -> nil
      end
    end
  end
end
