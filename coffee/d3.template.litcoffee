Create reusable designed patterns from structured data to created structured HTML, Style, and interaction

    d3.selection.prototype.template = ( template, data, opts ) ->
      ###
      Convert a structured javascript object into executable d3 commands
      data - optional data
      opts - optional rules and callbacks
      ###

For each element in the d3 selection

* Inherit inherit the bound data and selection index
* Create a new d3.template class for the current selection, data, and opts.
    
    
      @.each (d,i) ->
        opts ?= new Object
        data ?= new Object
        
The current state of the dom-node        
        
        data.state ?= d
        data.index ?= i

Define a class to manage the templates, selections, data, and options

        new templater template, d3.select(@), data, opts
    
``template`` creates a reactive state for d3 elements and data.
      
    class templater
      constructor: ( template, @selection, @data, @opts ) ->
        ###
        @opts - Javascript objects loaded into a template
          callback - callback functions registered with d3.template
        ###
        @init()
        
``template`` is an array of objects that use a simple syntaxes to generate
a ``key``, ``value``, and ``callback``
        
        template.forEach (_template) =>
          ###
          For each element in the template parse the d3.template syntax
          create key, value, callback for @template
          Use the current template to execute the commands
          return the selection
          ###
          @template = @parseArgs _template
          @build()
        @selection

      update: (obj, opts) ->  
        ###
        Update keys for the state, rules, data
        ###
        d3.entries opts
          .forEach (d)->
            obj[d.key] = d.value      

      config: (opts)->
        ###
        Used to create custom and standard rules and callbacks
        ###
        d3.entries opts
          .forEach (opts) ->
            @update @opts[opts.key]?= new Object, opts.value

      build: ()->
        ###
        Implement a rule for the current state, selection, data, opts
        ###
        if @opts.rule[@opts.state.key]?
          if @opts.state.key in ['text','html']
            c = ' '
            if Array.isArray @template.value
              @template.value = @template.value.map (d) =>
                @parseValue {value:d}
              .join c          
            
          @selection = @opts.rule[@opts.state.key] @opts.state, @selection, @data, @opts

      init: ->
        ###
        Initialize the state of the template.
        ###
        
        @update @opts.state ?= new Object,
          ###
          key - existing rule
          value - value for the rule to execute
          callback - a callback function to apply to the value before it is created.
          ###
          key: null
          value: null
          callback: (d) -> d
          
Create a rules for all of the [d3 selection API](https://github.com/mbostock/d3/wiki/Selections).
          
        @update @opts['rule'] ?= new Object,
          selectAll: updateSelection
          select: updateSelection
          template: updateSelection
          datum: updateSelection

Add a convenience function to turn objects into arrays
d3.entries creates key and value objects for each record in the object
To avoid this behavior use datum.

          data: (template,selection)-> 
            if typeof template.value is 'object' and not Array.isArray template.value
              template.value = d3.entries template.value
            updateSelection selection, template

``call`` and ``each`` recurse into d3.template after some housekeeping

          call: (template,selection,data,opts)->
            selection['call'] (selection)=>
              selection['template'] template.value, data, opts
          each: (template,selection,data,opts)->
            selection.each (d,i) ->
              [data.state, data.index] = [ d, i]
              d3.select @
                .template template.value, data, opts
                
          insert: createNode
          append: createNode
          enter: nullSelection
          exit: nullSelection  
          remove: nullSelection
          transition: nullSelection
          text: updateSelection
          html: updateSelection
          style: updateNode
          attr: updateNode
          property: updateNode
          'class': updateNode
          classed: updateNode
          on: (template,selection,data,opts)-> 
            events = ['click']
            events.forEach (d)->
              selection.on d, ()->
                d3.select @
                  .template template.value[d], data, opts
            selection
            
I overzealously used child in past templates and I forcing this rule.          
        
        @opts.rule.child = @opts.rule.call
        
This isn't part of d3, but it's useful.            
            
          js: (template,selection)->
            eval template.value
            selection
        
      updateSelection =  (template, selection) ->
        ###
        selection.method( callback( value ) )
        ###
        if template.key in ['scripts']
          debugger
        selection[template.key] template.callback template.value


## d3.template syntaxes

#\## dollar sign notation

Create ``tag`` with ``class1`` and ``class2`` along with an id ``anchor``

<code class="yaml">
# Create a new tag
- append: $tag.class1.class2#anchor

# or append classes and id to existing tag by appending to the same selecti
- append: tag
- append: $.class1.class2
- append: $#anchor
</code>


      createNode = (template, selection) ->
        if template.value[0] == '$'
          id = template.value
            .split '#'
          tag = id[0][1..].split '.' #{remove dollar sign}
          id = id[1]
          classed = tag[1..]
          tag = tag[0]
        else
          tag = template.value
        if tag.length
          selection = selection[template.key] tag
        if classed
          classed.forEach (d)->
            selection.classed d, true
        if id
          selection.attr id: id
        selection

      nullSelection = (template,selection) ->
        ###
        selection.key()
        ###
        selection[template.key]()

      updateNode = (template, selection) ->
        ###
        iterate over objects to defined multiple classes and attributes at once
        ###
        f = (d) -> d
        if template.key.startsWith 'class'
          template.key = 'classed'
          ### If the value is null then assume the class is true ###
          f = (d) -> if d == null then true else d
        d3.entries template.value
          .forEach (d)->
            selection[template.key] d.key, template.callback f d.value
        selection    
        
      parseArgs: (template) ->
        ### 
        Convert key and value to the key, value, and callback
        key.callback: {[value]}
        ###
        @opts.state =
          key: d3.keys( template )[0].split('.')[0]
          callback: @parseCallback template
          value: @parseValue template

      parseCallback: (template) ->
        ###
        get callback 
        list of callbacks in config with function 
        ###
        t = d3.keys(template)[0].split('.')
        if t[1] then @opts.callback[t[1]] else (d) -> d

      parseValue: (template) ->
        ###
        parse template value
        ###
        t = d3.values(template)[0]
        if typeof t == 'string'
          if t[..5] == '@this'
            t = t[0] + t[5..]
            t = reduceKey t, @selection.node()
          else if t[..2] == '@i'
            t = @data.index
          else if t[0] == '@'
            t = reduceKey t, @data.state
          else if t[0] == ':'
            t = reduceKey t, window
          else if t[0] == '\\'
            t = t[1..]
        else
          t
        t    

      reduceKey = (k, v) ->
        ###
        Recurse through an object and return the value
        ###
        k[1..]
         .split '.'
         .reduce (p, n) ->
            if p[n] then p[n] else p
          , v
