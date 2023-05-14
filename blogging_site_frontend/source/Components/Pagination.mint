component Pagination {
  property total : Number = 0

  connect Stores.Pagination exposing { sidePages, perPage, page, setPage }

  style pagination {
    display: flex;
    justify-content: center;
    margin-top: 1.25em;
  }

  fun render : Html {
    if (total > perPage) {
      <div::pagination>
        <Ui.Pagination
          onChange={setPage}
          sidePages={sidePages}
          perPage={perPage}
          total={total}
          page={page}/>
      </div>
    } else {
      Html.empty()
    }
  }
}
