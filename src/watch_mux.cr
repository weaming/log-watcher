require "inotify"
require "inotify/watcher"

module LogWatcher
  class WatchMux
    getter path : String
    getter wsList : Array(HTTP::WebSocket)

    # getter watcher : Inotify::Watcher

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
end
