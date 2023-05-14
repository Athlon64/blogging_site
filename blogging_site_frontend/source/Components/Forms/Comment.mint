component Forms.Comment {
  connect Stores.Forms.Comment exposing { status, comment, setComment, submit }
  connect Stores.Forms.Validator exposing { errors }
  connect Stores.User exposing { isLoggedIn }

  property article : Article = Article.empty()

  style base {
    display: flex;
    flex-direction: column;
  }

  style button {
    margin-top: 0.625em;
    width: auto;
    align-self: center;
  }

  fun errorOf (name : String) {
    Api.errorOf(name, errors, status)
  }

  fun isInvalid (name : String) {
    Maybe.isJust(errorOf(name))
  }

  get placeholder : String {
    if (isLoggedIn()) {
      "撰写评论..."
    } else {
      "登录后才能发表评论"
    }
  }

  get buttonText : String {
    if (Api.isLoading(status)) {
      "处理中..."
    } else {
      "发表评论"
    }
  }

  fun onSubmit (event : Html.Event) {
    submit(article.slug)
  }

  fun render : Html {
    <div::base>
      <Ui.Field error={errorOf("body")}>
        <Ui.Textarea
          disabled={!isLoggedIn()}
          invalid={isInvalid("body")}
          placeholder={placeholder}
          value={comment}
          onChange={setComment}/>
      </Ui.Field>

      <div::button>
        <Ui.Button
          iconBefore={Ui.Icons:COMMENT}
          label={buttonText}
          disabled={Api.isLoading(status) || !isLoggedIn()}
          onClick={onSubmit}/>
      </div>
    </div>
  }
}
