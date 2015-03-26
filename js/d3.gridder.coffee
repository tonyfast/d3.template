---
---
#{ create a button to explore nodes with datum}
d3.select 'body'
  .append 'div'
  .style 'width', 60
  .style 'height', 60
  .style 'position', 'fixed'
  .style 'right', 0
  .style 'top', 0
  .style 'background-color', 'green'
  .style 'z-index',100
  .text 'show data'
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
  
  #{ traverse children to find data}
  children = (s,d) ->
    n = [].slice.call(s.node().children)
    n.forEach (n) ->
      
      if d3.select(n).datum()
        d.push n.getBoundingClientRect()
      d = children d3.select(n), d
    d
  
  #{ get all nodes with data}
  d = []
  d3.select el
    .call (s) ->
      d = children s, []
  
  w = d3.max( d,(d) -> d['right'] )
  h = d3.max( d,(d) -> d['bottom'] )

  #{ create svg }
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
        .attr 'x', d['left']
        .attr 'y', d['top']
        .attr 'width', d['width']
        .attr 'height', d['height']
        .style 'fill', 'blue'
        .style 'stroke', 'black'
        .style 'stroke-width', 2
        .style 'opacity', '.1'