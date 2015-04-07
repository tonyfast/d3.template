---
---
d3.getScript = ( src, callback ) ->
  #{http://stackoverflow.com/questions/16839698/jquery-getscript-alternative-in-native-javascript}
  script = document.createElement 'script'
  #{script.async = 1}
  prior = document.getElementsByTagName('script')[0]
  prior.parentNode.insertBefore script, prior
  script.onload = script.onreadystatechange = ( _, isAbort ) ->
    if isAbort or not script.readyState or /loaded|complete/.test script.readyState
      script.onload = script.onreadystatechange = null
      script = undefined

      unless isAbort
        if callback 
          callback()
  script.src = src  
  
d3.selection.prototype.template = (template, callback,i) ->
  ### 
  template an array of objects.
  rules trigger d3 events and callback 
  ###
  rule = (s,t) ->
    if config[t.k]
      s = config[t.k] s, t  
    else
      if t.k in ['selectAll','select','data','datum','template']
        s = s[t.k] t.f t.v
      else if t.k in ['call']
        s = s.call (s) ->
          s.template t.v
      else if t.k in ['each']
        s = s.each (d,i) ->
          d3.select @
            .template t.v,null,i
      else if t.k in ['append','insert']
        s = AppendDOM s, t
      else if t.k in ['attr','class','style','property','classed']
        #{ property access HTML5 properties }
        s = ChangeStateDOM s, t
      else if t.k in ['text','html']
        ChangeInner s,t
      else if t.k in ['enter','exit','remove']
        s = s[t.k]()
    s   
  addBaseurl = (t) ->
    unless t.v['baseurl']
      t.v['baseurl'] = ''
    d3.entries t.v
      .filter (d) -> unless d.key in ['baseurl','call'] then true else false
      .map (d) ->
        d.value = t.v['baseurl'] + d.value
        d
  config = 
      child: (s,t) ->
        #{ alternate name for call}
        t.k = 'call'
        rule s, t
      body: (s,t) ->
        #{ alternate name for call}
        d3.select document
          .select 'body'
          .template t.v
      parent: (s,t) ->
        d3.select s.node().parentElement
          .template t.v
      requests: (s,t) ->
        unless d3['requests']
          d3['requests'] = {}
        s.call (s) ->
          getRequest s, t, addBaseurl t
      scripts: (s,t) ->
        s.call (s) ->
          getRequest s, t, 
            addBaseurl t
              .map (d)-> 
                d.key += '.getScript'
                d
      stylesheets: (s,t) ->
        h = d3.select 'head'
        addBaseurl t 
          .forEach (d) ->
            unless h.select('#'+d.key).node() and h.select('#'+d.key).attr('id')
              h.append 'link'
                .attr 'id', d.key
                .attr 'type', 'text/css'
                .attr 'rel','stylesheet'
                .attr 'href', d.value
                .call (s) -> MarkupSelection s
        
        h.selectAll 'link.d3-template'
          .each (d) ->
            _s = d3.select @
            if _s.attr('id') in d3.keys t.v
              _s.attr 'disabled', null
            else
              _s.attr 'disabled', null
        s
      callbacks: (s,t) ->
        unless d3['callbacks'] 
          d3['callbacks'] = {}
          
        d3.entries t.v
          .forEach (d)->
            nm = d.key.split('.')[0]
            f = d.key.split('.')[1]
            d3['callbacks'][nm] = d3.scale[f]()
            d3.entries d.value
              .forEach (d) ->
                if Array.isArray d.value
                  d.value = d.value.map (d) -> 
                    parseValue s, {value:d}
                d3['callbacks'][nm][d.key] d.value
        s
                  
          
      js: (s,t) ->
        #{ need this to trigger jquery libraries}
        eval t.v
        s
  reduceKey = (k,v) ->
    ###
    k is array
    dont let this break
    ###
    k.slice 1
     .split '.'
     .reduce (p,n) ->
        if p[n]
          p[n]
        else 
          p
      , v
      
  ChangeInner = (s,t) ->
    #{ Changes text and html }
    #{ Concatenates individual array elements}
    t.v = JoinArray s, t.v, ' '
    s[t.k] t.f t.v

    
  AppendDOM = (s, t) ->
    if t.v[0] == '$'
      id = t.v
        .split '#'
      tag = id[0]
        .slice 1 #{remove dollar sign}
        .split '.'
      id = id[1]
      classed = tag.slice(1)
      tag = tag[0]
    else 
      tag = t.v
    if tag.length > 0
      s = s[t.k] tag
    if classed
      classed.forEach (d)->
          s['classed'] d, true
    if id
      s['attr'] 'id', id
    s

  getRequest = (s,t,a) ->
    iterate = (a) ->
      if t.k in ['requests']
        d3['requests'][nm] = d3['requests'][a[0].value]
      if a.length == 1  
        if t.v['call'] then s.template t.v['call'] else #{done}
      else
        getRequest s,t,a.slice(1)

    type = 'json'
    if a[0].key.split('.')[1]
      type = a[0].key.split('.')[1]
      
    nm = a[0].key.split('.')[0]

    if t.k in ['scripts'] 
      d3[type] a[0].value, -> iterate a
    else if t.k in ['requests'] and not d3['requests'][a[0].value]
      d3[type] a[0].value, (d) ->
          d3['requests'][a[0].value] = t.f d
          iterate a            
    else
      iterate a

        
  ChangeStateDOM = (s,t) ->
    f = (d) -> d
    if t.k.startsWith 'class' 
      t.k = 'classed'
      f = (d) ->
        if d == null 
          true 
        else 
          d
    d3.entries t.v
      .forEach (d)->
        d.value = parseValue s, { value: d.value }
        s[t.k] d.key, t.f f d.value
    s
  builder = (s,t) ->
    #{ each time a template is executed name the selection with the template }
    MarkupSelection s
    t.forEach (t) ->
      #{ on the selection execute a element in the template}
      s = Execute s, t 
  MarkupSelection = (s) ->
    #{ add feedback on d3 template histories }
    s.classed 'd3-template', true
  parseArgs = (s, t) ->
    #{ parse template key and value}
    t = 
      k: d3.keys( t )[0].split('.')[0]
      f: parseCallback s, t 
      v: parseValue s, t 
  
  parseCallback = (s,t) ->
    #{ get callback }
    #{ list of callbacks in config with function }
    t = d3.keys(t)[0].split('.')
    if t[1]
      d3['callbacks'][t[1]]
    else 
      (d) -> d
      
  parseValue = (s, t ) ->
    #{ parse template value}
    t = d3.values(t)[0]
    if typeof t == 'string'
      if t.slice(0,5) == '@this'
        t = t[0] + t.slice(5)
        t = reduceKey t, s.node()
      else if t.slice(0,2) == '@i'
        t = i
      else if t[0] == '@'
        t = reduceKey t, s.datum()
      else if t[0] == ':'
        t = reduceKey t, window
      else if t[0] == '\\'
        t = t.slice(1)
    else 
      t
    t
    
  JoinArray = (s,v,c) ->
    if Array.isArray v
      v = v.map (d) ->
        parseValue s, {value:d}
      .join c
    else 
      v
      
  Execute = (s,t) ->
    t = parseArgs s, t
    rule s, t
  
  
  unless callback
    callback = (d) -> d
  
  d3.entries template
    .forEach (d) ->
      unless d3['templates'] 
        d3['templates'] = {}
      d3.templates[d.key] = d.value
      
  builder @, callback template