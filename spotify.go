package main

import (
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"

	"github.com/godbus/dbus"
)

const (
	propMetadata = "org.mpris.MediaPlayer2.Player.Metadata"
	dest         = "org.mpris.MediaPlayer2.spotify"
	objPath      = "/org/mpris/MediaPlayer2"
)

var patternMatch = regexp.MustCompile(`%(\w+)%`)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Need pattern to return, using any of %artist% %title% %album% %artUrl% %url%")
		os.Exit(1)
	}

	pattern := strings.Join(os.Args[1:], " ")

	conn, err := dbus.SessionBus()
	fail(err)

	obj := conn.Object(dest, objPath)
	v, err := obj.GetProperty(propMetadata)
	fail(err)
	value := v.Value().(map[string]dbus.Variant)

	data := map[string]string{
		"%artist%": value["xesam:artist"].Value().([]string)[0],
		"%title%":  value["xesam:title"].Value().(string),
		"%album%":  value["xesam:album"].Value().(string),
		"%artUrl%": value["mpris:artUrl"].Value().(string),
		"%url%":    value["xesam:url"].Value().(string),
	}

	result := patternMatch.ReplaceAllStringFunc(pattern, func(match string) string {
		if found, ok := data[match]; ok {
			return found
		}
		return ""
	})

	fmt.Println(result)
}

func fail(err error) {
	if err != nil {
		log.Fatalln(err)
	}
}
