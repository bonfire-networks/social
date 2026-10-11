defmodule Bonfire.Web.Views.DashboardLive do
  @moduledoc """
  The main instance home page, mainly for guests visiting the instance
  """
  use Bonfire.UI.Common.Web, :surface_live_view
  # use_if_enabled(Bonfire.UI.Common.Web.Native, :view)

  declare_nav_link(l("Dashboard"), page: "home", icon: "ph:house-fill")

  # on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.UserRequired]}
  # TEMP: for testing native app
  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    current_user = current_user(socket)
    is_guest? = is_nil(current_user)

    # community_links =
    #   Config.get([:ui, :theme, :instance_welcome, :links], [])
    #   |> Bonfire.UI.Common.WidgetCommunityLinksLive.normalize_links()

    sidebar_widgets = [
      users: [
        secondary:
          Enum.filter(
            [
              # {Bonfire.UI.Common.WidgetCommunityLinksLive, [links: community_links]},
              Settings.get(
                [Bonfire.Web.Views.DashboardLive, :include, :getting_started],
                true,
                current_user: current_user
              ) &&
                {Bonfire.UI.Common.WidgetGettingStartedLive, [type: Surface.LiveComponent]},
              # Settings.get(
              #   [Bonfire.Web.Views.DashboardLive, :include, :instance_status],
              #   true,
              #   current_user: current_user
              # ) && {Bonfire.UI.Me.WidgetInstanceStatusLive, []},
              # Settings.get(
              #   [Bonfire.Web.Views.DashboardLive, :include, :forecast],
              #   true,
              #   current_user: current_user
              # ) &&
              #   {Bonfire.Geolocate.WidgetForecastLive,
              #    [
              #      location:
              #        Settings.get([Bonfire.Geolocate, :location], nil, current_user: current_user)
              #    ]},
              current_user &&
                Settings.get(
                  [Bonfire.Web.Views.DashboardLive, :include, :recent_articles],
                  true,
                  current_user: current_user
                ) &&
                {Bonfire.UI.Articles.WidgetRecentArticlesLive,
                 [limit: 5, widget_title: l("Recent Articles"), image_position: :bottom]},
              Settings.get(
                [Bonfire.Web.Views.DashboardLive, :include, :community_rules],
                true,
                current_user: current_user
              ) &&
                Bonfire.Common.Extend.module_enabled?(
                  Bonfire.CommunityRules.Web.WidgetRulesLive,
                  current_user
                ) &&
                {Bonfire.CommunityRules.Web.WidgetRulesLive, []},
              Settings.get(
                [Bonfire.Web.Views.DashboardLive, :include, :popular_topics],
                true,
                current_user: current_user
              ) && {Bonfire.Tag.Web.WidgetTagsLive, []},
              # {Bonfire.UI.Social.WidgetTrendingLinksLive, []},
              # Settings.get([Bonfire.Web.Views.DashboardLive, :include, :admins], true,
              #   current_user: current_user
              # ) &&
              #   {Bonfire.UI.Me.WidgetAdminsLive, []},
              Settings.get(
                [Bonfire.Web.Views.DashboardLive, :include, :recent_users],
                true,
                current_user: current_user
              )
            ],
            & &1
          )
      ]
    ]

    main_widgets = Bonfire.UI.Me.Dashboard.main_widgets(main_widget_choices(), current_user)

    {dashboard_feed, dashboard_feed_id} = Bonfire.UI.Me.Dashboard.feed_assigns(socket)

    page_title = l("Active discussions")

    {:ok,
     socket
     |> assign(
       page: "about",
       selected_tab: :about,

       page_header: false,
       page_header_aside: [
         # {Bonfire.UI.Me.DashboardConfigDropdownLive, [scope: :user]}
       ],
       dashboard_feed: dashboard_feed,
       dashboard_feed_id: dashboard_feed_id,
       is_guest?: is_guest?,
       without_sidebar: is_guest?,
       without_secondary_widgets: :never,
       no_header: is_guest?,
       page_title: page_title,
       sidebar_widgets: sidebar_widgets,
       main_widgets: main_widgets,
       loading: true,
       feed: nil,
       feed_id: nil,
       feed_ids: nil,
       feed_component_id: nil,
       page_info: nil,
       show_search_filters: false
     )
     # TODO: only assign for native?
     |> assign(tab_assigns("home"))}
  end

  @doc "Main-area widgets this flavour offers, in default order (keys of `Bonfire.UI.Me.Dashboard.catalogue/0`)."
  def main_widget_choices do
    [:instance_pinned, :trending_discussions, :polls_closing_soon, :suggested_profiles]
  end

  # @decorate time()
  # def handle_params(params, _url, socket) do
  #   # debug(params, "param")

  #   context = assigns(socket)[:__context__]

  #   feed_name =
  #     if module_enabled?(Bonfire.Social.Pins, context) and
  #          Settings.get(
  #            [Bonfire.UI.Social.FeedsLive, :curated],
  #            false,
  #            context
  #          ) do
  #       :curated
  #     else
  #       e(assigns(socket), :live_action, nil) ||
  #         Settings.get(
  #           [Bonfire.UI.Social.FeedLive, :default_feed],
  #           :my,
  #           context
  #         )
  #     end

  #   {
  #     :noreply,
  #     socket
  #     |> assign(
  #       Bonfire.Social.Feeds.LiveHandler.feed_default_assigns(
  #         {
  #           feed_name,
  #           params
  #         },
  #         socket
  #       )
  #     )
  #   }
  # end

  # def handle_event("select_tab", %{"selection" => tab}, socket) do
  #   {:noreply,
  #    socket
  #    |> assign(tab_assigns(tab))}
  # end

  def tab_assigns(tab) do
    {header_menu, toolbar_trailing, navigation_menu, page_title} =
      case tab do
        "home" ->
          {:home_header_menu, :home_toolbar_trailing, :home_navigation_menu, "Home"}

        "notifications" ->
          {:notifications_header_menu, :notifications_toolbar_trailing,
           :notifications_navigation_menu, "Notifications"}

        "direct_messages" ->
          {:direct_messages_header_menu, :direct_messages_toolbar_trailing,
           :direct_messages_navigation_menu, "Direct Messages"}

        "search" ->
          {:search_header_menu, :search_toolbar_trailing, :search_navigation_menu, "Search"}

        "profile" ->
          {:profile_header_menu, :profile_toolbar_trailing, :profile_navigation_menu, "Profile"}

        _ ->
          {nil, nil, nil, ""}
      end

    [
      selected_tab: tab,
      header_menu: header_menu,
      navigation_menu: navigation_menu,
      page_title: page_title,
      toolbar_trailing: toolbar_trailing
    ]
  end
end
