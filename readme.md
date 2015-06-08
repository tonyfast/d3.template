[![Build Status](https://travis-ci.org/tonyfast/d3.template.svg?branch=master)](https://travis-ci.org/tonyfast/d3.template)

``d3.template`` creates javascript and html from structured data objects.  This project 
hopes to accelerate the design and innovation of web-based presentation layers for data.

> This readme is written in Literate Coffeescript and can run as code.

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

All of the template data is stored in the ``document`` object under the key ``__data__``.
The meaning of ``document.__data__`` is from the d3 opinion that ``d3.select(document).datum({})``
would create the ``__data__`` class if it did not exist.

## Templating Lexicons ##

* The template object is refered to as a ``block``. (See [Jinja](http://jinja.pocoo.org/docs/dev/templates/#super-blocks) )
* An object key is a ``template`` or ``mixin``. 

    * ``template`` - operate on the value
    * ``mixin`` - operate on the selection and data
    
* Filters modify the value before the template is applied.  Templates are triggered
  with ``template.filter`` in the key. 
  
## Scoping d3 variables

``d3.template`` has some syntaxes to access local and global variables

|Scope|Prefix|Meaning|
|---|---|---|
|selection data| ``@`` | access data in the local scope |
|global data| ``:`` | access data in the global scope |
|current index| ``@i`` | the current index in an ``each`` iterator |
|current selection| ``@this`` | the current node in the selection |

## ``append`` shorthand

``$tagName.class1.class2#tag-id`` creates ``<tagName class="class1 class2" id="tag-id"></tagName>``
    
### What happened? ###

When ``.template`` is applied to the selection.  The structured object is converted into
Coffeescript then Javascript and finally it is display on the page as HTML.
  
### How does it work?  ###

``d3js`` design patterns are repeatable and structured.  Each key in a ``d3.template`` object corresponds to a method in [Selections API](https://github.com/mbostock/d3/wiki/Selections) with each value being the argument.
``d3.template`` iterates over arrays in the object; the key/value pairs are first
expressed as d3 written in Coffeescript.  The Coffeescript is transformed to Javascript and lastly
presented as HTML.

#### API Exceptions ####

``d3js`` has 4 functions that update a selection without any impact on the DOM.

|``d3js``|``d3.template``|----|
|-----|------|---|
|``enter``|``call-enter``| Update the selection to create new DOM nodes |
|``exit``|``call-exit``| Remove previously selected nodes from the selection |
|``remove``|``call-remove``| Remove exitted selection from DOM |
|``transition``|``call-transition``| Create a new d3 transition |


#### The Selection API ####

|``d3js``|``d3.template``|----|
|-----|------|---|
|``select``|``select``| Select the first DOM node containing the CSS selector|
|``selectAll``|``selectAll``| Select all  DOM nodes containing the CSS selector|
|``attr``|``attr``| change the state of a DOM node |
|``append``|``append``| add a new node to the DOM |


## Using Markdown


        
        mdobj = [
          - append: div
          - html.markdown: """
            # This is Markdown 

            It is appended to the document
            """
        ]
    
        selection.template mdobj

## Misc

``d3.template`` has two functions ``d3.getScript`` and ``d3.extend`` which both mirror their 
Jquery counterparts ``$.getScript`` and ``$.extend``.