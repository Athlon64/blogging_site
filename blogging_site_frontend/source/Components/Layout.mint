component Layout {
  connect Stores.User exposing { user }
  property children : Array(Html) = []

  style footerText {
    color: #6c757d;
    margin-bottom: 2.5em;
    text-align: center;
  }

  style subtitle {
    font-size: 1.125em;
    margin-bottom: 0.625em;
  }

  style link {
    color: var(--primary-color);
    text-decoration: none;

    &:hover {
      color: var(--primary-hover);
      text-decoration: underline;
    }
  }

  get navItems {
    case (user) {
      UserStatus::Visitor =>
        [
          Ui.NavItem::Link(
            iconBefore = Ui.Icons:SIGN_IN,
            iconAfter = <></>,
            label = "登录",
            target = "",
            href = "/login"),
          Ui.NavItem::Link(
            iconBefore = Ui.Icons:SMILEY,
            iconAfter = <></>,
            label = "注册",
            target = "",
            href = "/register"),
          Ui.NavItem::Divider,
          Ui.NavItem::Link(
            iconBefore = <></>,
            iconAfter = <Ui.DarkModeToggle size={Ui.Size::Em(0.75)}/>,
            label = "",
            target = "",
            href = "")
        ]

      UserStatus::LoggedIn(user) =>
        [
          Ui.NavItem::Link(
            iconBefore = Ui.Icons:PENCIL,
            iconAfter = <></>,
            label = "写文章",
            target = "",
            href = "/new"),
          Ui.NavItem::Divider,
          Ui.NavItem::Group(
            iconBefore = Ui.Icons:THREE_BARS,
            iconAfter = <></>,
            label = user.username,
            items =
              [
                Ui.NavItem::Link(
                  iconBefore = Ui.Icons:PERSON,
                  iconAfter = <></>,
                  label = "个人主页",
                  target = "",
                  href = "/users/" + user.username),
                Ui.NavItem::Link(
                  iconBefore = Ui.Icons:SIGN_OUT,
                  iconAfter = <></>,
                  label = "退出登录",
                  target = "",
                  href = "/logout")
              ]),
          Ui.NavItem::Link(
            iconBefore = <></>,
            iconAfter = <Ui.DarkModeToggle size={Ui.Size::Em(0.75)}/>,
            label = "",
            target = "",
            href = "")
        ]
    }
  }

  fun render : Html {
    <Theme>
      <Ui.Layout.Website
        header={
          <Ui.Header
            brand={
              <Ui.Brand
                icon={Ui.Icons:HOME}
                name="首页"
                href="/"/>
            }
            items={navItems}/>
        }
        content=<{ children }>
        footer={
          <div>
            <Separator/>

            <div::footerText>
              <div::subtitle>"多用户社交博客网"</div>

              <div>
                "项目源码请访问 "

                <a::link
                  href="https://github.com/Athlon64/blogging_site"
                  target="_blank">

                  "blogging_site"

                </a>
              </div>
            </div>
          </div>
        }/>
    </Theme>
  }
}
