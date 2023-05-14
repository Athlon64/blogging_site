component ArticleInfo {
  connect Stores.Article exposing { toggleFavorite }
  connect Stores.Tabs exposing { changeTag }

  property article : Article = Article.empty()

  state isLoading : Bool = false

  style base {
    display: flex;
    justify-content: space-between;
    padding: 1.2em 0 0 0;
  }

  style button {
    background: transparent;
    align-items: center;
    display: flex;
    border: 0;
    color: #{color};
    cursor: pointer;

    &:hover {
      opacity: 0.8;
    }

    &:disabled {
      opacity: 0.5;
    }
  }

  style button-text {
    margin-left: 0.3125em;
    font-weight: bold;
  }

  get color {
    if (article.favorited) {
      "var(--primary-color)"
    } else {
      "inherit"
    }
  }

  fun onToggleClick {
    sequence {
      next { isLoading = true }

      toggleFavorite(article)

      next { isLoading = false }
    }
  }

  fun render : Html {
    <div::base>
      <div>
        <Tags
          tags={article.tags}
          onClick={changeTag}/>
      </div>

      <button::button
        onClick={onToggleClick}
        disabled={isLoading}>

        <Ui.Icon icon={Ui.Icons:BOOKMARK}/>

        <span::button-text>
          <{ Number.toString(article.favoritesCount) }>
        </span>

      </button>
    </div>
  }
}
