body
  div#terminal

javascript:
  const term = document.getElementById("terminal")
  console.log(term)
  const ws = new WebSocket(location.href.replace("http", "ws"));
  ws.onmessage = function (event) {
    console.log(event.data);
  }
  ws.send("hello")
  ws.send("ping")
