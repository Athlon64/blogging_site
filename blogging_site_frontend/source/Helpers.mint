module Helpers {
  fun focus (e : Maybe(Dom.Element)) {
    e
    |> Maybe.withDefault(Dom.createElement("div"))
    |> Dom.focusFirst()
  }
}
