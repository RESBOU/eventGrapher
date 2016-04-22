require! {
  leshdash: { mapValues, each, assign }
  bluebird: p
  'socket.io-client': io
}

socket = io window.location.host
socket.on 'connect', ->
  console.log 'connected'
socket.on 'update', -> if it is data.id then window.location.reload!
socket.on 'reconnect', -> window.location.reload!

console.log window.data
