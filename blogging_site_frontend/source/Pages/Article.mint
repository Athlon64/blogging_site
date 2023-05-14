component Pages.Article {
  connect Stores.Article exposing { status, article, remove }
  connect Stores.User exposing { user, handleFollowing, isProcessing }

  style base {
    display: flex;
    margin-top: 0.625em;
  }

  style contents {
    flex: 4;
    margin-right: 1.875em;

    img {
      max-width: 100%;
      max-height: 100%;
    }
  }

  style authorInfo {
    flex: 1;
    margin-left: 1.875em;

    @media (max-width: 1024px) {
      display: none;
    }
  }

  style header {
    margin-bottom: 1.875em;
  }

  style title {
    font-size: 1.875em;
  }

  style content {
    font-size: 1.125em;
  }

  style card {
    margin: 0;
  }

  style buttonGroup {
    margin-top: 1.25em;
    display: flex;
    justify-content: space-between;
  }

  style userInfo {
    display: flex;
    align-items: center;
    gap: 1.25em;
  }

  get isAuthor {
    case (user) {
      UserStatus::LoggedIn(user) => user.username == article.author.username
      => false
    }
  }

  get followText : String {
    if (isProcessing) {
      "处理中..."
    } else if (article.author.following) {
      "取消关注"
    } else {
      "关注"
    }
  }

  get followIcon : Html {
    if (isProcessing) {
      Html.empty()
    } else if (article.author.following) {
      <Ui.Icon
        icon={Ui.Icons:DASH}
        size={Ui.Size::Em(6)}/>
    } else {
      <Ui.Icon
        icon={Ui.Icons:PLUS}
        size={Ui.Size::Em(6)}/>
    }
  }

  get username {
    <div::userInfo>
      <{ article.author.username }>

      if (Stores.User.isLoggedIn() && !isAuthor) {
        <Ui.Button
          iconBefore={followIcon}
          onClick={toggleFollowing}
          label={followText}
          size={Ui.Size::Em(0.1875)}/>
      }
    </div>
  }

  fun editArticle (evt : Html.Event) {
    Window.navigate("/edit/" + article.slug)
  }

  fun deleteArticle (evt : Html.Event) {
    remove(article.slug)
  }

  fun toggleFollowing (evt : Html.Event) {
    try {
      Html.Event.stopPropagation(evt)
      handleFollowing(article.author)
    }
  }

  fun cardClicked (evt : Html.Event) {
    Window.navigate("/users/" + article.author.username)
  }

  fun render : Html {
    <div::base>
      <div::contents>
        <Ui.Box>
          <Loader
            status={Api.toStatus(status)}
            errorMessage={Api.errors(status)}>

            <div::header>
              <div::title>
                <{ article.title }>
              </div>

              <ArticleInfo article={article}/>
            </div>

            <div::content>
              <Markdown content={article.body}/>

              <Separator/>
              <Comments/>

              <Separator/>
              <Forms.Comment article={article}/>
            </div>

          </Loader>
        </Ui.Box>
      </div>

      <div::authorInfo>
        <Loader
          status={Api.toStatus(status)}
          errorMessage={Api.errors(status)}>

          <div::card>
            <Ui.Card
              bordered={true}
              onClick={Maybe.just(cardClicked)}>

              <Ui.Card.Image src={article.author.image}/>

              <Ui.Card.Container
                size={Ui.Size::Em(0.5)}
                thumbnail={article.author.avatar}
                title={username}
                subtitle=<{ Time.format(Time.Format:ENGLISH, "文章发表于：%Y年%-m月%-d日", article.createdAt) }>
                content=<{ article.author.bio }>/>

            </Ui.Card>

            if (isAuthor) {
              <div::buttonGroup>
                <Ui.Button
                  onClick={editArticle}
                  iconBefore={Ui.Icons:PENCIL}
                  size={Ui.Size::Em(0.875)}
                  ellipsis={true}
                  label="编辑文章"
                  type="primary"/>

                <Ui.Button
                  onClick={deleteArticle}
                  iconBefore={Ui.Icons:PENCIL}
                  iconBefore={Ui.Icons:TRASHCAN}
                  size={Ui.Size::Em(0.875)}
                  ellipsis={true}
                  label="删除文章"
                  type="danger"/>
              </div>
            }
          </div>

        </Loader>
      </div>

      <BackToTop/>
    </div>
  }
}
