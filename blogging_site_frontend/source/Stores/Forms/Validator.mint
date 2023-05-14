store Stores.Forms.Validator {
  state errors : Map(String, Array(String)) = Map.empty()

  fun reset {
    next { errors = Map.empty() }
  }

  fun isFieldsValid (
    errorsToBeChecked : Array(Maybe(Tuple(String, String)))
  ) : Bool {
    try {
      errors =
        Validation.merge(errorsToBeChecked)

      next { errors = errors }

      if (Map.isEmpty(errors)) {
        true
      } else {
        false
      }
    }
  }
}
