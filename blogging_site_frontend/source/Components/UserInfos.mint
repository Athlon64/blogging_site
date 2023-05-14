component UserInfos {
  connect Stores.UserInfos exposing { status, users }

  style base {
    font-size: 0.625em;
  }

  style divider {
    margin: 1.25em 0;
  }

  get userList : Array(Html) {
    for (user of users) {
      <UserInfo user={user}/>
    }
    |> Array.intersperse(<div::divider/>)
  }

  fun render : Html {
    <Loader
      status={Api.toStatus(status)}
      errorMessage={Api.errors(status)}>

      <div::base>
        <{ userList }>
      </div>

    </Loader>
  }
}
