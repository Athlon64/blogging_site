component Theme {
  property children : Array(Html) = []

  fun render : Html {
    <Ui.Theme.Root
      tokens={Ui:DEFAULT_TOKENS}
      fontConfiguration={Ui:DEFAULT_FONT_CONFIGURATION}>

      <{ children }>

    </Ui.Theme.Root>
  }
}
