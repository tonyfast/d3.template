# ``d3.template`` in action

The ``gh-pages`` branch will demo ``d3.template``.  This ``readme.md`` is written 
in literate coffeescript and will be used to initialize the demo; all code blocks are executable by Coffeescript..

# Overview

This example will use create new rules and callbacks for ``d3.template`` then 
the template is built using simple d3js commands.

## Initialize some global variables

``d3.requests`` will store requests made using d3 xhr methods.  ``template`` is an
array of objects containing ``d3.template`` syntaxes.

      d3.requests = new Object
      template = new Array
      
## Making a Rule

``d3.template`` [rules](https://github.com/tonyfast/d3.template/blob/master/coffee/d3.template.litcoffee#initialize-the-rules-for-the-d3-core-api-selections) take in four arguments 

1. A parsed template object
2. A current d3 selection
3. The nearest parents data selection
4. Any custom rules or callbacks.
      
## Chain requests

> This could be done with [requirejs]() instead.
      
      makeRequest = (template,selection,data,opts)->
        ###
        baseurl is a special key that is prepended to all of the values
        the call key is executed after all of the requests successfully or with an error.
        template[key,value,callback]
        selection - d3 selection
        ###
        baseurl = (template) ->
          ### append baseurl to the requests source and remove the complete callback ###
          baseurl = template.baseurl ? ''
          temp = new Object
          d3.entries template
            .forEach (d)-> 
              unless d.key in ['baseurl','call']
                temp[d.key] = "#{baseurl}#{d.value}"
          temp
          
For each of the objects make a xhr request and default to json.  

This function will use the argument at the end of the key to identify the request method.

``foo.xml: http://api.xml`` is equivalent to d3.xml('http://api.xml', function )
``foo.text: http://api.whatever.com`` is equivalent to d3.text('http://api.whatever.com', function )
          
        iterate = (template,callback,complete)->
          current = d3.entries( template )
          key = current[0].key.split '.'
          method = 'json'
          if key.length > 1 then method = key[1]
          key = key[0]
          
          ### Make the Request ###
          d3[method] current[0].value, (d) ->
            
All the requests are stored in ``d3.requests`` with their respective keys.
            
            d3.requests[key] = d
            if current.length == 1 and complete
              selection.template complete, data, opts        
            else 
              delete template[current[0].key]
              iterate template, callback, complete
              
        iterate baseurl(template.value), template.callback, template.value.call
        selection
      
## Make Some New Rules

``d3.template`` has rules for every method in the core d3js API.  Any of these
  rules are overridden by custom rules.

      
      window['add-on'] = 
        rule: 
        
### rule 1: load stylesheets ###

          stylesheets: (t,s,d,o)->
            baseurl = t.value.baseurl ? ''
            head = d3.select 'head'
            d3.entries t.value
              .filter (d)-> d.key not in ['baseurl','call']
              .forEach (d)->
                head.append 'link'
                  .attr 'id',d.key
                  .attr 'href', "#{baseurl}#{d.value}"
                  .attr 'rel','stylesheet'
                  .attr 'type','text/css'
            s

### rule 2: make requests ###

          requests: makeRequest
  
### rule 3: get scripts ###

And do not break anything.

          scripts: (t,s,d,o)->
            temp = {}
            d3.entries t.value
              .forEach (_t) ->
                unless _t.key in ['baseurl','call']
                  temp["#{_t.key}.getScript"] = _t.value
                else
                  temp["#{_t.key}"] = _t.value
            t.value = temp
            makeRequest t,s,d,o
            
## Callbacks

Callbacks operate on the value of the ``d3.template`` key.
            
        callback: 
    
Convert text to markdown after concatenation of arrayed values    
    
          markdownify: (d)->marked(d)
    
Convert a block string into yaml    
    
          yaml: (d)->jsyaml.load(d)
    
Execute a blockstring of coffeescript
    
          coffeescript: (d)->CoffeeScript.run(d)
    
# Run it

Load a template and append it ``body``.

          
      d3.text 'templates/template-editor.yaml', (d)->
        template = jsyaml.load d
        d3.select 'body'
          .template template, null, window['add-on']