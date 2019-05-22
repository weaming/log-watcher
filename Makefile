.PHONY: build install watch live-http
watch:
	# watchexec --exts slang,cr,yml make live-render
	watchexec --exts slang,cr,yml -r -s SIGINT make live-http

live-http: build
	./bin/log-watcher . 9000

build:
	shards build -v

install:
	shards build -v --release && mv ./bin/log-watcher /usr/local/bin
