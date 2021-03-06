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

  # manage WatchMux
  class WatcherManager
    getter mapping = {} of String => WatchMux

    def watch(file : String, socket : HTTP::WebSocket, position = 0, last = 0)
      if ENV.has_key? "DEBUG"
        puts "got position #{position}, last #{last}"
      end
      file = Path.posix(file).expand.to_s

      # send exists log
      LogWatcher.read_appended file, position, last do |p, line|
        begin
          socket.send line
        rescue ex
          puts ex
          return
        end
        position = p
      end

      if @mapping.has_key? file
        if !mapping[file].enabled?
          @mapping[file].append socket
          return
        end
      end
      @mapping[file] = WatchMux.new(file, [socket], position)
    end
  end

  def self.main
    port = Helper::CLI.argv_n?(1, "8000").to_i32
    serve_http port
  end
end

LogWatcher.main
