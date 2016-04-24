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
  height = Math.floor $('body').height() / 3
  width = $('.graph').width()
  
  console.log height
  svg = d3.select ".graph"
    .append("svg")
      .attr "width", width
      .attr "height", height
  
  x = d3.time.scale()
    .range [0, width]
    
  y = d3.scale.linear()
    .range [height, 0]

  valueline = d3.svg.line()
    .x (d) -> x d.start
    .y (d) -> y d.layer
    


#    x.domain [
#      d3.min data, -> it.start.clone().subtract(0.5 'days').toDate()
#     d3.max data, -> it.end.clone().add(0.5, 'days').toDate()
#    ]
    
    x.domain [
      d3.min data, -> it.start.toDate() 
      d3.max data, -> it.end.toDate()
    ]

    y.domain [ 0, 1 + d3.max data, (.layer) ]

    xAxis = d3.svg.axis().scale(x)
    .orient("bottom").ticks(5);

    svg.append "g"
      .attr "class", "x axis"
      .attr "transform", "translate(0," + (height + 10) + ")"
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
      .attr "x", -> x(it.start)
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
  $('.json').append json


# * Socket
socket = io window.location.host
socket.on 'connect', -> console.log 'connected'
socket.on 'update', -> if it is data.id then window.location.reload!
socket.on 'reconnect', -> window.location.reload!

data.data = parseDates (-> new moment it), data.data

data.data
  |> parseDates -> it.format('YYYY-mm-DD')
  |> drawText 

# * Init
$('body').ready -> 
  data.data
    |> draw 
