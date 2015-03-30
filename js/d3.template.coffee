---
---

d3.selection.prototype.template = (template, callback) ->
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
      args = t.key.split('.')
      if args.length > 1 and d3['scales'] and d3['scales'][ args.slice(-1)[0] ]
        state.callback = d3['scales'][ args.slice(-1)[0] ]
        t.key = args.slice(0,-1).join('')
      else
        state.callback = (d) -> d
      if rules[t.key]
        s = rules[t.key]( s, t.value, state )
      else if t.key in ['selectAll','select']
          s = s[t.key] t.value
      else
        s = s[t.key] (d) ->
          reduce t.value, d, state, s
    s      
  
  rules = 
    scales: (s,t,state) ->
      d = s.data()
      d3.entries t
        .forEach (t) ->
          if not d3['scales']
            d3['scales'] = {}
          else if typeof t.value == 'object'
            if not d3['scales'][t.key]
              d3['scales'][t.key] = d3.scale.linear()
            d3.entries t.value
              .forEach (_t) ->
                if Array.isArray( _t.value )
                  temp = []
                  _t.value.forEach (_t) ->
                    temp.push reduce( _t, d, state, s)
                  t.value = temp
                else 
                  t.value = d3.extent d, (_d,i) ->
                    state.i = i
                    v = reduce( _t.value, _d, state, s)
                    if v and v['trim']
                      v = parseFloat v.trim()
                    v
                d3['scales'][t.key][_t.key] reduce( t.value, d, state, s)
          else
            d3['scales'][t.key] = reduce  t.value, d, state, s
      s   
    text: (s,t,state) ->
      s.text (d,i) ->
        if Array.isArray(t)
          t.map (_d,i) ->
            reduce _d, d, state, s
          .join ''
        else
          reduce t, d, state, s
    js: (s,t) ->
      eval t
      s
    template: (s,t, state) ->
      build s, reduce( t, null, state, s )
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
            reduce t.value, d, state, s
      s
    style: (s,t, state) ->
      d3.entries t
        .forEach (t) ->
          unless t.value
            t.value = true
          s.style t.key, (d) ->
            reduce t.value, d, state, s
      s
    'class': (s,t, state) ->
      d3.entries t
        .forEach (t) ->
          unless t.value
            t.value = true
          s.classed t.key, (d) ->
            reduce t.value, d, state, s
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
  reduce = (path, d, state, s) ->
    if typeof path == 'string' and path[0] in ['@',':']
      if path in ['@']
        d
      else if path in ['@i']
        d = state.i
      else
        if path[0] == ':'
          d = window
        else if path.slice(0,5) == '@this'
          d = s.node()
          path = ['@',path.slice(6)].join ''
        d = path.slice 1
            .split '.'
            .reduce (p,k)->
                p[k]
            , d 
    else
      #{path has data}
      d = path
    if typeof d == 'function' and typeof d() == 'function'
      d = d()
    #{ apply scales}
    state.callback d 
    
  unless callback
    callback = (x)->x
  d3.entries template
    .forEach (d) ->
      unless d3['templates']
        d3['templates'] = {}
      d3.templates[d.key] = d.value
  build @, callback( template )
  