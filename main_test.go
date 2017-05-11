package main

import (
	"testing"
)

var testSentence = `This is a test sentence of go-alfred-sentence-splitter. Unittest is very im-
 portant for software. It is not only testing system, but the easiest way (1, 2). So if you write code,
 you sholud write unittest too. CI (Continuous Integration) is important too. Both systems will save
 your codes' quality.  written by Pudding`

var expectedNewlineRemoved = `This is a test sentence of go-alfred-sentence-splitter. Unittest is very im- portant for software. It is not only testing system, but the easiest way (1, 2). So if you write code, you sholud write unittest too. CI (Continuous Integration) is important too. Both systems will save your codes' quality.  written by Pudding`

var expectedHyphenRemoved = `This is a test sentence of go-alfred-sentence-splitter. Unittest is very important for software. It is not only testing system, but the easiest way (1, 2). So if you write code,
 you sholud write unittest too. CI (Continuous Integration) is important too. Both systems will save
 your codes' quality.  written by Pudding`

var expectedWhitespaceRemoved = `This is a test sentence of go-alfred-sentence-splitter. Unittest is very im-
 portant for software. It is not only testing system, but the easiest way (1, 2). So if you write code,
 you sholud write unittest too. CI (Continuous Integration) is important too. Both systems will save
 your codes' quality. written by Pudding`

var expectedRefNumberRemoved = `This is a test sentence of go-alfred-sentence-splitter. Unittest is very im-
 portant for software. It is not only testing system, but the easiest way . So if you write code,
 you sholud write unittest too. CI (Continuous Integration) is important too. Both systems will save
 your codes' quality.  written by Pudding`

var expectedSplit = `This is a test sentence of go-alfred-sentence-splitter.

 Unittest is very im- portant for software.

 It is not only testing system, but the easiest way (1, 2).

 So if you write code, you sholud write unittest too.

 CI (Continuous Integration) is important too.

 Both systems will save your codes' quality.   written by Pudding`

func TestRemoveNewLine(t *testing.T) {
	result := removeNewLine(testSentence)
	if result != expectedNewlineRemoved {
		outputError("removeNewLine", expectedNewlineRemoved, result, t)
	}
}

func TestRemovedWhitespace(t *testing.T) {
	result := removeConsecutiveWhiteSpace(testSentence)
	if result != expectedWhitespaceRemoved {
		outputError("removeConsecutiveWhiteSpace", expectedWhitespaceRemoved, result, t)
	}
}

func TestRemoveEndHyphen(t *testing.T) {
	result := removeEndHyphen(testSentence)
	if result != expectedHyphenRemoved {
		outputError("removeEndHyphen", expectedHyphenRemoved, result, t)
	}
}

func TestRemoveRefNumber(t *testing.T) {
	result := removeRefNum(testSentence)
	if result != expectedRefNumberRemoved {
		outputError("removeRefNum", expectedRefNumberRemoved, result, t)
	}
}

func TestSplit(t *testing.T) {
	result := removeNewLine(testSentence)
	result = split(result)
	if result != expectedSplit {
		outputError("split", expectedSplit, result, t)
	}
}

func outputError(funcName string, expect string, result string, t *testing.T) {
	t.Errorf("%v output invalid sentence. \nExpect: %v\nResult: %v", funcName, expect, result)
}