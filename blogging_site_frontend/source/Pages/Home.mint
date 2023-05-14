component Pages.Home {
  connect Stores.Tabs exposing {
    activeTab,
    changeTab,
    tag
  }

  connect Stores.Articles exposing { articlesCount }
  connect Stores.User exposing { user }

  style base {
    display: flex;
    margin-top: 0.625em;
  }

  style articles {
    flex: 3;
  }

  style tags {
    flex: 1;

    @media (max-width: 1024px) {
      display: none;
    }
  }

  fun appendNonBlankTab (tab : Ui.Tab, tabs : Array(Ui.Tab)) : Array(Ui.Tab) {
    if (String.isNotBlank(tab.label)) {
      Array.push(tab, tabs)
    } else {
      tabs
    }
  }

  get tabs {
    [
      {
        iconBefore = Ui.Icons:RSS,
        iconAfter = <></>,
        content = <{ <Articles/> }>,
        label = "所有文章",
        key = "All"
      }
    ]
    |> appendNonBlankTab(favoritesTab)
    |> appendNonBlankTab(tagTab)
  }

  get favoritesTab {
    if (user != UserStatus::Visitor) {
      {
        iconBefore = Ui.Icons:BOOKMARK,
        iconAfter = <></>,
        content = <{ <Articles/> }>,
        label = "我的收藏",
        key = "Favorites"
      }
    } else {
      {
        iconBefore = <></>,
        iconAfter = <></>,
        content = <></>,
        label = "",
        key = ""
      }
    }
  }

  get tagTab {
    if (activeTab == "Tag") {
      {
        iconBefore = Ui.Icons:TAG,
        iconAfter = <></>,
        content = <{ <Articles/> }>,
        label = tag,
        key = "Tag"
      }
    } else {
      {
        iconBefore = <></>,
        iconAfter = <></>,
        content = <></>,
        label = "",
        key = ""
      }
    }
  }

  fun render : Html {
    <div::base>
      <div::articles>
        <Tabs
          activeTab={activeTab}
          onChange={changeTab}
          items={tabs}/>

        <Pagination total={articlesCount}/>
      </div>

      <div::tags>
        <PopularTags/>
      </div>

      <BackToTop/>
    </div>
  }
}
