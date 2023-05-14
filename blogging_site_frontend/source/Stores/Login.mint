store Stores.Login {
  state status : Api.Status(User) = Api.Status::Initial

  state email : String = ""
  state password : String = ""

  fun reset {
    parallel {
      next
        {
          status = Api.Status::Initial,
          password = "",
          email = ""
        }

      Stores.Forms.Validator.reset()
    }
  }

  fun setEmail (email : String) {
    next { email = email }
  }

  fun setPassword (password : String) {
    next { password = password }
  }

  fun submit (event : Html.Event) {
    sequence {
      errorsToBeChecked =
        [
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
              email = email,
              password = password
            }
        }

      newStatus =
        "/users/login"
        |> Http.post()
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
