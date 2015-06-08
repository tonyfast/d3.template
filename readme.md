[![Build Status](https://travis-ci.org/tonyfast/d3.template.svg?branch=master)](https://travis-ci.org/tonyfast/d3.template)

``d3.template`` creates javascript and html from structured data objects.  This project 
hopes to accelerate the design and innovation of web-based presentation layers for data.
  
## Basic usage?

0. ``d3.template`` requires [d3js](www.d3js.org); it is extends the [``d3.selection.prototype``]().  

        d3.getScript 'https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js'

1. Create a structured manifest as YAML or JSON for example.
  
        obj = [
          append: h1
          text: This is a heading
        ]
  
2. Create a new d3 selection.

        selection = d3.select 'body'

3. Append the template to the selection
        
        selection.template obj
    
4. That HTML is the current selection is changed.

## ``document.__data__``

All of the template data is stord in the ``document`` object under the key ``__data__``.
The meaning of ``document.__data__`` is from the d3 opinion that ``d3.select(document).datum({})``
would create the ``__data__`` class if it didn't exist.

### What happened? ###

When ``template`` is applied to the selection.  The structured object is converted into
Coffeescript then Javascript and finally it is display on the page as HTML.
  
### How does it work?  ###

``d3js`` design patterns are repeatable and structured.  
Each key in a ``d3.template`` object corresponds to a method in [Selections API](https://github.com/mbostock/d3/wiki/Selections) with each value being the argument.
``d3.template`` iterates over arrays in the object; the key/value pairs are first
expressed as d3 written in Coffeescript.  The Coffeescript is transformed to Javascript and lastly
presented as HTML.

#### The Seection API ####

|``d3js``|``d3.template``|----|
|-----|------|---|
|``select``|``select``| Select the first DOM node containing the CSS selector|
|``selectAll``|``selectAll``| Select all  DOM nodes containing the CSS selector|
|``attr``|``attr``| change the state of a DOM node |
|``append``|``append``| add a new node to the DOM |


## Misc

``d3.template`` has two functions ``d3.getScript`` and ``d3.extend`` which both mirror their 
Jquery counterparts ``$.getScript`` and ``$.extend``.