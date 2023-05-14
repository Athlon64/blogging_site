record ArticleList {
  articles : Array(Article),
  count : Number
}

store Stores.Articles {
  state status : Api.Status(ArticleList) = Api.Status::Initial
  state articles : Array(Article) = []
  state articlesCount : Number = 0

  fun reset {
    next { status = Api.Status::Initial }
  }

  fun updateLocalArticle (article : Article) {
    try {
      updatedArticles =
        Array.map(
          (item : Article) : Article {
            if (item.slug == article.slug) {
              article
            } else {
              item
            }
          },
          articles)

      next { articles = updatedArticles }
    }
  }

  fun load {
    sequence {
      next { status = Api.Status::Loading }

      url =
        case (Stores.Tabs.activeTab) {
          "Favorites" =>
            "/articles?favorited=" + Stores.Tabs.favoritedBy + "&"

          "Tag" =>
            "/articles?tag=" + Stores.Tabs.tag + "&"

          "Own" =>
            "/articles?author=" + Stores.Tabs.favoritedBy + "&"

          "All" =>
            "/articles?"

          =>
            "impossible"
        }

      params =
        SearchParams.empty()
        |> SearchParams.append("limit", Number.toString(Stores.Pagination.perPage))
        |> SearchParams.append("offset", Number.toString(Stores.Pagination.page * Stores.Pagination.perPage))

      newStatus =
        url + SearchParams.toString(params)
        |> Http.get()
        |> Api.send((object : Object) : Result(Object.Error, ArticleList) { decode object as ArticleList })

      data =
        Api.withDefault(
          {
            articles = [],
            count = 0
          },
          newStatus)

      next
        {
          status = newStatus,
          articles = data.articles,
          articlesCount = data.count
        }
    }
  }
}
