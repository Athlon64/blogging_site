component Main {
  connect App exposing { page }

  fun render : Html {
    case (page) {
      Page::Initial => <></>

      Page::Home =>
        <Layout>
          <Pages.Home/>
        </Layout>

      Page::Article =>
        <Layout>
          <Pages.Article/>
        </Layout>

      Page::Edit =>
        <Layout>
          <Pages.Edit/>
        </Layout>

      Page::Login =>
        <Theme>
          <Pages.Login/>
        </Theme>

      Page::Register =>
        <Theme>
          <Pages.Register/>
        </Theme>

      Page::Settings =>
        <Layout>
          <Pages.Settings/>
        </Layout>

      Page::Profile =>
        <Layout>
          <Pages.Profile/>
        </Layout>

      Page::NotFound =>
        <Layout>"404 Not Found"</Layout>
    }
  }
}
