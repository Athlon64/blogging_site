store Stores.Pagination {
  state sidePages : Number = 1
  state perPage : Number = 3
  state page : Number = 0

  fun reset {
    next { page = 0 }
  }

  fun setPage (page : Number) {
    sequence {
      next { page = page }

      if (Stores.Tabs.activeTab == "Followings" || Stores.Tabs.activeTab == "Followers") {
        Stores.UserInfos.load()
      } else {
        Stores.Articles.load()
      }
    }
  }
}
