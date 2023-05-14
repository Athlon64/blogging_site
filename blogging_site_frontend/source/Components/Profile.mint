component Profile {
  connect Stores.Profile exposing { status, profile }
  connect Stores.User exposing { user, handleFollowing }

  state loading : Bool = false

  style base {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1.875em;
  }

  style grid {
    display: grid;
    gap: 0.3125em 0.5em;

    grid-template-columns: min-content 1fr min-content;

    grid-template-areas: "avatar username button"
                         "avatar bio button";

    > *:nth-child(1) {
      grid-area: avatar;
    }

    > *:nth-child(2) {
      grid-area: username;
    }

    > *:nth-child(3) {
      grid-area: bio;
    }

    > *:nth-child(4) {
      grid-area: button;
    }
  }

  style cell {
    display: grid;
    align-content: center;
  }

  style banner {
    height: 25em;
  }

  style image {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  style avatar {
    width: 4em;
    height: 4em;
    border-radius: 50%;
  }

  style username {
    font-weight: bold;
    font-size: 1.25em;
  }

  style bio {
    font-size: 1.05em;
    opacity: 0.8;
  }

  style button {
    margin-left: 5em;
  }

  get followText : String {
    if (loading) {
      "处理中..."
    } else if (profile.following) {
      "取消关注"
    } else {
      "关注"
    }
  }

  get followIcon : Html {
    if (loading) {
      Html.empty()
    } else if (profile.following) {
      Ui.Icons:DASH
    } else {
      Ui.Icons:PLUS
    }
  }

  get followButton : Html {
    case (user) {
      UserStatus::Visitor => Html.empty()

      UserStatus::LoggedIn(user) =>
        <div::button>
          if (user.username != profile.username) {
            <Ui.Button
              iconBefore={followIcon}
              label={followText}
              onClick={toggleFollowing}
              disabled={loading}/>
          } else {
            <Ui.Button
              iconBefore={Ui.Icons:PERSON}
              label="编辑个人资料"
              onClick={editProfile}
              disabled={loading}/>
          }
        </div>
    }
  }

  fun editProfile (evt : Html.Event) {
    Window.navigate("/settings")
  }

  fun toggleFollowing (evt : Html.Event) {
    handleFollowing(profile)
  }

  fun render : Html {
    <Loader
      status={Api.toStatus(status)}
      errorMessage={Api.errors(status)}>

      <div::base>
        <div::banner>
          <img::image src={profile.image}/>
        </div>

        <div::grid>
          <div::cell>
            <img::avatar src={profile.avatar}/>
          </div>

          <div::cell::username>
            <{ profile.username }>
          </div>

          <div::cell::bio>
            <{ profile.bio }>
          </div>

          <div::cell>
            <{ followButton }>
          </div>
        </div>
      </div>

    </Loader>
  }
}
