package main

import (
	"bytes"
	"fmt"
	"os"
	"regexp"
	"unicode"

	"github.com/urfave/cli"
	"golang.org/x/text/unicode/norm"
)

var version = "0.1.1"
var newLine = regexp.MustCompile(`(\r?\n)+`)
var duplicateWhiteSpace = regexp.MustCompile(`( ){2,}`)
var hyphenAtEnd = regexp.MustCompile(`-([^\S]+|(\r?\n))`)
var endOfSentence = regexp.MustCompile(`[?!.]`)
var emptyErrorMsg = `NSaYw3'D2o,W1eL_|ac\`

func main() {
	app := cli.NewApp()
	app.Name = "go-alfred-sentence-splitter"
	app.Usage = "Remove all `\\n` in the sentence and then separate by period and remove reference number."
	app.Version = version
	app.Commands = []cli.Command{
		{
			Name:   "split",
			Usage:  "Remove `\\n` and split sentence by period.",
			Action: common,
		},
		{
			Name:   "reshape",
			Usage:  "Just remove `\\n` ...etc",
			Action: common,
		},
	}
	app.Run(os.Args)
}

func common(c *cli.Context) {
	var res string
	res = norm.NFC.String(c.Args().First())
	res = removeEndHyphen(res)
	res = removeNewLine(res)
	res = removeConsecutiveWhiteSpace(res)
	if len([]rune(res)) < 2 {
		fmt.Print(emptyErrorMsg)
		os.Exit(1)
	}
	if c.Command.Name == "split" {
		res = split(res)
	}
	fmt.Print(res)
}

func split(sentence string) string {
	splittedSentence := splitAfter(sentence, endOfSentence)
	var buffer bytes.Buffer
	for i, s := range splittedSentence {
		rs := []rune(s)
		if i == 0 || len(rs) < 3 {
			buffer.WriteString(s)
			continue
		}
		mode := firstCharType(rs)
		switch mode {
		case 0:
			// Nothing to do
		case 1:
			buffer.WriteString("\n\n")
		default:
			buffer.WriteString(" ")
		}
		buffer.WriteString(s)
	}
	return buffer.String()
}

func firstCharType(rs []rune) (mode int) {
	for _, s := range rs {
		if !unicode.IsSpace(s) {
			if unicode.IsDigit(s) {
				mode = 0
			} else if unicode.IsUpper(s) {
				mode = 1
			} else {
				mode = 2
			}
			break
		}
	}
	return
}

func splitAfter(s string, re *regexp.Regexp) []string {
	var (
		r []string
		p int
	)
	is := re.FindAllStringIndex(s, -1)
	if is == nil {
		return append(r, s)
	}
	for _, i := range is {
		r = append(r, s[p:i[1]])
		p = i[1]
	}
	return append(r, s[p:])
}

func removeNewLine(sentence string) string {
	return newLine.ReplaceAllString(sentence, "")
}

func removeEndHyphen(sentence string) string {
	return hyphenAtEnd.ReplaceAllString(sentence, "")
}

func removeConsecutiveWhiteSpace(sentence string) string {
	return duplicateWhiteSpace.ReplaceAllString(sentence, " ")
}
