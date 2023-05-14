package validators

import (
	"github.com/gin-gonic/gin/binding"
	chs "github.com/go-playground/locales/zh"
	ut "github.com/go-playground/universal-translator"
	"github.com/go-playground/validator/v10"
	chs_trans "github.com/go-playground/validator/v10/translations/zh"
)

var (
	uni      *ut.UniversalTranslator
	validate *validator.Validate
	Trans    ut.Translator
)

func Customize() {
	zh := chs.New()
	uni = ut.New(zh, zh)

	Trans, _ = uni.GetTranslator("zh")

	validate = binding.Validator.Engine().(*validator.Validate)
	chs_trans.RegisterDefaultTranslations(validate, Trans)
}
