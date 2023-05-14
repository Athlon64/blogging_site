component Pages.Edit {
  connect Stores.Forms.Article exposing {
    submit,
    status,
    slug,
    tags,
    abstract,
    content,
    title,
    setAbstract,
    setContent,
    setTitle,
    setTags
  }

  connect Stores.Forms.Validator exposing { errors }

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

    grid-template-areas: "title tags"
                         "abstract abstract"
                         "content preview"
                         "button button";

    gap: 1.25em;

    > *:nth-child(1) {
      grid-area: title;
    }

    > *:nth-child(2) {
      grid-area: tags;
    }

    > *:nth-child(3) {
      grid-area: abstract;
    }

    > *:nth-child(4) {
      grid-area: content;
    }

    > *:nth-child(5) {
      grid-area: preview;
    }

    > *:last-child {
      grid-area: button;
    }

    @media (max-width: 1024px) {
      grid-template-areas: "title" "tags" "abstract" "content" "preview" "button";
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

  style preview {
    padding: 0.625em 1.25em;
    min-height: 2.3em;
    border-radius: 0.3125em;
    border: 0.0625em solid yellowgreen;
    font-size: 0.6em;

    img {
      max-width: 100%;
      max-height: 100%;
    }
  }

  get titleText : String {
    if (Maybe.isJust(slug)) {
      "编辑文章"
    } else {
      "撰写文章"
    }
  }

  get buttonText : String {
    if (Api.isLoading(status)) {
      "处理中..."
    } else {
      "提交"
    }
  }

  get tagsText : String {
    String.join(" ", Set.toArray(tags))
  }

  fun errorOf (name : String) {
    Api.errorOf(name, errors, status)
  }

  fun componentDidMount {
    Helpers.focus(form)
  }

  fun render : Html {
    <Ui.Box>
      <Ui.FocusTrap>
        <div::title>
          <{ titleText }>
        </div>

        <div::grid as form>
          <div::cell>
            <Ui.Field
              label="标题"
              error={errorOf("title")}>

              <Ui.Input
                placeholder="文章标题"
                onChange={setTitle}
                disabled={Api.isLoading(status)}
                value={title}/>

            </Ui.Field>
          </div>

          <div::cell>
            <Ui.Field
              label="标签（多个标签请用空格隔开）"
              error={errorOf("tag")}>

              <Ui.Input
                placeholder="标签"
                inputDelay={1000}
                onChange={setTags}
                disabled={Api.isLoading(status)}
                value={tagsText}/>

            </Ui.Field>
          </div>

          <div::cell>
            <Ui.Field
              label="摘要"
              error={errorOf("abstract")}>

              <Ui.Textarea
                placeholder="文章摘要"
                behavior="grow"
                onChange={setAbstract}
                disabled={Api.isLoading(status)}
                value={abstract}/>

            </Ui.Field>
          </div>

          <div::cell>
            <Ui.Field
              label="内容"
              error={errorOf("body")}>

              <Ui.Textarea
                placeholder="文章正文"
                behavior="grow"
                onChange={setContent}
                disabled={Api.isLoading(status)}
                value={content}/>

            </Ui.Field>
          </div>

          <div::cell>
            <Ui.Field label="预览">
              <div::preview>
                <Markdown content={content}/>
              </div>
            </Ui.Field>
          </div>

          <div::cell>
            <div::button>
              <Ui.Button
                iconBefore={Ui.Icons:FILE}
                label={buttonText}
                onClick={submit}/>
            </div>
          </div>
        </div>
      </Ui.FocusTrap>
    </Ui.Box>
  }
}
