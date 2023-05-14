component Tag {
  connect Stores.Tabs exposing { tag }

  property name : String = ""
  property onClick : Function(Html.Event, Promise(Never, Void))

  style tag {
    display: inline-block;
    margin: 0.1875em 0.3125em 0.1875em 0;
    padding: 0.1875em 0.375em;
    text-decoration: none;
    color: #{color};
    background-color: #{backgroundColor};
    border-radius: 0.1875em;
    cursor: pointer;

    &:hover {
      background-color: #adadad;
    }
  }

  get active : Bool {
    tag == name
  }

  get color : String {
    if (active) {
      "var(--primary-text)"
    } else {
      "#6c757d"
    }
  }

  get backgroundColor : String {
    if (active) {
      "var(--primary-color)"
    } else {
      "#cdcdcd"
    }
  }

  fun render : Html {
    <a::tag onClick={onClick}>
      <{ name }>
    </a>
  }
}
