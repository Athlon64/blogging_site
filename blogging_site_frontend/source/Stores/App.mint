enum Page {
  Initial
  Home
  Article
  Edit
  Login
  Register
  Settings
  Profile
  NotFound
}

store App {
  state page : Page = Page::Initial

  fun setPage (page : Page) {
    next { page = page }
  }

  fun initializePage (page : Page) {
    sequence {
      Http.abortAll()

      setPage(page)
      Stores.User.load()
    }
  }
}
