enum UserStatus {
  LoggedIn(User)
  Visitor
}

store Stores.User {
  state user : UserStatus = UserStatus::Visitor
  state isProcessing : Bool = false

  fun resetStores {
    parallel {
      Stores.Articles.reset()
      Stores.Article.reset()
      Stores.Comments.reset()
    }
  }

  fun isLoggedIn : Bool {
    case (user) {
      UserStatus::LoggedIn(user) => true

      => false
    }
  }

  fun getUsername : String {
    case (user) {
      UserStatus::LoggedIn(user) => user.username

      => ""
    }
  }

  fun updateLocalUser (user : User) {
    sequence {
      next { user = UserStatus::LoggedIn(user) }

      Storage.Local.set("user", Json.stringify(encode user))

      Promise.never()
    } catch Storage.Error => error {
      Promise.never()
    }
  }

  fun load {
    sequence {
      try {
        data =
          Storage.Local.get("user")

        object =
          Json.parse(data)
          |> Maybe.toResult("")

        currentUser =
          decode object as User

        next { user = UserStatus::LoggedIn(currentUser) }
      } catch Storage.Error => error {
        next { user = UserStatus::Visitor }
      } catch Object.Error => error {
        next { user = UserStatus::Visitor }
      } catch String => error {
        next { user = UserStatus::Visitor }
      }
    }
  }

  fun login (user : User) {
    sequence {
      Storage.Local.set("user", Json.stringify(encode user))

      resetStores()

      next { user = UserStatus::LoggedIn(user) }

      Window.navigate("/")

      Ui.Notifications.notify(
        <Ui.ContentHint
          size={Ui.Size::Em(0.7)}
          icon={Ui.Icons:HUBOT}
          type="success">

          <{ user.username + "，欢迎您的到来 👋" }>

        </Ui.ContentHint>,
        3000)
    } catch Storage.Error => error {
      Promise.never()
    }
  }

  fun logout {
    sequence {
      Storage.Local.remove("user")

      resetStores()

      next { user = UserStatus::Visitor }

      Window.navigate("/")
    } catch Storage.Error => error {
      Promise.never()
    }
  }

  fun toggleFollowing (user : Author) : Promise(Never, Api.Status(Author)) {
    sequence {
      url =
        "/profiles/" + user.username + "/follow"

      request =
        if (user.following) {
          Http.delete(url)
        } else {
          Http.post(url)
        }

      Api.send(Author.extractfromResponse, request)
    }
  }

  fun handleFollowing (user : Author) {
    sequence {
      next { isProcessing = true }

      newStatus =
        toggleFollowing(user)

      case (newStatus) {
        Api.Status::Ok(user) =>
          try {
            Stores.Profile.setProfile(user)
            Stores.Article.setAuthor(user)
          }

        =>
          Ui.Notifications.notify(
            <Ui.ContentHint
              size={Ui.Size::Em(0.7)}
              icon={Ui.Icons:ALERT}
              type="danger">

              <{ "发生错误，请稍后重试" }>

            </Ui.ContentHint>,
            3000)
      }

      next { isProcessing = false }
    }
  }
}
