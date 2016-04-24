# * Require
require! {
  leshdash: { mapValues, map, pick, each, assign, flattenDeep, flatten }
  bluebird: p
  'socket.io-client': io
  d3
  moment
  'color-hash'
  'zepto-browserify': { $ }
  './jsonPrint'
}

colorHash = new colorHash()

parseDates = (parser, data) -->
  map data, (event) ->
    assign {}, event, mapValues pick(event, 'start','end'), parser

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


#    x.domain [
#      d3.min data, -> it.start.clone().subtract(0.5 'days').toDate()
#     d3.max data, -> it.end.clone().add(0.5, 'days').toDate()
#    ]
    
    x.domain [
      d3.min data, -> it.start.toDate() 
      d3.max data, -> it.end.toDate()
    ]

    y.domain [ 0, 1 + d3.max data, (.layer) ]

    svg.append "g"
      .attr "class", "x axis"
      .attr "transform", "translate(0," + height + ")"
      .call xAxis
      
    eventHeight = height / y.domain()[1] / 2
    
    zoom = d3.behavior.zoom();
    eventBar = svg.selectAll(".bar")
      .data(data)
      .enter().append("g")
      .call(zoom)

    eventBar
        .append("rect")
        .attr "class", "eventBar"
        .attr "fill", -> d3.rgb.apply d3, colorHash.rgb it.id
        .attr "x", -> x it.start
        .attr "width", -> x(it.end) - x(it.start)
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

# * Text
drawText = (data) ->
  console.log $
  json = $ '<pre class="json"></pre>'
  json.html jsonPrint.prettyPrint data
  $('body').append json

drawTitle = (data) ->
  $('body').prepend "<div class='title'>#{data.id}</div>"


# * Socket
socket = io window.location.host
socket.on 'connect', -> console.log 'connected'
socket.on 'update', -> if it is data.id then window.location.reload!
socket.on 'reconnect', -> window.location.reload!

data.data = parseDates (-> new moment it), data.data

# * Init
data.data
  |> draw 

data.data
  |> parseDates -> it.format('YYYY-mm-DD')
  |> drawText 


data
  |> drawTitle
