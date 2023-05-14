store Stores.Profile {
  state status : Api.Status(Author) = Api.Status::Initial
  state profile : Author = Author.empty()

  fun setProfile (profile : Author) {
    next { profile = profile }
  }

  fun load (author : String) {
    sequence {
      next { status = Api.Status::Loading }

      newStatus =
        Http.get("/profiles/" + author)
        |> Api.send(Author.extractfromResponse)

      next
        {
          status = newStatus,
          profile = Api.withDefault(Author.empty(), newStatus)
        }
    }
  }
}
