       nav = d3.select('nav')
          .style('position','fixed')
          .style('width', function(){
            return this.offsetWidth*1.7+'px';
          })
          .style('left', function(){
            return -1 * this.offsetWidth + 'px'
          })
        
        d3.select('#editor-block')
          .on('click',function(){
            if (d3.select(this).style('opacity') != '.75'){
              d3.select(this).style('opacity','.75')
            }
          });
        
        modal = d3.select('#modal');
        
        d3.text( 'ui.yml', function(_d){
          
          _d = jsyaml.load( _d );
          
          d3.selectAll('.modal-trigger')
            .on( 'click', function(d){
                var id = d3.select(this).attr('id').split('-')[0];

              var dat = _d[id];
              if (modal.style('display') == 'none'){
                modal.style('display','block')
                     .datum({
                        id: id,
                      });
                UpdateModal(dat);
              } else if (modal.datum() && modal.datum()['id'] && id != modal.datum()['id'] ){
                  modal.datum({
                    id: id,
                  });
                  UpdateModal(dat);
              } else {
                modal.style('display','none')
              }
            })
        })
        function UpdateModal(dat){
          modal.select('ul.filter-list')
            .selectAll('li')
            .data(dat)
            .call( function(s){
               s.enter()
                .append('li')
                .append('a')
                .classed('filter-item',true)
                .attr('href','#')
               
               s.exit()
                .remove();
            })
            .each( function(s){
               d3.select(this)
                .select('a.filter-item')     
                .attr('id',function(d){return d.id;})     
                /**.on('click',function(){
                 
                  modal.style('display','none') 
                  
                })**/
                .text( function(d){
                  return d.name;
                })
            })        

          d3.select('#editor-trigger')
            .on('click',function(d){
              modal.style('display','none');
              d3.select('#editor-block')
                .style('display','block');              
            });

          d3.select('#html-trigger')
            .on('click',function(d){
              var p = d3.select('#preview-block');
              if (p.datum()['state']!='html'){
                p.datum( function(d){
                  d['state'] = 'html'
                  return d
                })
                update();
              }
            });

          d3.select('#raw-trigger')
            .on('click',function(d){
              var p = d3.select('#preview-block');
              if (p.datum()['state']!='raw'){
                p.datum( function(d){
                  d['state'] = 'raw'
                  return d
                })
                update();
              }
            });

          

        }
        editor = CodeMirror(d3.select('#editor-text').node(), {
              theme: "blackboard",
              mode: "yaml",
              lineNumbers: true,
              lineWrapping: true,
              extraKeys: {"Ctrl-Q": function(cm){ cm.foldCode(cm.getCursor()); }},
              foldGutter: {
                rangeFinder: new CodeMirror.fold.combine(CodeMirror.fold.indent, CodeMirror.fold.comment)
              },
              gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]
            });
        
        editor.setValue(d3.select('#initial').html())
        editor.on('change', update);
        preview = d3.select('#preview-block');
        preview.datum({
          state: 'html'
        })
        function update(){
          d3.select('#preview-block').call( function(s){
            if( s.datum()['state'] == 'html' ){
              s.html('')
               .template(  
                jsyaml.load( editor.getValue() ), function(d){ return d.display } 
              )
            } else if ( s.datum()['state'] == 'raw' ){
              
              s.text( function(){
                return this.innerHTML
              })
            }
          });
        }
        
        d3.select('.hider')
          .on('click', function(d){
            d3.select(this.parentNode)
              .style('display','none')
          })