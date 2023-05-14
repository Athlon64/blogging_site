package models

import (
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var (
	DB  *gorm.DB
	err error
)

func init() {
	// DB, err = gorm.Open(sqlite.Open("blogging_site.db"), &gorm.Config{Logger: logger.Default.LogMode(logger.Info)})
	DB, err = gorm.Open(sqlite.Open("blogging_site.db"))
	if err != nil {
		panic(err)
	}

	DB.AutoMigrate(&Article{})
	DB.AutoMigrate(&Comment{})
	DB.AutoMigrate(&Tag{})
	DB.AutoMigrate(&User{})
}
