store Stores.Tabs {
  /* All states: "All", "Favorites", "Tag", "Own", "Followings", "Followers" */
  state activeTab : String = "All"

  state favoritedBy : String = ""
  state tag : String = ""

  fun reset (tab : String, username : String, tag : String) {
    sequence {
      next
        {
          favoritedBy = username,
          tag = tag
        }

      setActiveTab(tab)
    }
  }

  fun setActiveTab (tab : String) {
    sequence {
      next { activeTab = tab }

      if (tab != "Tag") {
        next { tag = "" }
      } else {
        next { }
      }

      Stores.Pagination.setPage(0)
    }
  }

  fun changeTag (evt : Html.Event) {
    sequence {
      tag =
        Dom.getTextContent(evt.target)

      Window.navigate("/?tag=" + tag)
    }
  }

  fun changeTab (tab : String) {
    Window.navigate("/?tab=" + tab)
  }
}
