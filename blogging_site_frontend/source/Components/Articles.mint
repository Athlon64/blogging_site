component Articles {
  connect Stores.Articles exposing { status, articles }

  style divider {
    margin: 1.25em 0;
  }

  get articleList : Array(Html) {
    for (article of articles) {
      <ArticleItem article={article}/>
    }
    |> Array.intersperse(<div::divider/>)
  }

  fun render : Html {
    <Loader
      status={Api.toStatus(status)}
      errorMessage={Api.errors(status)}>

      <{ articleList }>

    </Loader>
  }
}
