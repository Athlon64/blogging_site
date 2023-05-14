component Pages.Profile {
  connect Stores.Tabs exposing {
    activeTab,
    setActiveTab
  }

  connect Stores.Articles exposing { articlesCount }
  connect Stores.UserInfos exposing { usersCount }
  connect Stores.Profile exposing { profile }

  style base {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 3.125em;
  }

  style articles {
    width: 100%;
  }

  get username {
    try {
      name =
        Stores.User.getUsername()

      if (profile.username == name) {
        "我"
      } else {
        profile.username
      }
    }
  }

  get tabs {
    [
      {
        iconBefore = Ui.Icons:INBOX,
        iconAfter = <></>,
        content = <{ <Articles/> }>,
        label = username + "的文章",
        key = "Own"
      },
      {
        iconBefore = Ui.Icons:BOOKMARK,
        iconAfter = <></>,
        content = <{ <Articles/> }>,
        label = username + "的收藏",
        key = "Favorites"
      },
      {
        iconBefore = Ui.Icons:PERSON,
        iconAfter = <></>,
        content = <{ <UserInfos/> }>,
        label = username + "关注的用户",
        key = "Followings"
      },
      {
        iconBefore = Ui.Icons:MEGAPHONE,
        iconAfter = <></>,
        content = <{ <UserInfos/> }>,
        label = username + "的粉丝",
        key = "Followers"
      }
    ]
  }

  fun render : Html {
    <div::base>
      <Profile/>

      <div::articles>
        <Tabs
          activeTab={activeTab}
          onChange={setActiveTab}
          items={tabs}/>

        if (activeTab == "Own" || activeTab == "Favorites") {
          <Pagination total={articlesCount}/>
        } else {
          <Pagination total={usersCount}/>
        }
      </div>
    </div>
  }
}
