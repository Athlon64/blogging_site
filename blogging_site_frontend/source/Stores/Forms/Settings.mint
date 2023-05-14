store Stores.Forms.Settings {
  state status : Api.Status(User) = Api.Status::Initial

  state username : String = ""
  state email : String = ""

  state avatar : String = ""
  state image : String = ""
  state bio : String = ""

  fun setAvatar (value : String) {
    next { avatar = value }
  }

  fun setImage (value : String) {
    next { image = value }
  }

  fun setBio (value : String) {
    next { bio = value }
  }

  fun set (user : User) {
    next
      {
        status = Api.Status::Initial,
        avatar = Maybe.withDefault("", user.avatar),
        image = Maybe.withDefault("", user.image),
        bio = "",
        username = user.username,
        email = user.email
      }
  }

  fun submit {
    sequence {
      next { status = Api.Status::Loading }

      body =
        encode {
          user =
            {
              avatar = avatar,
              image = image,
              bio = bio
            }
        }

      newStatus =
        Http.put("/user")
        |> Http.jsonBody(body)
        |> Api.send(User.extractFromResponse)

      next { status = newStatus }

      case (newStatus) {
        Api.Status::Ok(user) =>
          sequence {
            Stores.User.updateLocalUser(user)
            Window.navigate("/users/" + username)
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
    }
  }
}
