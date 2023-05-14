store Stores.Tags {
  state status : Api.Status(Array(String)) = Api.Status::Initial
  state tags : Array(String) = []

  fun decoder (object : Object) : Result(Object.Error, Array(String)) {
    decode object as Array(String)
  }

  fun load {
    sequence {
      next { status = Api.Status::Loading }

      newStatus =
        "/tags"
        |> Http.get()
        |> Api.send((object : Object) : Result(Object.Error, Array(String)) { Object.Decode.field("tags", decoder, object) })

      next
        {
          status = newStatus,
          tags = Api.withDefault([], newStatus)
        }
    }
  }
}
