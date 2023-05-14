component Tags {
  property tags : Array(String) = []
  property onClick : Function(Html.Event, Promise(Never, Void))

  fun render : Html {
    <>
      for (tag of tags) {
        <Tag
          name={tag}
          onClick={onClick}/>
      }
    </>
  }
}
