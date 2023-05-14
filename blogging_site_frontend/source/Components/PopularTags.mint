component PopularTags {
  connect Stores.Tags exposing { status, tags }
  connect Stores.Tabs exposing { tag, changeTag }

  style base {
    margin: 0 1.875em;
  }

  style title {
    margin-bottom: 0.875em;
    font-size: 1.2em;
  }

  fun render : Html {
    <div::base>
      <Loader
        status={Api.toStatus(status)}
        errorMessage={Api.errors(status)}>

        <div::title>"热门标签"</div>

        <Tags
          tags={tags}
          onClick={changeTag}/>

      </Loader>
    </div>
  }
}
