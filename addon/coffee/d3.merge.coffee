merge = (data...) ->
  ###
  Merge objects using native d3.
  ###
  out = {}
  data.forEach (d) ->
    d3.entries d
      .forEach (d)->
        out[d.key] = d.value
  out
