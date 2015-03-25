---
layout: index
---

# d3.template

``d3.template`` is an extension to the d3.selection prototype.  

# Usage

## Sample Template

    body:
    - append: div
    - attr: 
        class: foo
        id: ID
    # child of div
    - call:
      - append: h3
      - text: Bar

## Brief Append

``$`` operator

    body:
    - append: $div.foo#ID
    - call:
      - append: $h3
      - text: Bar
    

## Apply template to a selection

    templates = jsyaml.load(  d3.select('#manifest').html() )

    d3.select('body')
      .template( templates['body'] )

### Resulting HTML 
    

    <div class="foo" id="ID">
      <h3>
        Bar
      </h3>
    </div>
    
# Datum :: 

``datum`` binds and javascript object or value to a dom node and is available in the local scope.

    list:
    - append: $div.row
    - call:
      - append: $ul
      - datum: 
          bar: [baz, boom, bang]
      - selectAll: 'li'
      - data: '@bar'
      - call:
        - enter: 
        - append: li 
        - text: '@'
    
# Data :: Arrays

    body:
    - append: $div.row
    - call:
      - append: $ul
      - selectAll: li
      - data: 
        - red
        - green
        - blue
      #d3 update pattern
      - call:
        - enter:
        - append: $li
        - each:
          - text: '@'
          - style:
              font-color: '@'

        

# Data :: Objects

``data`` iterates over objects by applying ``d3.entries`` to the value

    body:
    - append: $div.row
    - call:
      - append: $ul
      - selectAll: li
      - data: 
          section-1: section1.html
          section-2: section2.html
          section-3: section3.html
      #d3 update pattern
      - call:
        - enter:
        - append: $li
        - append: a
        - each:
          - text: '@key'
          - attr:
              href: '@value'
          - style:
              font-color: '@value.color'

# Requests

    body: 
    - append: $div.row
    - call:
      - append: $ul
      - selectAll: li
      - requests:
          # { bar: [ baz, boom, bang] }
          file.json: http://url.com/foo.json
          # name.type: url
        
        # { finish the template after the request }
        call:
        - data: '@bar'
        - call:
          - enter:
          - append: li
          - text: '@'