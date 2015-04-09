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
