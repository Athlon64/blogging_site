store Stores.Article {
  state status : Api.Status(Article) = Api.Status::Initial
  state article : Article = Article.empty()

  fun reset {
    next
      {
        status = Api.Status::Initial,
        article = Article.empty()
      }
  }

  fun setAuthor (user : Author) {
    next { article = { article | author = user } }
  }

  fun load (slug : String) {
    sequence {
      next { status = Api.Status::Loading }

      newStatus =
        "/articles/" + slug
        |> Http.get()
        |> Api.send(Article.extractFromResponse)

      next
        {
          status = newStatus,
          article = Api.withDefault(Article.empty(), newStatus)
        }
    }
  }

  fun remove (slug : String) {
    sequence {
      Window.confirm("此操作无法撤销\n确定要删除吗？")

      status =
        Http.delete("/articles/" + slug)
        |> Api.send(
          (object : Object) : Result(Object.Error, Void) { Result.ok(void) })

      case (status) {
        Api.Status::Ok =>
          parallel {
            Ui.Notifications.notify(
              <Ui.ContentHint
                size={Ui.Size::Em(0.7)}
                icon={Ui.Icons:INFO}
                type="success">

                <{ "已删除文章" }>

              </Ui.ContentHint>,
              3000)

            Window.navigate("/")
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
    } catch String => error {
      Promise.never()
    }
  }

  fun toggleFavorite (article : Article) {
    case (Stores.User.user) {
      UserStatus::LoggedIn(user) =>
        sequence {
          url =
            "/articles/" + article.slug + "/favorite"

          request =
            if (article.favorited) {
              Http.delete(url)
            } else {
              Http.post(url)
            }

          status =
            Api.send(Article.extractFromResponse, request)

          case (status) {
            Api.Status::Ok(article) =>
              sequence {
                Stores.Articles.updateLocalArticle(article)
                next { article = article }
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

      =>
        Ui.Notifications.notify(
          <Ui.ContentHint
            size={Ui.Size::Em(0.7)}
            icon={Ui.Icons:ALERT}
            type="danger">

            "登录后才能执行此操作"

          </Ui.ContentHint>,
          3000)
    }
  }
}
