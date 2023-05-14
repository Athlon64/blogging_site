component Tabs {
  property activeTab : String = ""
  property items : Array(Ui.Tab) = []
  property onChange : Function(String, Promise(Never, Void)) = Promise.never1

  fun render : Html {
    <Ui.Tabs
      active={activeTab}
      onChange={onChange}
      items={items}/>
  }
}
