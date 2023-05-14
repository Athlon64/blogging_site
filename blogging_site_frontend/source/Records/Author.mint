record Author {
  username : String,
  bio : String,
  avatar : String,
  image : String,
  following : Bool
}

module Author {
  fun empty : Author {
    {
      username = "",
      bio = "",
      avatar = "",
      image = "",
      following = false
    }
  }

  fun decoder (object : Object) : Result(Object.Error, Author) {
    decode object as Author
  }

  fun extractfromResponse (object : Object) : Result(Object.Error, Author) {
    Object.Decode.field("profile", decoder, object)
  }
}
