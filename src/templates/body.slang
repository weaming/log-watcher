body
  pre#terminal

javascript:
  const term = document.getElementById("terminal")
  console.log(term)
  let wsUrl = location.href.replace("http", "ws")
  let xs = wsUrl.split("/")
  xs.splice(3, 0, "ws")
  wsUrl = xs.join("/")

  const ws = new WebSocket(wsUrl);
  ws.onmessage = function (event) {
    console.log(event.data);
    if (term.innerHTML.length > 0) {
      term.innerHTML += "\\n" + event.data
    } else {
      term.innerHTML += event.data
    }
  }
  window.ws = ws
