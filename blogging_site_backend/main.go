package main

import (
	_ "github.com/Athlon64/blogging_site/models"
	"github.com/Athlon64/blogging_site/routers"
	"github.com/Athlon64/blogging_site/validators"
)

func main() {
	validators.Customize()
	routers.Run()
}
