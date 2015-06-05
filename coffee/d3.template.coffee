d3.selection.prototype.template = (template, opts )->
  ###
  template - a nested array object
    ```yaml
    - key.callback: value
    ```yaml

    key - d3 and user-defined actions.
    callback - manipulates data
    value - Javascript object that complies with the action.

  opts - append callbacks, rules, and useful data.
  ###
  
  ### initialize document.__data__ and d3.template objects ###
  initTemplate()
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
  
  ### store the template as json, coffee, javascript ###
  
  if key
    document.__data__.template[key] = {
      object: template
      __data__: __data__
    }
    
  ### convert actions to coffeescript ###
  coffee = templateToCoffee template,
    ["selection=document.__data__.current.selection","data=selection.datum()","selection"], 
    1, -1
  console.log coffee
  document.__data__.template[key].coffee = if key then coffee    
  document.__data__.template[key].js = CoffeeScript.compile coffee, {bare:true}
  eval document.__data__.template[key].js

### Convert to values instead of strings ###
objToString = (value) ->  
  ### Transform rule object to coffeescript string prefix ###
  prefix = 
    '$': ""
    '@this': "@"
    '@i': "index"
    '@': "data"
    ':': "window"
    '_': "document.__data__.current.template.__data__"
    '\\': ""

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
    [stringvalue] = d3.entries prefix
      .filter (prefix) ->
        value.startsWith prefix.key
    if stringvalue
      ### Do not wrap is single quotes ###
      if stringvalue.key in ['$']
        "#{value}"
      else if stringvalue.value
        "#{stringvalue.value}#{templateToValueString value.slice 1}"
      else
        ### wrap in single quotes ###
        "\"#{stringvalue.value}\""
    else
      ### wrap in double quotes to activate string interpolation ###
      "\"#{value}\""
  else
    value
    
    
selectionCall = (template)->
  ### 
  The Call option 
  Can isolate data transforms and requests also it can great dom children
  ###
  """
  .#{template.key} (selection)->
  \tconsole.log 's', selection
  \tdata=selection.datum() ? null
  \tselection
  """

selectionEach = (template)->
  ### Iterates over an existing dom selection ###
  """
  .#{template.key} (data,index)->
  \td3.select @
  """
mountDOM = (template)->
    ### 
    Short hand notaton: 
      $tagName.className1.className2.className3#anchor-id
    =>
      <tagName class="className1 className2 className3" id="anchor-id"></tagName>
    Make many changes to DOM insert new objects 

    * There is no reason for callback here.  Shit yes there is what is a class value changes.  col-sm-6
    ###
    output = []
    if template.value.startsWith '$'
      unless  '.' in template.value
        output.push ".#{template.key} #{cbToString template}\"#{template.value.slice 1}\"" 
      else
        [tagName, classes...] = template.value.slice 1
          .split '.'
        len = classes.length-1
        if len > 0 and '#' in classes[len]
          [classes[len],id] = classes[len].split '#'
        if tagName?
          output.push ".#{template.key} #{cbToString template}'#{tagName}'" 
        if classes?
          obj  = {}
          classes.forEach (d)-> obj[d] = if obj? then true else { d: true }
          output.push updateDOM 
            key: 'classed'
            callback: template.callback
            value: obj
        if id?
          output.push updateDOM 
            key: 'attr'
            callback: template.callback
            value: 
              id: id        
      output.join '\n'
    else
      ".#{template.key} #{template.value}"
      
updateData = (template)->
  if typeof template.value in ['object'] 
      d3.entries template.value
        .forEach (d)->
          template.value[d.key] = objToString d.value
      valueString = JSON.stringify template.value
  else 
    valueString = template.value
  if template.key in ['data']
    if typeof template.value in ['object'] and not Array.isArray template.value 
      ### Convert object to d3.entry ###
      template.value = d3.entries template.value
      
  ".#{template.key} #{cbToString template}#{valueString}"
  
updateSelection = (template)-> 
  ### selection ###
  ".#{template.key} #{cbToString template}#{template.value ? null }"  
updateDOM = (template)->
  ### attr whatever ###
  classProcess = if template.key in ['classed'] then (d)->"#{d?}" else (d)->"'#{d}'"#
  d3.entries template.value
    .map (d,i)->
      ".#{template.key} '#{d.key}', #{cbToString template}#{classProcess d.value}"
    .join '\n'
    
nullSelection = (template)->
  ### enter, exit, transition, remove ###
  """
  .call (selection)->
  \tselection.#{template.key}()
  """
  
updateInner = (template) ->
  ### Update inner text  ###
  if Array.isArray template.value
    template.value = template.value.map (d)-> objToString d
      .join ' '
  ".#{template.key} #{cbToString template}#{template.value ? '' }"
  
cbToString = (template)->
  if template['callback'] and document.__data__.callback[template['callback']]? 
    "document.__data__.callback['#{template.callback}'] " 
  else 
    ""
  
initTemplate = (opts)->
  ### 
  Agnostic to template
  A template converts structured data to javascript and coffeescript 
  Init Template initializes the document data and sets the template settings

  * return __data__ to append to template object
  method and default take different arguments
  ###
  if not document['__data__']
    ### d3 initialize ``document.__data__``  ###
    d3.select(document).datum (d)-> d ? {}  
    
    document.__data__ = 
      request: {}
      current: {selection:null,template:null}
      template: {}
      callback: 
        'echo': (d)-> console.log(d); d
      default:
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
        'call.enter': nullSelection
        'call.exit': nullSelection
        'call.transition': nullSelection
        'call.remove': nullSelection
        text: updateInner
        html: updateInner
      method:
        test: (selection, obj) -> console.log 'test rule echos: ', obj
        js: (selection, obj) -> eval obj.value
        request: (selection, obj, onComplete)->
          makeRequest = (req)->
            if req.length == 0 and onComplete
                onComplete()
            else
              [name, type] = req[0].key.split '.' 
              if document.__data__.request[name]
                selection.datum (d)->
                  d ?= {}; d[name] = document.__data__.request[name]
                  d
                makeRequest req.slice 1
              else
                d3[type ? 'text'] req[0].value, (e,d)->
                  document.__data__.request[name] = d
                  
                  selection.datum (d)->
                    d ?= {}; d[name] = document.__data__.request[name]
                    d
                  makeRequest req.slice 1
          makeRequest d3.entries(obj).filter (d)-> not( d.key in ['call','baseurl'])


        
updateOpts = (opts)->
  if opts
    [__data__, opts ] = 
      [ opts.__data__ ? null, d3.entries(opts).filter (d)-> not d['key'] in ['__data__']]
    d3.entries document.__data__
      .forEach (d)->
        if opts[d.key]
          document.__data__[d.key] = d3.merge opts[d.key], d.value
        else 
          document.__data__[d.key] = d.value
          
  __data__ ? null
  
    
### methods convert yaml syntaxes to coffeescript code ###
methodToCoffee = (template)->
  ### Creates string representations of JS objects in coffee ###
  if document.__data__.default[template.key]
    ### default d3 actions ###
    document.__data__.default[template.key] template
  else if document.__data__.method[template.key]
    ###  write execution of custom method in coffeescrippt ###
    reserved = ['call','each']
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
    \tdocument.__data__.method['#{template.key}'] selection, #{JSON.stringify val}, ()-> selection\\
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
  indentBlockString = (indent,lines)->
    lines.split '\n'
      .map (line)-> "#{indent}#{line}"
      .join '\n'
      
  level = level + 1
  template.forEach (template)->
    [template] = d3.entries template
    [template['key'],template['callback']] = template['key'].split '.'
    
    ### classed is a dumb name ###
    if template['key'] in ['class'] then template['key'] = 'classed'
    
    ### Stringified version of callback in coffee###
    template['callback'] = cbToString template
    
    ### stringify value if necessary ###
    if template['key'] in d3.keys document.__data__.default
      ### text and html can concatentate array elements as a special case ###
      template['value'] = objToString template['value']
    
    ### Coffeescript is whitespace aware and is lovely to read ###
    indent = d3.range(level).map (d)-> ''
      .join '\t'
    
    parsed = methodToCoffee template
    
    output.push indentBlockString indent, parsed
    
    if template['key'][0..3] in ['call','each']
      ### Branching data and null selections ###
      output.push templateToCoffee template.value, [], level, index

    if template['key'] in d3.keys document.__data__.method
      ### Methods ###
      [onCompleteKey] = d3.keys template.value
        .filter (d)-> d in ['call','each']
      onComplete = {}
      onComplete[onCompleteKey] = template.value[onCompleteKey]
      if template.value['call']? or template.value['each']?
        output.push templateToCoffee [onComplete], [], level+1, index
        

  output.join '\n'
  
      
d3.extend = (obj1, obj2)->
  d3.entries obj2 
    .forEach (d)->
      obj1[d.key] ?= d.value
  obj1