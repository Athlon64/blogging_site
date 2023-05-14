component BackToTop {
  fun render : Html {
    <Ui.ScrollToTop
      size={Ui.Size::Inherit}
      threshold={50}
      zIndex={800}
      global={true}/>
  }
}
