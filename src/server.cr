require "kemal"

module LogWatcher
  def self.unifyPath(path : String) : String
    if path == ""
      path = "."
    end
    path
  end

  def self.serve_http(port : Int32?)
    watcherMgr = WatcherManager.new

    error 404 do
      "404 NOT FOUND"
    end

    get "/*" do |env|
      path = env.request.path[1..]
      path = unifyPath(path)

      if File.file?(path)
        # render html page to display websocket messages
        renderer = Renderer.new path
        html = renderer.render
        html
      elsif File.directory?(path)
        if path.ends_with?('/') || path == "."
          dir = Dir.open path
          title = path
          head = Kilt.render("src/templates/head.slang")
          body = Kilt.render("src/templates/dir.slang")
          head + body
        else
          env.redirect "#{path}"
        end
      else
        env.response.status_code = 404
      end
    end

    ws "/*" do |socket, env|
      path = env.request.path[1..]
      path = unifyPath(path)

      if File.file?(path)
        # watch file and send appended lines in daemon
        watcherMgr.watch(path, socket)
      elsif File.directory?(path)
        socket.send "#{path} is a directory"
        socket.close
      else
        env.response.status_code = 404
      end

      socket.on_message do |message|
        if message == "ping"
          message = "pong"
        end
        socket.send message
      end

      socket.on_close do
        puts "Socket closed."
      end
    end

    Kemal.run port
  end
end
