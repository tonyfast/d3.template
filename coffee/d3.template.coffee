d3.selection.prototype.template = (template, opts )->
  ###
  template - a nested array object
    ```yaml
    - key.filter: value
    ```yaml

    key - d3 and user-defined actions.
    filter - manipulates data
    value - Javascript object that complies with the action.

  opts - append filters, rules, and useful data.
  ###
  
  ### initialize document.__data__ and d3.template objects ###
  initTemplate()
  
  ### Append any custom operations ###
  __data__ = updateOpts opts
  
  ### split key and value from template if they exist. ###
  [key,template] = unless Array.isArray template
    [d3.keys( template )[0],d3.values( template )[0]]
  else 
    ### Array valued template - the template not stored on the document ###
    [null,template]
  
  ### Track current selection ###
  document.__data__.current = 
    selection: @
    template: template
    
  if key
    document.__data__.block[key] = {
      object: template
      __data__: __data__
    }
    
  ### convert actions to coffeescript ###
  coffee = templateToCoffee \
    template, ["selection=document.__data__.current.selection","data=selection.node().__data__","selection"], 1, -1
  
  document.__data__.block[key].coffee = if key then coffee    
  document.__data__.block[key].js = CoffeeScript.compile coffee, {bare:true}
  eval document.__data__.block[key].js
  document.__data__.block[key].html = document.__data__.current.selection.html()

### Convert to values instead of strings ###
objToString = (value, noQuote) ->  
  ### Transform rule object to coffeescript string prefix ###

  templateToValueString = (value) ->
    ### 
    split dot separated strings 
    @this.key1.key2.lastkey -- @['key1']['key2']['lastkey']
    ###
    if value
      value = value.split '.'
        .join "']['"
      "['#{value}']"
    else
      ""
  if value and typeof value in ['string']
    [stringvalue] = d3.entries document.__data__.prefix
      .filter (prefix) ->
        value.startsWith prefix.key
    if stringvalue
      ### Do not wrap is single quotes ###
      if stringvalue.key in ['$']
        "#{value}"
      else if stringvalue.key in ['@i']
        "#{stringvalue.value}"
      else if stringvalue.value
        "#{stringvalue.value}#{templateToValueString value.slice 1}"
      else
        ### wrap in single quotes ###
        "\"#{stringvalue.value}\""
    else if noQuote? and noQuote
      ### wrap in double quotes to activate string interpolation ###
      "#{value}"
    else 
      "\"#{value}\""
  else
    value
    
    
selectionCall = (template)->
  ### 
  The Call option 
  Can isolate data transforms and requests also it can great dom children
  ###
  """
  .call (selection)-> 
  \tdata=selection.node().__data__ ? null
  \tselection
  """

selectionEach = (template)->
  ### Iterates over an existing dom selection ###
  """
  .each (data,index)->
  \td3.select @
  """
mountDOM = (template)->
    ### 
    Short hand notaton: 
      $tagName.className1.className2.className3#anchor-id
    =>
      <tagName class="className1 className2 className3" id="anchor-id"></tagName>
    Make many changes to DOM insert new objects 

    * There is no reason for filter here.  Shit yes there is what is a class value changes.  col-sm-6
    ###
    output = []
    if template.value.startsWith '$'
      unless  '.' in template.value
        output.push ".#{template.key} #{template.filter}\"#{template.value.slice 1}\"" 
      else
        [tagName, classes...] = template.value.slice 1
          .split '.'
        len = classes.length-1
        if len > 0 and '#' in classes[len]
          [classes[len],id] = classes[len].split '#'
        if tagName?
          output.push ".#{template.key} #{template.filter}'#{tagName}'" 
        if classes?
          obj  = {}
          classes.forEach (d)-> obj[d] = if obj? then true else { d: true }
          output.push updateDOM 
            key: 'classed'
            filter: template.filter
            value: obj
        if id?
          output.push updateDOM 
            key: 'attr'
            filter: template.filter
            value: 
              id: id        
      output.join '\n'
    else
      ".#{template.key} #{template.value}"
      
updateData = (template)->
  if typeof template.value in ['object'] 
      d3.entries template.value
        .forEach (d)->
          template.value[d.key] = objToString d.value, true
      valueString = JSON.stringify template.value
  else 
    valueString = template.value
    
  if template.key in ['data']
    if typeof template.value in ['object'] and not Array.isArray template.value 
      ### Convert object to d3.entry ###
      valueString = JSON.stringify d3.entries template.value
      
  ".#{template.key} #{template.filter}#{valueString}"
  
updateSelection = (template)-> 
  ### selection ###
  ".#{template.key} #{template.filter}#{template.value ? null }"  
updateDOM = (template)->
  ### attr whatever ###
  classProcess = if template.key in ['classed'] then (d)->"#{d?}" else (d)->"#{d}"#
  d3.entries template.value 
    .forEach (value)->
      template.value[value.key] = objToString value.value, true
      if template.value[value.key] == value.value
        template.value[value.key] = "'#{template.value[value.key]}'"
        
  d3.entries template.value
    .map (d,i)->
      ".#{template.key} '#{d.key}', #{template.filter}#{classProcess d.value}"
    .join '\n'
    
nullSelection = (template)->
  ### enter, exit, transition, remove ###
  """
  .call (selection)->
  \tselection.#{template.key.split('-')[1]}()
  """
  
updateInner = (template) ->
  ### Update inner text  ###
  if Array.isArray template.value
    value = template.value.map (d)-> 
      _d = objToString d, true
      hasPre = d3.keys document.__data__.prefix
        .filter (prefix)->
          d.startsWith prefix
        .length
      if hasPre > 0
        _d = "\#\{#{_d}\}"
      _d
    .join ''
  else 
    value = template.value ? ''
  if template.key in ['html'] 
    """
    .#{template.key} #{template.filter} \"\"\"
    #{ value }
    \"\"\"
    """
  else 
    ".#{template.key} #{template.filter}#{value}"
  
cbToString = (template)->
  if template['filter'] and document.__data__.filter[template['filter']]? 
    "document.__data__.filter['#{template.filter}'] " 
  else 
    ""
  
initTemplate = (opts)->
  ### 
  Agnostic to template
  A template converts structured data to javascript and coffeescript 
  Init Template initializes the document data and sets the template settings

  * return __data__ to append to template object
  mixin and default take different arguments
  ###
    
  init = 
    include: {}
    current: {selection:null,template:null}
    block: {}
    filter: 
      echo: (d)-> console.log(d); d
      markdown: (d)-> marked d
      jade: (d)-> jade.render d
    template:
      call: selectionCall
      each: selectionEach
      insert: mountDOM 
      append: mountDOM
      data: updateData
      datum: updateData
      select: updateSelection
      selectAll: updateSelection
      attr: updateDOM
      property: updateDOM
      style: updateDOM
      classed: updateDOM
      'call-enter': nullSelection
      'call-exit': nullSelection
      'call-transition': nullSelection
      'call-remove': nullSelection
      text: updateInner
      html: updateInner      
    mixin:
      test: (selection, obj) -> console.log 'test rule echos: ', obj
      js: (selection, obj) -> eval obj.value
      request: (selection, obj, onComplete)->
        makeRequest = (req)->
          if req.length == 0 and onComplete
              onComplete()
          else
            [name, type] = req[0].key.split '.' 
            if document.__data__.include[name]
              selection.datum (d)->
                d ?= {}
                d[name] = document.__data__.include[name]
                d
              makeRequest req.slice 1
            else
              d3[type ? 'text'] req[0].value, (e,d)->
                document.__data__.include[name] = d

                selection.datum (d)->
                  d ?= {}; d[name] = document.__data__.include[name]
                  d
                makeRequest req.slice 1
        makeRequest d3.entries(obj).filter (d)-> not( d.key in ['call','baseurl'])
    prefix:
      '$': ""
      '@this': "@"
      '@i': "index"
      '@': "data"
      ':d3.templates': "document.__data__.block"
      ':': "window"
      '_': "document.__data__.current.template.__data__"
      '\\': ""

  document['__data__'] ?= {}
  d3.entries init
    .forEach (opt)->
      document['__data__'][opt.key] ?= {}
      document['__data__'][opt.key] = d3.extend document['__data__'][opt.key], opt.value

        
updateOpts = (opts)->
  if opts
    [__data__, opts ] = 
      [ opts.__data__ ? null, d3.entries(opts).filter (d)-> not(d['key'] in ['__data__']) ]
    if opts?
      opts.forEach (opt)->
          document.__data__[opt.key] = d3.extend document.__data__[opt.key], opt.value
    __data__
  
    
### mixins convert yaml syntaxes to coffeescript code ###
mixinToCoffee = (template)->
  ### Creates string representations of JS objects in coffee ###
  if document.__data__.template[template.key]
    ### default d3 actions ###
    document.__data__.template[template.key] template
  else if document.__data__.mixin[template.key]
    ###  write execution of custom mixin in coffeescrippt ###
    reserved = ['call','each']
    if typeof template.value  == 'string'
      val = template.value
    else
      val = {}
      d3.entries template.value 
        .filter (d)-> 
          if d.key in reserved
            false
          else
            true
        .forEach (d)-> val[d.key] = d.value
    ### Append more templates to selection on next pass ###      
    """
    .call (selection)->
    \tdocument.__data__.mixin['#{template.key}'] selection, #{JSON.stringify val}, ()=> 
    \t\tdata=selection.node().__data__ ? null
    \t\tselection
    """    
  else 
    """
    .call (selection)->
    \tconsole.log 'The is no rule #{template.key} defined'
    """
    
templateToCoffee = (template,output,level,index) ->
  ###
  level: hierarchy in object
  index: value of array loop (-1 : not Array)
  ###  

  if template
    indentBlockString = (indent,lines)->
      lines.split '\n'
        .map (line)-> "#{indent}#{line}"
        .join '\n'

  level = level + 1
  template.forEach (template)->
    [template] = d3.entries template
    [template['key'],template['filter']] = template['key'].split '.'

    ### classed is a dumb name ###
    if template['key'] in ['class'] then template['key'] = 'classed'

    ### Stringified version of filter in coffee###
    template['filter'] = cbToString template

    ### stringify value if necessary ###
    if template['key'] in d3.keys(document.__data__.template).filter((d)->d!='html')
      ### text and html can concatentate array elements as a special case ###
      template['value'] = objToString template['value']

    ### Coffeescript is whitespace aware and is lovely to read ###
    indent = d3.range(level).map (d)-> ''
      .join '\t'

    parsed = mixinToCoffee template

    output.push indentBlockString indent, parsed

    if template['key'][0..3] in ['call','each']
      ### Branching data and null selections ###
      output.push templateToCoffee template.value, [], level, index

    if template['key'] in d3.keys document.__data__.mixin
      ### mixins ###
      [onCompleteKey] = d3.keys template.value
        .filter (d)-> d in ['call','each']
      if template.value['call']? or template.value['each']?
        output.push templateToCoffee template.value[onCompleteKey], [], level+1, index

  output.join '\n'
  
### Append some d3 utilities ###

# Extend an object the keys in the first are overwritten ###
  
d3.extend = (obj1, obj2)->
  d3.entries obj2
    .forEach (d)->
      obj1[d.key] ?= d.value
  obj1

### similar to $.ready() ###
  
d3.getScript = (src, callback) ->
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