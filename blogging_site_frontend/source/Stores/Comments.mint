store Stores.Comments {
  state status : Api.Status(Array(Comment)) = Api.Status::Initial
  state comments : Array(Comment) = []

  fun reset : Promise(Never, Void) {
    next { status = Api.Status::Initial }
  }

  fun decoder (object : Object) : Result(Object.Error, Array(Comment)) {
    decode object as Array(Comment)
  }

  fun load (slug : String) {
    sequence {
      next { status = Api.Status::Loading }

      newStatus =
        "/articles/" + slug + "/comments"
        |> Http.get()
        |> Api.send(
          (object : Object) : Result(Object.Error, Array(Comment)) {
            Object.Decode.field("comments", decoder, object)
          })

      next
        {
          status = newStatus,
          comments = Api.withDefault([], newStatus)
        }
    }
  }

  fun decodeMessage (object : Object) : Result(Object.Error, String) {
    decode object as String
  }

  fun updateLocalComments (id : Number) {
    try {
      updatedComments =
        Array.reject(
          (item : Comment) : Bool {
            item.id == id
          },
          comments)

      next { comments = updatedComments }
    }
  }

  fun deleteComment (id : Number) {
    sequence {
      Window.confirm("此操作无法撤销\n确定要删除吗？")

      newStatus =
        "/articles/" + Stores.Article.article.slug + "/comments/" + Number.toString(id)
        |> Http.delete()
        |> Api.send(
          (object : Object) : Result(Object.Error, String) {
            Object.Decode.field("message", decodeMessage, object)
          })

      case (newStatus) {
        Api.Status::Ok(message) =>
          parallel {
            updateLocalComments(id)

            Ui.Notifications.notify(
              <Ui.ContentHint
                size={Ui.Size::Em(0.7)}
                icon={Ui.Icons:INFO}
                type="success">

                <{ "已删除评论" }>

              </Ui.ContentHint>,
              3000)
          }

        =>
          Ui.Notifications.notify(
            <Ui.ContentHint
              size={Ui.Size::Em(0.7)}
              icon={Ui.Icons:ALERT}
              type="danger">

              <{ "删除评论失败" }>

            </Ui.ContentHint>,
            3000)
      }
    } catch String => error {
      Promise.never()
    }
  }
}
