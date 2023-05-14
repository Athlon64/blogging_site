enum Api.Status(data) {
  Initial
  Loading
  Ok(data)
  Error(Map(String, String))
}

module Api {
  fun newError (name : String, error : String) : Api.Status(data) {
    try {
      err =
        Map.empty()
        |> Map.set(name, error)

      Api.Status::Error(err)
    }
  }

  fun errorsDecoder (object : Object) {
    decode object as Map(String, String)
  }

  fun parseErrors (body : String) : Api.Status(data) {
    try {
      object =
        Json.parse(body)
        |> Maybe.toResult("")

      errors =
        Object.Decode.field("errors", errorsDecoder, object)

      Api.Status::Error(errors)
    } catch Object.Error => error {
      newError("request", "无法将响应解构为错误结构体")
    } catch String => error {
      newError("request", "无法解析服务器响应")
    }
  }

  fun errors (status : Api.Status(data)) : String {
    case (status) {
      Api.Status::Error(errors) =>
        errors
        |> Map.map((name : String, error : String) : String { name + ": " + error })
        |> Map.values()
        |> String.join("\n")

      => "没有任何错误"
    }
  }

  fun errorOf (
    name : String,
    validationErrors : Map(String, Array(String)),
    status : Api.Status(data)
  ) : Maybe(String) {
    try {
      error =
        Validation.getFirstError(name, validationErrors)

      if (Maybe.isJust(error)) {
        error
      } else {
        case (status) {
          Api.Status::Error(errors) =>
            Map.get(name, errors)

          => Maybe.nothing()
        }
      }
    }
  }

  fun send (
    decoder : Function(Object, Result(Object.Error, data)),
    rawRequest : Http.Request
  ) : Promise(Never, Api.Status(data)) {
    sequence {
      request =
        case (Stores.User.user) {
          UserStatus::LoggedIn(user) =>
            Http.header("Authorization", "Token " + user.token, rawRequest)

          UserStatus::Visitor => rawRequest
        }

      response =
        { request | url = "http://localhost:5000/api" + request.url }
        |> Http.header("Content-Type", "application/json")
        |> Http.send()

      case (response.status) {
        200 =>
          try {
            object =
              response.body
              |> Json.parse()
              |> Maybe.toResult("")

            newStatus =
              decoder(object)

            Api.Status::Ok(newStatus)
          } catch Object.Error => error {
            newError("request", "无法将响应解构为所需的结构体")
          } catch String => error {
            newError("request", "无法解析服务器响应")
          }

        => parseErrors(response.body)
      }
    } catch Http.ErrorResponse => error {
      newError("request", "发送请求时出错")
    }
  }

  fun toStatus (status : Api.Status(data)) : Status {
    case (status) {
      Api.Status::Initial => Status::Initial
      Api.Status::Loading => Status::Loading
      Api.Status::Ok => Status::Ok
      Api.Status::Error => Status::Error
    }
  }

  fun withDefault (data : data, status : Api.Status(data)) : data {
    case (status) {
      Api.Status::Ok(data) => data

      => data
    }
  }

  fun isLoading (status : Api.Status(data)) : Bool {
    case (status) {
      Api.Status::Loading => true

      => false
    }
  }
}
