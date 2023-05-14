store Stores.Forms.Article {
  state status : Api.Status(Article) = Api.Status::Initial

  state slug : Maybe(String) = Maybe.nothing()
  state tags : Set(String) = Set.empty()
  state abstract : String = ""
  state content : String = ""
  state title : String = ""

  fun reset {
    parallel {
      next
        {
          status = Api.Status::Initial,
          slug = Maybe.nothing(),
          tags = Set.empty(),
          abstract = "",
          content = "",
          title = ""
        }

      Stores.Forms.Validator.reset()
    }
  }

  fun set (article : Article) {
    next
      {
        abstract = Maybe.withDefault("", article.abstract),
        tags = Set.fromArray(article.tags),
        slug = Maybe.just(article.slug),
        content = article.body,
        title = article.title
      }
  }

  fun setTags (value : String) {
    next { tags = Set.fromArray(String.split(" ", value)) }
  }

  fun setAbstract (value : String) {
    next { abstract = value }
  }

  fun setContent (value : String) {
    next { content = value }
  }

  fun setTitle (value : String) {
    next { title = value }
  }

  fun submit (event : Html.Event) {
    sequence {
      errorsToBeChecked =
        [
          Validation.isNotBlank(title, {"title", "文章标题不能为空"}),
          Validation.isNotBlank(content, {"body", "文章内容不能为空"})
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
          article =
            {
              tags = Set.toArray(tags),
              abstract = abstract,
              title = title,
              body = content
            }
        }

      request =
        if (Maybe.isJust(slug)) {
          Http.put("/articles/" + Maybe.withDefault("", slug))
        } else {
          Http.post("/articles")
        }

      newStatus =
        request
        |> Http.jsonBody(body)
        |> Api.send(Article.extractFromResponse)

      next { status = newStatus }

      case (newStatus) {
        Api.Status::Ok(article) => Window.navigate("/article/" + article.slug)

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
