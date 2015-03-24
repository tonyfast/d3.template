---
---

d3.selection.prototype.template = (template) ->
  
  build = ( s, t) ->
    t.forEach (t) ->
      t = d3.entries(t)[0]
      if rules[t.key]
        s = rules[t.key]( s, t.value)
      else if t.key in ['selectAll','select']
          s = s[t.key] t.value
      else
        s = s[t.key] (d) ->
          reduce t.value, d 
    s      
  
  rules = 
    template: (s,t) ->
      build s, reduce( t, null )
    data: (s,t) ->
      #{ force data to be an array or convenience? }
      s.data (d) ->
        t = reduce t, d 
        unless Array.isArray(t)
          t = d3.entries t
        t
    attr: (s,t) ->
      d3.entries t
        .forEach (t) ->
          unless t.value
            t.value = true
          s.attr t.key, (d) ->
            reduce t.value, d
      s
    'class': (s,t) ->
      d3.entries t
        .forEach (t) ->
          unless t.value
            t.value = true
          s.classed t.key, (d) ->
            reduce t.value, d
      s
    enter: (s,t) ->
      s.enter()
    exit: (s,t) ->
      s.exit()
    remove: (s,t) ->
      s.remove()
    call: ( s, t) ->
      s.call (s) ->
        build s, t
    each: ( s, t) ->
      s.each (d) ->
        build d3.select(@), t
    append: (s,t) ->
        id = null
        tag = null
        classes = null
        if t.startsWith('$')
          t = t.slice 1
            .split '#'
          if t[1]
            id = t[1]
          t = t[0].split '.'
          if t[0]
            tag = t[0]
          classes = t.slice 1
          if tag
            s = s.append tag
          if classes
            classes.forEach (c) ->
              s.classed c, true
          if id
            s.attr 'id', id
        else
          s = s.append t
        s
    child: (s,t) -> rules.call(s,t)
    requests: (s,t)->
      template = t['call']
      delete t['call']
      t = d3.entries t
      unless d3['requests']
        d3.requests = {}
      l = t.length - 1
      
      
      t.forEach (t,i)->
          t.key = t.key.split('.')
          type = 'text'
          if t.key[1]
            type = t.key[1]
            t.key = t.key[0]
            
            
          unless d3['requests'][t.value]
            get = (type, callback, complete)->
              d3[type] t.value
              .get (e,d) ->
                 d3['requests'][t.value] = callback(d)
                 d3['requests'][t.key] = d3['requests'][t.value] 
                 if i == l 
                    s = s.call (s) ->
                      build s, template
              s
            f = (d) -> d
            if type in ['json','xml','csv','tsv','html','text']
            else if type in ['yaml','yml']
              type = 'text'
              f = (d) -> 
                jsyaml.load d 
            s = get type, f
          else 
            d3['requests'][t.key] = d3['requests'][t.value] 
      s      
  reduce = (path, d) ->
    if typeof path == 'string' and path[0] in ['@',':']
      if path in ['@']
        d
      else
        if path[0] == ':'
          d = window
        path.slice 1
            .split '.'
            .reduce (p,k)->
              p[k]
            , d 
    else
      #{path has data}
      path
    
  build @, template