.PHONY: build install watch live-http
watch:
	# watchexec --exts slang,cr,yml make live-render
	watchexec --exts slang,cr,yml -r -s SIGINT make live-http

live-http: build-dev
	./bin/log-watcher 21400

build:
	shards build -v --release

build-dev:
	shards build -v

install:
	shards build -v --release && mv ./bin/log-watcher /usr/local/bin
