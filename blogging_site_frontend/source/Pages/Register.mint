component Pages.Register {
  connect Stores.Register exposing {
    username,
    setUsername,
    password,
    setPassword,
    email,
    setEmail,
    submit,
    status
  }

  connect Stores.Forms.Validator exposing { errors }

  style base {
    height: 90vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  fun errorOf (name : String) {
    Api.errorOf(name, errors, status)
  }

  fun isInvalid (name : String) {
    Maybe.isJust(errorOf(name))
  }

  get buttonText {
    if (Api.isLoading(status)) {
      "处理中..."
    } else {
      "注册"
    }
  }

  use Provider.Keyup {
    keyups =
      (evt : Html.Event) {
        if (evt.key == "Enter") {
          submit(evt)
        } else {
          Promise.never()
        }
      }
  }

  fun componentDidMount {
    Helpers.focus(form)
  }

  fun render : Html {
    <Ui.FocusTrap>
      <div::base as form>
        <Ui.Layout.Centered maxContentWidth="20em">
          <Ui.Column gap={Ui.Size::Em(1.5)}>
            <Ui.Brand
              icon={Ui.Icons:SMILEY}
              name="注册"/>

            <Ui.Box>
              <Ui.Column gap={Ui.Size::Em(1)}>
                <Ui.Field
                  error={errorOf("username")}
                  label="用户名">

                  <Ui.Input
                    value={username}
                    onChange={setUsername}
                    invalid={isInvalid("username")}
                    placeholder="username"
                    type="text"/>

                </Ui.Field>

                <Ui.Field
                  error={errorOf("email")}
                  label="电子邮箱">

                  <Ui.Input
                    value={email}
                    onChange={setEmail}
                    invalid={isInvalid("email")}
                    placeholder="username@domain.com"
                    type="email"/>

                </Ui.Field>

                <Ui.Field
                  error={errorOf("password")}
                  label="密码">

                  <Ui.Input
                    value={password}
                    onChange={setPassword}
                    invalid={isInvalid("password")}
                    placeholder="12345678"
                    type="password"/>

                </Ui.Field>

                <Ui.Button
                  iconAfter={Ui.Icons:ARROW_RIGHT}
                  onClick={submit}
                  label={buttonText}
                  disabled={Api.isLoading(status)}/>
              </Ui.Column>
            </Ui.Box>
          </Ui.Column>
        </Ui.Layout.Centered>
      </div>
    </Ui.FocusTrap>
  }
}
