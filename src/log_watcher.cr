require "uri"
require "http"

require "kilt/slang"
require "inotify"
require "inotify/watcher"

require "./helper"
require "./server"

class WatchMux
  getter path : String
  getter wsList : Array(HTTP::WebSocket)
  getter watcher : Inotify::Watcher

  def initialize(@path, @wsList)
    @watcher = Inotify.watch @path do |event|
      send_all "#{event}"
    end
  end

  def append(socket : HTTP::WebSocket)
    @wsList << socket
  end

  def send_all(msg : String)
    @wsList.each do |x|
      if x.closed?
        @wsList.delete x
        close_if_all_disconnected
      else
        x.send msg
      end
    end
  end

  def close_if_all_disconnected
    if @wsList.size == 0
      @watcher.close
    end
  end

  def enabled? : Bool
    @watcher.@enabled
  end
end

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
    getter mapping = {} of String => WatchMux

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
