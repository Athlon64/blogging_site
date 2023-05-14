routes {
  /?tab=:tab (tab : String) {
    sequence {
      App.initializePage(Page::Home)

      Stores.Tabs.reset(tab, Stores.User.getUsername(), "")
      Stores.Tags.load()
    }
  }

  /?tag=:tag (tag : String) {
    sequence {
      App.initializePage(Page::Home)

      Stores.Tabs.reset("Tag", Stores.User.getUsername(), tag)
      Stores.Tags.load()
    }
  }

  / {
    sequence {
      App.initializePage(Page::Home)

      Stores.Tabs.reset("All", Stores.User.getUsername(), "")
      Stores.Tags.load()
    }
  }

  /article/:slug (slug : String) {
    sequence {
      App.initializePage(Page::Article)

      Stores.Article.load(slug)
      Stores.Comments.load(slug)
      Stores.Forms.Comment.reset()
    }
  }

  /new {
    sequence {
      Http.abortAll()
      Stores.User.load()
      Stores.Forms.Article.reset()

      case (Stores.User.user) {
        UserStatus::LoggedIn(user) => App.setPage(Page::Edit)

        UserStatus::Visitor => Window.navigate("/")
      }
    }
  }

  /edit/:slug (slug : String) {
    sequence {
      Http.abortAll()
      Stores.User.load()
      Stores.Forms.Article.reset()
      Stores.Article.load(slug)

      case (Stores.User.user) {
        UserStatus::LoggedIn(user) =>
          try {
            Stores.Forms.Article.set(Stores.Article.article)
            App.setPage(Page::Edit)
          }

        UserStatus::Visitor => Window.navigate("/")
      }
    }
  }

  /users/:username (username : String) {
    sequence {
      App.initializePage(Page::Profile)

      Stores.Tabs.reset("Own", username, "")
      Stores.Pagination.reset()
      Stores.Profile.load(username)
    }
  }

  /login {
    sequence {
      Http.abortAll()
      Stores.User.load()

      case (Stores.User.user) {
        UserStatus::LoggedIn(user) => Window.navigate("/")

        UserStatus::Visitor =>
          parallel {
            App.setPage(Page::Login)
            Stores.Login.reset()
          }
      }
    }
  }

  /register {
    sequence {
      Http.abortAll()
      Stores.User.load()

      case (Stores.User.user) {
        UserStatus::LoggedIn(user) => Window.navigate("/")

        UserStatus::Visitor =>
          parallel {
            App.setPage(Page::Register)
            Stores.Register.reset()
          }
      }
    }
  }

  /logout {
    sequence {
      Http.abortAll()
      Stores.User.load()

      case (Stores.User.user) {
        UserStatus::LoggedIn(user) => Stores.User.logout()

        UserStatus::Visitor => Window.navigate("/")
      }
    }
  }

  /settings {
    sequence {
      Http.abortAll()
      Stores.User.load()

      case (Stores.User.user) {
        UserStatus::LoggedIn(user) =>
          sequence {
            Stores.Forms.Settings.set(user)
            App.setPage(Page::Settings)
          }

        UserStatus::Visitor => Window.navigate("/")
      }
    }
  }

  * {
    App.setPage(Page::NotFound)
  }
}
