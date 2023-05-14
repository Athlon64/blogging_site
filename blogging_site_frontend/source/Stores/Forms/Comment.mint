store Stores.Forms.Comment {
  state status : Api.Status(Comment) = Api.Status::Initial

  state comment : String = ""

  fun reset {
    parallel {
      next
        {
          status = Api.Status::Initial,
          comment = ""
        }

      Stores.Forms.Validator.reset()
    }
  }

  fun setComment (value : String) {
    next { comment = value }
  }

  fun submit (slug : String) {
    sequence {
      errorsToBeChecked =
        [Validation.isNotBlank(comment, {"body", "不能发表空白评论"})]

      if (Stores.Forms.Validator.isFieldsValid(errorsToBeChecked)) {
        submitForm(slug)
      } else {
        Promise.never()
      }
    }
  }

  fun submitForm (slug : String) {
    sequence {
      next { status = Api.Status::Loading }

      body =
        encode { comment = { body = comment } }

      newStatus =
        Http.post("/articles/" + slug + "/comments")
        |> Http.jsonBody(body)
        |> Api.send(Comment.extractFromResponse)

      next { status = newStatus }

      case (newStatus) {
        Api.Status::Ok =>
          parallel {
            Stores.Comments.load(slug)
            reset()
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
