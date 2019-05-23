require "uri"
require "http"

require "kilt/slang"

require "./helper"
require "./server"
require "./watch_mux"

module LogWatcher
  class Renderer
    getter path : String

    def initialize(@path : String)
    end

    def render : String
      head = self.render_head
      body = self.render_body
      head + body
    end

    def render_head : String
      title = @path
      Kilt.render("src/templates/head.slang")
    end

    def render_body : String
      Kilt.render("src/templates/body.slang")
    end
  end

  class WatcherManager
    # getter mapping = {} of String => WatchMux

    def watch(file : String, socket : HTTP::WebSocket)
      if @mapping.has_key? file && !mapping[file].enabled?
        @mapping[file].append socket
      else
        @mapping[file] = WatchMux.new(file, [socket])
      end
    end
  end

  def self.main
    root = Helper::CLI.argv_first("missing directory to watch")
    port = Helper::CLI.argv_n?(2, "8000").to_i32
    serve_http port
  end
end

LogWatcher.main
