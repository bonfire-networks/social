defmodule Social.Localise do
  @moduledoc """
  Registers the object type names for gettext extraction, at compile time.

  This lives in the flavour rather than in `bonfire_common` or the root app for two reasons, both covered in `Bonfire.Common.Localise.localise_object_type_names/0`: the root app's `lib/` is never compiled during `just localise-extract` (an umbrella root owns no source), and the object type list is enumerated from *loaded* applications, so it needs a vantage point that depends on every extension in the build — which is precisely what a flavour is.
  """

  use Bonfire.Common.Localise

  Bonfire.Common.Localise.localise_object_type_names()
end
