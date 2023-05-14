package helpers

import (
	"net/http"
	"strings"

	"github.com/Athlon64/blogging_site/validators"
	"github.com/go-playground/validator/v10"
)

type Errors struct {
	Status int
	ErrMap map[string]string
}

var (
	ErrAuthorizationFailed = NewError(http.StatusUnauthorized, "authorization", "鉴权失败")
)

func (e *Errors) Error() string {
	var errs string
	for k, v := range e.ErrMap {
		errs += k + ": " + v + "\n"
	}

	return errs
}

func NewError(status int, name string, error string) *Errors {
	errs := &Errors{
		Status: status,
		ErrMap: make(map[string]string),
	}
	errs.ErrMap[name] = error

	return errs
}

func ErrorsFromValidator(errors error) *Errors {
	errs := &Errors{
		Status: http.StatusUnprocessableEntity,
		ErrMap: make(map[string]string),
	}
	if errors, ok := errors.(validator.ValidationErrors); ok {
		for _, e := range errors {
			errs.ErrMap[strings.ToLower(e.Field())] = e.Translate(validators.Trans)
		}
	}

	return errs
}

func InternalServerError(error string) *Errors {
	return NewError(http.StatusInternalServerError, "server", error)
}
