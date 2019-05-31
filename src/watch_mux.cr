require "inotify"
require "inotify/watcher"

module LogWatcher
  # file -> list of websocket connections
  class WatchMux
    getter path : String
    getter wsList : Array(HTTP::WebSocket)
    getter position = 0

    # getter watcher : Inotify::Watcher

    def initialize(@path, @wsList, @position)
      @watcher = Inotify.watch @path do |event|
        puts "#{Time.now} #{event}"
        if event.type == Inotify::Event::Type::MODIFY
          LogWatcher.read_appended @path, @position do |position, line|
            send_all line
            @position = position
          end
        end
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
          begin
            x.send msg
          rescue ex
            puts ex
          end
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

  def self.read_appended(path : String, position)
    i = 0
    File.each_line path do |line|
      i += 1
      if i > position
        position += 1
        yield position, "#{position} #{line}"
      end
    end
  end
end
