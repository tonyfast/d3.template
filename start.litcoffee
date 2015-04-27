# Assign some global variables to be backwards compatible

      d3.requests = new Object
      template = new Array
      

# Iterate over a d3.template of requests
      
      makeRequest = (template,selection,data,opts)->
        ###
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
          
        iterate = (template,callback,complete)->
          current = d3.entries( template )
          key = current[0].key.split '.'
          method = 'json'
          if key.length > 1 then method = key[1]
          key = key[0]

Make request using d3 xhr methods

          d3[method] current[0].value, (d) ->
            d3.requests[key] = d
            if current.length == 1 and complete
              selection.template complete, data, opts        
            else 
              delete template[current[0].key]
              iterate template, callback, complete
              
        iterate baseurl(template.value), template.callback, template.value.call
        selection
      

# New rules and callbacks
      
      window['add-on'] = 
        rule: 
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
          requests: makeRequest
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
        callback: 
          markdownify: (d)->marked(d)
          yaml: (d)->jsyaml.load(d)
          
      d3.text 'templates/template-editor.yaml', (d)->
        template = jsyaml.load d
        d3.select 'body'
          .template template, null, window['add-on']