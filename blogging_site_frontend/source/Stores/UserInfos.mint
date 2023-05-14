record UserList {
  users : Array(Author),
  count : Number
}

store Stores.UserInfos {
  state status : Api.Status(UserList) = Api.Status::Initial
  state users : Array(Author) = []
  state usersCount : Number = 0

  fun reset {
    next { status = Api.Status::Initial }
  }

  fun load {
    sequence {
      next { status = Api.Status::Loading }

      url =
        case (Stores.Tabs.activeTab) {
          "Followings" =>
            "/profiles/" + Stores.Tabs.favoritedBy + "/followings?"

          "Followers" =>
            "/profiles/" + Stores.Tabs.favoritedBy + "/followers?"

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
        |> Api.send(
          (object : Object) : Result(Object.Error, UserList) { decode object as UserList })

      data =
        Api.withDefault(
          {
            users = [],
            count = 0
          },
          newStatus)

      next
        {
          status = newStatus,
          users = data.users,
          usersCount = data.count
        }
    }
  }
}
