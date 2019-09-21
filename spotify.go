package main

import (
	"fmt"
	"log"
	"os"
	"regexp"
	"strconv"
	"strings"

	"github.com/godbus/dbus"
)

const (
	propMetadata = "org.mpris.MediaPlayer2.Player.Metadata"
	dest         = "org.mpris.MediaPlayer2.spotify"
	objPath      = "/org/mpris/MediaPlayer2"
)

var patternMatch = regexp.MustCompile(`%([\w:]+)%`)

func main() {
	showSong()
}

func showSong() {
	if len(os.Args) < 2 {
		fmt.Println("Need pattern to format the output, like %artist% %title% %album% %artUrl% %url%")
		os.Exit(1)
	}

	pattern := strings.Join(os.Args[1:], " ")

	objValues := getCurrent()

	data := map[string]string{}
	keys := []string{}

	for dataName, dataValue := range objValues {
		keys = append(keys, dataName)
		switch v := dataValue.Value().(type) {
		case string:
			data["%"+dataName+"%"] = v
		case []string:
			data["%"+dataName+"%"] = strings.Join(v, ", ")
		case int32:
			data["%"+dataName+"%"] = strconv.FormatInt(int64(v), 10)
		case uint64:
			data["%"+dataName+"%"] = strconv.FormatUint(v, 10)
		case int64:
			data["%"+dataName+"%"] = strconv.FormatInt(v, 10)
		case float64:
			data["%"+dataName+"%"] = strconv.FormatFloat(v, 'f', 3, 64)
		default:
			fmt.Printf("%t\n", v)
		}
	}

	result := patternMatch.ReplaceAllStringFunc(pattern, func(match string) string {
		if found, ok := data[match]; ok {
			return found
		} else {
			fmt.Printf("Key '%s' not found, possible keys are: %v\n", match, keys)
			os.Exit(1)
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

func getCurrent() map[string]dbus.Variant {
	conn, err := dbus.SessionBus()
	fail(err)

	obj := conn.Object(dest, objPath)
	objValue, err := obj.GetProperty(propMetadata)
	if err != nil {
		if err.Error() == "The name org.mpris.MediaPlayer2.spotify was not provided by any .service files" {
			fmt.Println("spotify not running")
			os.Exit(1)
		}
		fail(err)
	}
	return objValue.Value().(map[string]dbus.Variant)
}
