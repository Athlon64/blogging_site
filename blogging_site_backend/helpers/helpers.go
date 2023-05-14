package helpers

import (
	"io/fs"
	"log"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

var MySigningKey = []byte("An example signing key")

func EncryptPassword(password string) (string, error) {
	encryptedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(encryptedPassword), err
}

func CheckPassword(plainPassword, encryptedPassword string) error {
	return bcrypt.CompareHashAndPassword([]byte(encryptedPassword), []byte(plainPassword))
}

func GetTokenString(c *gin.Context) string {
	tokenString := c.GetHeader("Authorization")
	return strings.TrimPrefix(tokenString, "Token ")
}

func NewToken(userID uint) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"userID": userID,
		"exp":    time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString(MySigningKey)
	return tokenString, err
}

func CheckToken(tokenString string) (float64, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return MySigningKey, nil
	})

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims["userID"].(float64), nil
	}

	return 0, err
}

func GetFileList() map[string]string {
	fileSystem := os.DirFS("./public")

	files := map[string]string{}
	fs.WalkDir(fileSystem, ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			log.Fatal(err)
		}

		if path != "." {
			files[path] = "./public/" + path
		}
		return nil
	})

	return files
}
