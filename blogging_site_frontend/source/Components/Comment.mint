component Article.Comment {
  connect Stores.User exposing { user }
  connect Stores.Comments exposing { deleteComment }

  property comment : Comment = Comment.empty()

  style base {
    margin-bottom: 0.625em;
    border-radius: 0.125em;
  }

  style text {
    padding-top: 0.5em;
    font-size: 2em;
  }

  style subtitle {
    display: flex;
    justify-content: space-between;
  }

  get body {
    <p::text>
      <{ comment.body }>
    </p>
  }

  get isAuthor {
    case (user) {
      UserStatus::LoggedIn(user) => user.username == comment.author.username

      => false
    }
  }

  get subtitle {
    <div::subtitle>
      <{ Time.format(Time.Format:ENGLISH, "评论发表于：%Y年%-m月%-d日", comment.createdAt) }>

      if (isAuthor) {
        <Ui.Button
          iconBefore={
            <Ui.Icon
              icon={Ui.Icons:TRASHCAN}
              size={Ui.Size::Em(2)}/>
          }
          onClick={delBtnClicked}
          label="删除"
          type="danger"/>
      }
    </div>
  }

  fun delBtnClicked (evt : Html.Event) {
    deleteComment(comment.id)
  }

  fun render : Html {
    <div::base>
      <Ui.Card size={Ui.Size::Em(0.5)}>
        <Ui.Card.Container
          thumbnail={comment.author.avatar}
          title=<{ comment.author.username }>
          subtitle={subtitle}
          content={body}/>
      </Ui.Card>
    </div>
  }
}
