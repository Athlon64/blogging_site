record Article {
  title : String,
  slug : String,
  abstract : Maybe(String),
  body : String,
  author : Author,
  favoritesCount : Number using "favoritesCount",
  favorited : Bool,
  tags : Array(String),
  createdAt : Time using "createdAt",
  updatedAt : Time using "updatedAt"
}

module Article {
  fun empty : Article {
    {
      title = "",
      slug = "",
      abstract = Maybe.nothing(),
      body = "",
      author = Author.empty(),
      favoritesCount = 0,
      favorited = false,
      tags = [],
      createdAt = Time.now(),
      updatedAt = Time.now()
    }
  }

  fun decoder (object : Object) : Result(Object.Error, Article) {
    decode object as Article
  }

  fun extractFromResponse (object : Object) : Result(Object.Error, Article) {
    Object.Decode.field("article", decoder, object)
  }
}
