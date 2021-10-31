SHELL   := /bin/bash

BINDIR := $(CURDIR)/bin
CACHEDIR := $(CURDIR)/.cache
DISTDIR := $(CURDIR)/dist

GOOS := darwin
GOARCH ?= $(shell go env GOARCH)
NAME    := google-translate-formatter-$(GOARCH)
PACKAGE := $(DISTDIR)/$(NAME).alfredworkflow
SRCS    := $(wildcard *.go) go.mod go.sum
VERSION := $(shell cat VERSION)
REVISION:= $(shell git rev-parse --short HEAD || echo "In-Development")
LDFLAGS := -ldflags="-s -w -X \"main.version=$(VERSION)-$(REVISION)\" -extldflags \"-static\""

GOLANGCI_LINT := $(BINDIR)/golangci-lint 
GOLANGCI_LINT_VERSION := 1.42.1

BUILT_TARGET := $(NAME)

.DEFAULT_GOAL := build

build: lint test $(BUILT_TARGET) ;

$(BUILT_TARGET): $(SRCS)
	@echo "Build $(NAME) $(VERSION)"
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build $(LDFLAGS) -o $(NAME) .

clean:
	rm -rf $(BUILT_TARGET)*
	rm -f dist/*

$(BINDIR) $(CACHEDIR) $(DISTDIR):
	mkdir $@

$(CACHEDIR)/golangci-lint-$(GOLANGCI_LINT_VERSION): | $(CACHEDIR)
	GOBIN=$(CACHEDIR) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v$(GOLANGCI_LINT_VERSION)
	mv $(CACHEDIR)/golangci-lint $@

$(GOLANGCI_LINT): $(CACHEDIR)/golangci-lint-$(GOLANGCI_LINT_VERSION) | $(BINDIR)
	ln -sf $< $@

lint: $(GOLANGCI_LINT)
	$(GOLANGCI_LINT) run ./...

test: $(SRCS)
	go test -v ./...

$(PACKAGE): $(BUILT_TARGET) VERSION | $(DISTDIR)
	$(eval TMPDIR=$(shell mktemp -d google-translate-formatter-XXXXXX))
	$(eval VER=$(shell cat VERSION))
	cp $(NAME) $(TMPDIR)/google-translate-formatter
	cp resources/* $(TMPDIR)/
	cp LICENSE $(TMPDIR)/
	sed -e "/.*>version<.*/{n;s/[0-9]\.[0-9]\.[0-9]/$(VER)/;}" resources/info.plist > $(TMPDIR)/info.plist
	cd $(TMPDIR) && zip $(PACKAGE) ./*
	rm -rf $(TMPDIR)

package: $(PACKAGE) ;

all: clean package ;

.PHONY: build rebuild clean lint test deps package ;
