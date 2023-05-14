enum Status {
  Initial
  Loading
  Ok
  Error
}

component Loader {
  property status : Status = Status::Initial
  property loadingMessage : String = "正在加载，请稍候..."
  property errorMessage : String = "发生错误，请稍后重试..."
  property children : Array(Html) = []

  style error {
    color: deeppink;
  }

  fun render : Html {
    case (status) {
      Status::Initial => <></>

      Status::Loading =>
        <h3>
          <{ loadingMessage }>
        </h3>

      Status::Error =>
        <h3::error>
          <{ errorMessage }>
        </h3>

      Status::Ok =>
        <{ children }>
    }
  }
}
