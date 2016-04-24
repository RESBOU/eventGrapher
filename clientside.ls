# * Require
require! {
  leshdash: { mapValues, map, pick, each, assign, flattenDeep, flatten }
  bluebird: p
  'socket.io-client': io
  d3
  moment
  'color-hash'
}

colorHash = new colorHash()

parseDates = (data) ->
  map data, (event) ->
    assign {}, event, mapValues pick(event, 'start','end'), (value) -> new moment(value).toDate()

# * Draw
draw = (data) ->
  margin = top: 30, right: 20, bottom: 30, left: 50
  width = 600 - margin.left - margin.right
  height = 270 - margin.top - margin.bottom

  x = d3.time.scale()
    .range [0, width]
    
  y = d3.scale.linear()
    .range [height, 0]

  xAxis = d3.svg.axis().scale(x)
  .orient("bottom").ticks(5);

  yAxis = d3.svg.axis().scale(y)
  .orient("left").ticks(5);

  valueline = d3.svg.line()
    .x (d) -> x d.start
    .y (d) -> y d.layer
    
  svg = d3.select "body"
    .append("svg")
      .attr "width", width + margin.left + margin.right
      .attr "height", height + margin.top + margin.bottom
    .append("g")
      .attr "transform", "translate(" + margin.left + "," + margin.top + ")"

    x.domain [
      d3.min data, (.start)
      d3.max data, (.end) ]

    y.domain [ 0, 1 + d3.max data, (.layer) ]
    
#    svg.append "path"
#      .attr "class", "line"
#      .attr "d", valueline data

    svg.append "g"
      .attr "class", "x axis"
      .attr "transform", "translate(0," + height + ")"
      .call xAxis
      
#    svg.append "g"
#      .attr "class", "y axis"
#      .call yAxis

    window.y = y

    eventHeight = height / y.domain()[1] / 2
    
    eventBar = svg.selectAll(".bar")
      .data(data)
      .enter().append("g")


    eventBar
        .append("rect")
        .attr "class", "eventBar"
        .attr "fill", -> d3.rgb.apply d3, colorHash.rgb it.id
        .attr "x", -> x it.start
        .attr "width", -> x it.end
        .attr "y", -> y(it.layer) - eventHeight
        .attr "height", -> eventHeight


    eventBar
      .append "text"
      .attr "class", "eventBar"
      .attr "x", -> x it.start
      .attr "y", -> y(it.layer) - (eventHeight / 2 )
      .attr "dy", ".25em"
      .attr "dx", "1em"
      .text ->
        console.log String it.id
        it.id

# * Socket
socket = io window.location.host
socket.on 'connect', -> console.log 'connected'
socket.on 'update', -> if it is data.id then window.location.reload!
socket.on 'reconnect', -> window.location.reload!

# * Init
data.data
  |> parseDates
  |> draw 
