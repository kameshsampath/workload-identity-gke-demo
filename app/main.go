package main

import (
	"context"
	"net/http"
	"os"
	"time"

	"cloud.google.com/go/translate"
	"github.com/labstack/echo/v4"
	log "github.com/sirupsen/logrus"
	"golang.org/x/text/language"
)

func main() {
	e := echo.New()
	port := "8080"
	if p, ok := os.LookupEnv("PORT"); ok {
		port = p
	}

	e.GET("/:lang", handler)

	if err := e.Start(":" + port); err != nil {
		log.Fatal(err)
	}
}

func handler(c echo.Context) error {
	lang := c.Param("lang")
	if lang != "" {
		bgCtx := context.Background()
		ctx, cancel := context.WithTimeout(bgCtx, 10*time.Second)
		defer cancel()

		client, err := translate.NewClient(ctx)
		if err != nil {
			log.Error(err)
			return err
		}
		res, err := client.Translate(bgCtx, []string{"Hello World!"},
			language.MustParse(lang), &translate.Options{
				Source: language.English,
				Format: translate.Text,
			})
		if err != nil {
			log.Error(err)
			return err
		}
		if len(res) > 0 {
			t := res[0].Text
			log.Infof("Translated 'Hello World!' to %s in language %s", t, lang)
			return c.JSON(http.StatusOK, map[string]string{
				"text":                "Hello World!",
				"translation":         t,
				"translationLanguage": lang,
			})
		}
	}

	return c.String(http.StatusOK, "Hello World!")
}
