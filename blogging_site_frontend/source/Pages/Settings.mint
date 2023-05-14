component Pages.Settings {
  connect Stores.Forms.Settings exposing {
    status,
    submit,
    username,
    email,
    avatar,
    image,
    bio,
    setAvatar,
    setImage,
    setBio
  }

  style title {
    margin-bottom: 1.5em;
    font-size: 1.5em;
    text-align: center;

    @media (max-width: 1024px) {
      margin-bottom: 1.125em;
    }
  }

  style grid {
    display: grid;
    grid-template-columns: 1fr 1fr;

    grid-template-areas: "username email"
                         "avatar bgImage"
                         "bio bio"
                         "button button";

    gap: 1.25em;

    > *:nth-child(1) {
      grid-area: username;
    }

    > *:nth-child(2) {
      grid-area: email;
    }

    > *:nth-child(3) {
      grid-area: avatar;
    }

    > *:nth-child(4) {
      grid-area: bgImage;
    }

    > *:nth-child(5) {
      grid-area: bio;
    }

    > *:last-child {
      grid-area: button;
    }

    @media (max-width: 1024px) {
      grid-template-areas: "username" "email" "avatar" "bgImage" "bio" "button";
      grid-template-columns: 1fr;
      gap: 0.9375em;
    }
  }

  style cell {
    display: grid;
  }

  style button {
    margin-top: 1.875em;
    text-align: center;
  }

  get buttonText : String {
    if (Api.isLoading(status)) {
      "处理中..."
    } else {
      "提交"
    }
  }

  fun errorOf (name : String) {
    Api.errorOf(name, Map.empty(), status)
  }

  fun onSubmit (evt : Html.Event) {
    submit()
  }

  fun componentDidMount {
    Helpers.focus(form)
  }

  fun render : Html {
    <Ui.Box>
      <Ui.FocusTrap>
        <div::title>
          <{ "编辑个人资料" }>
        </div>

        <div::grid as form>
          <div::cell>
            <Ui.Field label="用户名">
              <Ui.Input
                placeholder="用户名"
                disabled={true}
                value={username}/>
            </Ui.Field>
          </div>

          <div::cell>
            <Ui.Field label="邮箱地址">
              <Ui.Input
                placeholder="邮箱地址"
                disabled={true}
                value={email}/>
            </Ui.Field>
          </div>

          <div::cell>
            <Ui.Field
              label="头像"
              error={errorOf("avatar")}>

              <Ui.Input
                placeholder="头像 URL"
                onChange={setAvatar}
                disabled={Api.isLoading(status)}
                value={avatar}/>

            </Ui.Field>
          </div>

          <div::cell>
            <Ui.Field
              label="个人主页背景图像"
              error={errorOf("image")}>

              <Ui.Input
                placeholder="背景图像 URL"
                onChange={setImage}
                disabled={Api.isLoading(status)}
                value={image}/>

            </Ui.Field>
          </div>

          <div::cell>
            <Ui.Field
              label="个性签名"
              error={errorOf("bio")}>

              <Ui.Input
                placeholder="个性签名"
                onChange={setBio}
                disabled={Api.isLoading(status)}
                value={bio}/>

            </Ui.Field>
          </div>

          <div::cell>
            <div::button>
              <Ui.Button
                iconBefore={Ui.Icons:FILE}
                label={buttonText}
                onClick={onSubmit}/>
            </div>
          </div>
        </div>
      </Ui.FocusTrap>
    </Ui.Box>
  }
}
