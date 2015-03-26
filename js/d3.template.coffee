---
---

d3.selection.prototype.template = (template) ->
  ###
  d3.[selection].template extends a d3 selection by 
  iterating over an object that contains repeatable d3 
  code patterns.

  template adds data to the DOM and modifies selections.  It
  allows data to be attached to its presentation layers within the
  DOM.

  also, template handles requests inline.  when a request is complete.
  the last call state with continue to build teh template

  d3.selection.template modifies d3.selection.prototype.template and d3.requests
  ###
  
  build = ( s, t, state) ->
    if not state
      state = {}
    t.forEach (t) ->
      t = d3.entries(t)[0]
      if rules[t.key]
        s = rules[t.key]( s, t.value, state )
      else if t.key in ['selectAll','select']
          s = s[t.key] t.value
      else
        s = s[t.key] (d) ->
          reduce t.value, d, state
    s      
  
  rules = 
    domain: (s,t,state) ->
      #{update state}
      
      s
    text: (s,t,state) ->
      s.text (d,i) ->
        if Array.isArray(t)
          t.map (_d,i) ->
            reduce _d, d, state
          .join ''
        else
          reduce t, d, state
    js: (s,t) ->
      eval t
      s
    template: (s,t, state) ->
      build s, reduce( t, null, state )
    data: (s,t, state) ->
      #{ force data to be an array or convenience? }
      s.data (d) ->
        t = reduce t, d, state
        unless Array.isArray(t)
          t = d3.entries t
        t
    datum: (s,t, state) ->
      #{ force data to be an array or convenience? }
      s.datum (d) -> reduce t, d, state
    attr: (s,t, state) ->
      d3.entries t
        .forEach (t) ->
          unless t.value
            t.value = true
          s.attr t.key, (d) ->
            reduce t.value, d, state
      s
    style: (s,t, state) ->
      d3.entries t
        .forEach (t) ->
          unless t.value
            t.value = true
          s.style t.key, (d) ->
            reduce t.value, d, state
      s
    'class': (s,t, state) ->
      d3.entries t
        .forEach (t) ->
          unless t.value
            t.value = true
          s.classed t.key, (d) ->
            reduce t.value, d, state
      s
    enter: (s,t) ->
      s.enter()
    exit: (s,t) ->
      s.exit()
    remove: (s,t) ->
      s.remove()
    call: ( s, t, state) ->
      s.call (s) ->
        build s, t, state
    each: ( s, t, state) ->
      s.each (d, i) ->
        state['i'] = i
        build d3.select(@), t, state
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
    child: (s,t, state) -> rules.call(s,t, state)
    requests: (s,t, state)->
      if t['call']
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
                 console.log i,l,t.key,t.value
                 if i == l and template
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
            if i == l and template
              s = s.call (s) ->
                build s, template, state

      s      
  reduce = (path, d, state) ->
    if typeof path == 'string' and path[0] in ['@',':']
      if path in ['@']
        d
      else if path in ['@i']
        state.i
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