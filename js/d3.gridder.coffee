---
---
d3.select 'body'
  .append 'svg'
  .attr 'width', 60
  .attr 'height', 60
  .style 'position', 'fixed'
  .style 'right', 0
  .style 'top', 0
  .style 'background-color', 'green'
  .style 'z-index',100
  .style 'opacity', '.6'
  .on 'click', () ->
    d3.select @
      .datum (d) ->
        if d
          if d['active']
            d = 
              active: false
            d3.select('#overlay').remove()
          else
            d = 
              active: true
        else #{ initialize }
          d = 
            active: true
      .call (s)->
        console.log s.data()
        if s.datum()['active']
          d3.gridder 'body'
  
  

d3.gridder = ( el ) ->
  
  children = (s,d) ->
    n = [].slice.call(s.node().children)
    n.forEach (n) ->
      
      if d3.select(n).datum()
        d.push n.getBoundingClientRect()
      d = children d3.select(n), d
    d
  
  d = []
  d3.select el
    .call (s) ->
      d = children s, []
  
  w = d3.max( d,(d) -> d['right'] )
  h = d3.max( d,(d) -> d['top'] )
  
  x = d3.scale.linear()
    #{.domain [d3.min( d,(d) -> d['left'] ),w]}
    .domain [0,w]
    .range [0, w]
  y = d3.scale.linear()
    #{.domain [d3.min( d,(d) -> d['top'] ),h]}
    .domain [0,h]
    .range [0, h]

  overlay = d3.select 'body'
    .append 'svg'
    .attr 'id', 'overlay'
    .attr 'width', w
    .attr 'height', h
    .style 'position','absolute'
    .style 'top', 0
    .style 'left', 0
    .selectAll 'rect'
    .data d
    .enter()
    .append 'rect'
    .each (d,i)->
      d3.select @
        .attr 'x', x( d['left'] )
        .attr 'y', y( d['top'] )
        .attr 'width', x( d['width'] )
        .attr 'height', y( d['height'] )
        .style 'fill', 'blue'
        .style 'stroke', 'pink'
        .style 'opacity', '.1'