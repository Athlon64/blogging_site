component UserInfo {
  property user : Author = Author.empty()

  style grid {
    display: grid;
    gap: 0.3125em 0.5em;

    grid-template-columns: min-content 1fr min-content;

    grid-template-areas: "avatar username"
                         "avatar bio";

    > *:nth-child(1) {
      grid-area: avatar;
    }

    > *:nth-child(2) {
      grid-area: username;
    }

    > *:nth-child(3) {
      grid-area: bio;
    }
  }

  style cell {
    display: grid;
    align-content: center;
  }

  style avatar {
    width: 4em;
    height: 4em;
    border-radius: 50%;
  }

  style username {
    font-weight: bold;
    font-size: 1.25em;
  }

  style bio {
    font-size: 1em;
    opacity: 0.8;
  }

  fun render : Html {
    <div::grid>
      <div::cell>
        <img::avatar src={user.avatar}/>
      </div>

      <div::cell::username>
        <{ user.username }>
      </div>

      <div::cell::bio>
        <{ user.bio }>
      </div>
    </div>
  }
}
