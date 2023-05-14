store Stores.Register {
  state status : Api.Status(User) = Api.Status::Initial

  state username : String = ""
  state password : String = ""
  state email : String = ""

  fun reset {
    parallel {
      next
        {
          status = Api.Status::Initial,
          username = "",
          password = "",
          email = ""
        }

      Stores.Forms.Validator.reset()
    }
  }

  fun setUsername (value : String) {
    next { username = value }
  }

  fun setPassword (value : String) {
    next { password = value }
  }

  fun setEmail (value : String) {
    next { email = value }
  }

  fun submit (event : Html.Event) {
    sequence {
      errorsToBeChecked =
        [
          Validation.isNotBlank(username, {"username", "用户名不能为空"}),
          Validation.isNotBlank(email, {"email", "电子邮箱地址不能为空"}),
          Validation.isValidEmail(email, {"email", "电子邮箱地址无效"}),
          Validation.isNotBlank(password, {"password", "密码不能为空"})
        ]

      if (Stores.Forms.Validator.isFieldsValid(errorsToBeChecked)) {
        submitForm()
      } else {
        Promise.never()
      }
    }
  }

  fun submitForm {
    sequence {
      next { status = Api.Status::Loading }

      body =
        encode {
          user =
            {
              username = username,
              password = password,
              email = email
            }
        }

      newStatus =
        Http.post("/users")
        |> Http.jsonBody(body)
        |> Api.send(User.extractFromResponse)

      next { status = newStatus }

      case (newStatus) {
        Api.Status::Ok(user) =>
          Stores.User.login(user)

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
