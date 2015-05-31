---
---

client = new ZeroClipboard document.getElementById "copy-button"

client.on  "ready", ( readyEvent ) ->
  alert "ZeroClipboard SWF is ready!" 

client.on "aftercopy", ( event )->
  ###
  `this` === `client`
  `event.target` === the element that was clicked
  event.target.style.display = "none";
  ###
  alert "Copied text to clipboard:  #{event.data['text/plain']}" 

$(".button-collapse").sideNav \
  menuWidth: 300, 
  edge: 'left', 
  closeOnClick: false 
  
contextvalue = d3.select '#context-value'

cm = d3.select '#context'
  .append 'div'
  .attr 'id', 'codemirror-view'
  .style 'display','none'
  
document.__data__ = 
  editor: CodeMirror cm.node(), \
          theme: "blackboard"
          mode: "yaml"
          lineNumbers: true
          lineWrapping: true
          extraKeys: 
            "Ctrl-Q": (cm)->cm.foldCode cm.getCursor()
          foldGutter: 
            rangeFinder: new CodeMirror.fold.combine CodeMirror.fold.indent, CodeMirror.fold.comment
          gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]

d3.select 'nav'
  .selectAll 'li'
  .each ()->
    if component = @dataset
      d3.select @
        .selectAll 'li'
        .on 'click', ()->
          d3.select '#header-lang'
            .text ()=>
              if [@dataset.key] in ['preview']
                @dataset.key
              else 
                " as #{@dataset.key}"
          if @dataset.key in ['preview']
            cm.style 'display','none'
            contextvalue.style 'display','block'
          else
            cm.style 'display','block'
            contextvalue.style 'display','none'
            val = if typeof document.__data__.template.body[@dataset.key] in ['object']
              JSON.stringify document.__data__.template.body[@dataset.key], null,2
            else 
              document.__data__.template.body[@dataset.key]
            document.__data__.editor.setValue val
            ### Change Code Mirror Mode ###