component ArticleItem {
  connect Stores.Article exposing { toggleFavorite }

  property article : Article = Article.empty()

  style link {
    text-decoration: none;
    color: inherit;

    &:hover {
      color: var(--primary-hover);
    }
  }

  get title : Html {
    <a::link href={"/article/" + article.slug}>
      <{ article.title }>
    </a>
  }

  get abstract : Html {
    <{ Maybe.withDefault("", article.abstract) }>
  }

  fun render : Html {
    <Ui.Box title={title}>
      <{ abstract }>

      <div style="font-size:0.75em">
        <ArticleInfo article={article}/>
      </div>
    </Ui.Box>
  }
}
