SHELL   := /bin/bash

NAME    := google-translate-formatter
PACKAGE := $(NAME).alfredworkflow
PLIST   := resources/info.plist
SRCS    := $(wildcard *.go) go.mod go.sum
VERSION := $(shell git describe --tag --abbrev=0 || echo "v0.0.0")
REVISION:= $(shell git rev-parse --short HEAD || echo "In-Development")
LDFLAGS := -ldflags="-s -w -X \"main.version=$(VERSION)-$(REVISION)\" -extldflags \"-static\""

BINDIR := $(CURDIR)/bin
CACHEDIR := $(CURDIR)/.cache
GOLANGCI_LINT := $(BINDIR)/golangci-lint 
GOLANGCI_LINT_VERSION := 1.42.1

BUILT_TARGET := $(NAME)

.DEFAULT_GOAL := all

build: test $(BUILT_TARGET) ;

$(BUILT_TARGET): $(SRCS)
	@echo "Build $(NAME) $(VERSION)"
	GO111MODULE=on go build $(LDFLAGS) -o $(NAME) .

clean:
	rm -f $(BUILT_TARGET)

rebuild: clean build ;

$(BINDIR) $(CACHEDIR):
	mkdir $@

$(CACHEDIR)/golangci-lint-$(GOLANGCI_LINT_VERSION): | $(CACHEDIR)
	GOBIN=$(CACHEDIR) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v$(GOLANGCI_LINT_VERSION)
	mv $(CACHEDIR)/golangci-lint $@

$(GOLANGCI_LINT): $(CACHEDIR)/golangci-lint-$(GOLANGCI_LINT_VERSION) | $(BINDIR)
	ln -sf $< $@

lint: $(GOLANGCI_LINT)
	$(GOLANGCI_LINT) run ./...

test-only: $(SRCS)
	go test -v ./...

test: lint test-only ;

deps:
	go mod download

release: test
	@if [[ ! "$(VER)" =~ ^([0-9]\.){2}[0-9]$$ ]]; then \
		echo "'$(VER)' is invalid. Please call this like 'make release VER=0.0.0'"; \
		exit 1; \
	fi
	sed -i '' -e "/.*>version<.*/{n;s/[0-9]\.[0-9]\.[0-9]/$(VER)/;}" $(PLIST)
	git add $(PLIST)
	git commit -m 'Release v$(VER)'
	git tag v$(VER)
	# Push this release to remote, please type following command
	# $ git push origin $(VER)
	@echo "v$(VER)  [OK]"

$(PACKAGE): $(BUILT_TARGET)
	@if [ ! -d ./dist ]; then \
		mkdir -p ./dist; \
	fi
	mv $(NAME) ./dist/
	cp resources/* ./dist/
	cd ./dist/ && zip $(PACKAGE) ./*

package: $(PACKAGE) ;

all: build ;

.PHONY: build rebuild clean lint test-only test deps package ;
