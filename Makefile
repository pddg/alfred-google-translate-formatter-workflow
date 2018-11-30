SHELL   := /bin/bash

NAME    := go-alfred-sentence-splitter
PACKAGE := sentence-splitter.alfredworkflow
PLIST   := resources/info.plist
SRCS    := $(shell go list -f {{.Dir}} ./... | grep -v /vendor/)
VERSION := $(shell git describe --tag --abbrev=0 || echo "v0.0.0")
REVISION:= $(shell git rev-parse --short HEAD || echo "In-Development")
LDFLAGS := -ldflags="-s -w -X \"main.version=$(VERSION)-$(REVISION)\" -extldflags \"-static\""

BUILT_TARGET := $(NAME)

.DEFAULT_GOAL := all

build: test $(BUILT_TARGET) ;

$(BUILT_TARGET): $(SRCS)
	@echo "Build $(NAME) $(VERSION)"
	go build $(LDFLAGS) .

clean:
	rm -f $(BUILT_TARGET)

rebuild: clean build ;

lint: $(SRCS)
	go vet -v ./...
	goimports -d $(SRCS) | tee /dev/stderr

test-only: $(SRCS)
	go test -v ./...

test: lint test-only ;

deps:
	@if ! type dep > /dev/null 2>&1; then\
		echo "Try to install dep..."; \
    	curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh;\
	fi
	dep ensure -vendor-only

release: test
	@if [[ ! "$(VER)" =~ ^v([0-9]\.){2}[0-9]$$ ]]; then \
		echo "'$(VER)' is invalid. Please call this like 'make release VER=v0.0.0'"; \
		exit 1; \
	fi
	sed -i '' -e "/.*>version<.*/{n;s/[0-9]\.[0-9]\.[0-9]/$(VER)/;}" $(PLIST)
	git add $(PLIST)
	git commit -m 'Release $(VER)'
	git tag $(VER)
	# Push this release to remote, please type following command
	# $ git push origin $(VER)
	@echo "$(VER)  [OK]"

$(PACKAGE): $(BUILT_TARGET)
	@if [ ! -d ./dist ]; then \
		mkdir -p ./dist; \
	fi
	mv $(NAME) ./dist/
	cp resources/* ./dist/
	cd ./dist/ && zip $(PACKAGE) ./*

package: $(PACKAGE) ;

all: dev test build ;

.PHONY: build rebuild clean lint test-only test deps package ;
