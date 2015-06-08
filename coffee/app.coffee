---
---

client = new ZeroClipboard document.getElementById "copy-button"

client.on  "ready", ( readyEvent ) ->
  
client.on "beforecopy", ( event )->
    document.__data__.editor.mode.lineNumbers = false
    
client.on "aftercopy", ( event )->
  ###
  `this` === `client`
  `event.target` === the element that was clicked
  event.target.style.display = "none";
  ###
  document.__data__.editor.mode.lineNumbers = true
  
  console.log "Copied text to clipboard:  #{event.data['text/plain']}" 

$(".button-collapse").sideNav \
  menuWidth: 300, 
  edge: 'left', 
  closeOnClick: false 
  
contextvalue = d3.select '#context-value'

cm = d3.select '#context'
  .append 'div'
  .style 'display','none'
  
document.__data__ = 
  editor: CodeMirror cm.node(), 
          theme: "blackboard"
          lineNumbers: true
          lineWrapping: true
          readOnly: false
          extraKeys: 
            "Ctrl-Q": (cm)->cm.foldCode cm.getCursor()
          foldGutter: 
            rangeFinder: new CodeMirror.fold.combine CodeMirror.fold.indent, CodeMirror.fold.comment
          gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]

d3.select 'nav'
  .selectAll '.left li a'
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
      document.__data__.editor.mode = @dataset.key
      cm.style 'display','block'
      contextvalue.style 'display','none'
      val = if typeof document.__data__.block.body[@dataset.key] in ['object']
        JSON.stringify document.__data__.block.body[@dataset.key], null,2
      else 
        document.__data__.block.body[@dataset.key]
      document.__data__.editor.setValue val
      ### Change Code Mirror Mode ###
      cm.select '.CodeMirror-lines '
        .attr 'id', 'codemirror-view'
        
document.__data__.editor.on 'update', (cm)->
  if 'yaml' in [cm.mode]
    
    document.__data__.block.body.yaml = cm.getValue() 
      
      
d3.select '#update'
  .on 'click', ()->
    yaml = document.__data__.block.body.yaml
    contextvalue.html ''
      .template jsyaml.load yaml
    document.__data__.block.body.yaml = yaml

        
            

      