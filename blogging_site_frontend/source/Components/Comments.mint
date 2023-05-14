component Comments {
  connect Stores.Comments exposing { status, comments }

  style base {
    text-align: center;
    font-weight: bold;
    opacity: 0.7;
  }

  fun render : Html {
    <Loader
      status={Api.toStatus(status)}
      errorMessage={Api.errors(status)}>

      if (Array.isEmpty(comments)) {
        <div::base>"尚无评论"</div>
      } else {
        <>
          for (comment of comments) {
            <Article.Comment comment={comment}/>
          }
        </>
      }

    </Loader>
  }
}
