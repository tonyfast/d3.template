# ``d3.template`` 

``d3.template`` is a reactive templating engine extended from ``d3js`` to create HTML from structured data.

# Example

Below is a ``yaml`` string that will create a very simple HTML element.

```yaml
- append: div
- attr:
    class: 'container'
- call:
  - append: h1
  - text: Hello World
- call: 
  - append: p
  - text: I am a child of the parent container
```

# How does it work

1. Create a template that can be converted to a Javascript object.  

        ###
        Deserialize a javascript object 
        Requires jsyaml
        ###
        template_data = JSON.parse json_string
    
2. Pass the object to a ``d3.selection``
    
        ###
        Append <div class="d3-template"></div> to the <body></body> tag
        ###
        template_div = d3.select 'body'
          .append 'div'
          .attr 'class', 'd3-template'

3. ``d3.template`` iterates over the arrayed objects using d3-like syntaxes.
    
        ###
        The d3 selection ``div`` has class ``template`` that uses 
        key value pairs to build html documents
        ###
        div = template_div.template template_data

# Keys

Most of the options from core [d3 Selection API](https://github.com/mbostock/d3/wiki/Selections) are 
available with ``d3.template``.  The d3 

## Rule

Each method in the d3.selection API has a special set of rules written in [coffeescript](). 

> I am not married to the word rule.  Method is probably a better word.

### Rule.Callbacks

Rules can be append with a callback that applies a function to the value of the template.

# Values

Values are the arguments that are passed to the rules.

## Strings

## Arrays

### Concatenate Strings

# About this readme

This readme is written in literate coffeescript and is used for the tutorial on the webpage.







[![Build Status](https://travis-ci.org/tonyfast/d3.template.svg?branch=master)](https://travis-ci.org/tonyfast/d3.template)

It is very easy to extend ``d3js`` beyond SVG elements to a DOM manipulation tool.  At it's core, d3 adds ``__data__`` to selected DOM
elements then it adds convenience functions to insert derivatives of this data into the DOM.

``d3js`` has a limited grammer and very repeatable syntaxes.  ``d3.template`` extends ``d3js`` to execute reusable patterns from structured data, typically YAML because it is easy to write.

[``d3.template``](https://github.com/tonyfast/d3.template/) traverses a large nested array of objects.  keys are equivalent to d3 commands with add-ons to get scripts, providers, stylesheets, and execute javascript.  The value is an value into the d3 method.

## Example Templates

Copy and paste these into the [wsywyg editor](http://tonyfast.com/d3.template/)

* [https://gist.github.com/tonyfast/13e1e75081f73a118a9f](https://gist.github.com/tonyfast/13e1e75081f73a118a9f)
* [https://gist.githubusercontent.com/tonyfast/49e2e2cbab5cf92fbe9f/raw/07b3996b14aa7f58300b7e12b2549fdca8978d64/.movie-domain.yml](Movie Data)
* [Templates used for demo page](https://github.com/tonyfast/d3.template/tree/gh-pages/templates)


## Append shorthand:

    - append: $div.foo.bar#baz

Starting values with a ``$`` will make


    <div class="foo bar" id="baz">
    </div>
    
## Callbacks 

``key.baz.foo`` will applied the function ``d3.callbacks.baz.foo`` before the data
is applied to the dom.  

Callbacks defintions start at the first period in a key.


## Value shortcuts:

* **@foo.bar** - access the local scope ``d.foo.bar``
* **@this.nodeKey** - access the local DOM node ``this.nodeKey``
* **@i** - The current function index
* **:foo.bar** - access the global scope ``window.foo.bar``
* **\\:window.foo.bar** - escape string ``:window.foo.bar``

## Concatentation

Concatenate string for ``text`` and ``html`` by supplying an array as the value.  Each element will be parsed with the value
shortcuts then concatenated.
