record User {
  username : String,
  email : String,
  avatar : Maybe(String),
  image : Maybe(String),
  bio : String,
  token : String
}

module User {
  fun empty : User {
    {
      username = "",
      email = "",
      avatar = Maybe.nothing(),
      image = Maybe.nothing(),
      bio = "",
      token = ""
    }
  }

  fun decoder (object : Object) : Result(Object.Error, User) {
    decode object as User
  }

  fun extractFromResponse (object : Object) : Result(Object.Error, User) {
    Object.Decode.field("user", decoder, object)
  }
}
