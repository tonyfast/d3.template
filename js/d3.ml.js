;( function(){
  // an extension for d3 that iterates over Javascript objects
  // to build a DOM derived from data.
  d3.ml = {
    // YAML templates that execute d3ml
    templates: {},
    requests: {},
    scripts: {},
    get: 
      function(d){
        // make it easy as possible to get the correctly typed file
        // default: text
        
        var _d  = d3.entries( d.value )[0]
        
        if ( d3.ml.requests[_d.value] ){
          d3.ml.requests[d.key] = d3.ml.requests[_d.value]
        } else {
          var f = d3.text,
              parser = function(d){return d;},
              out = {};

          if( 
            d3.ml.helper.intersect( _d.key, ['json','xml','tsv','csv'] ) 
          ){
            f = d3[ _d.key ]
          } else if (  
            d3.ml.helper.intersect( _d.key, ['yaml','yml'] ) 
          ){
            parser = function(d){return jsyaml.load( d );}
          }

          f(_d.value, function(d){
            d3.ml.requests[_d.value] = parser(d)
          })
        }
      },
    build: 
      function(s, template){
          // Initial DOM node data
          // Append a template to a selection
          if ( !s.data()[0]){
            // make sure the parent selection has
            // data for the worker to use.
            s = s.datum( {} );
          }
        
          if (d3.ml.templates['requests']){
            d3.entries(d3.ml.templates['requests']).forEach( function(d){
              d3.ml.get(d)
            })
          }

          if ( template ){
            // add a class to the parent selection so it knows d3ml was used
            s.classed('d3-ml',true);

            // build the template only if it exists
            return d3.ml.worker( 
              s, 
              template
            )
          } 
      },
    worker: 
      function ( s, template ){
         // Execute a d3ml template on the
         // selection

         if ( s.data()[0] ){
           // if a selection has data then 
           // bring it into the scope 
           var data = s.data()[0];
         }
        
        console.log( 's', s, template )
        template.forEach( function(template){
           // for each of selections
           // traverse the templates with
           // d3ml
           s = d3.ml.task( s, d3.entries(template)[0], data)
           })
        return s;
      },
    helper: {
      extend : 
        function ( d, _d, i ){
          // a hack for $.extend with native d3
          if ( !Array.isArray(d) ){    
            d3.merge( [ 
              d3.entries( d ), 
              d3.entries( _d )
            ])
              .forEach( function(_d){
                i[ _d.key] = _d.value;
              })
            return i;
          } else {
            // Don't append objects to Arrays
            return d;
          }
        },
      extend:
        function ( d, _d, i ){
          // a hack for $.extend with native d3
          if ( !Array.isArray(d) ){    
            d3.merge( [ 
              d3.entries( d ), 
              d3.entries( _d )
            ])
              .forEach( function(_d){
                i[ _d.key] = _d.value;
              })
            return i;
          } else {
            // Don't append objects to Arrays
            return d;
          }
        },
      intersect :
        function (str, set ){
          // return true if a string is in a set of strings
          return( 
            set.filter( function(d){
              return (d == str);           
            }).length > 0
          )
        },
      reduce: 
        function ( k, d, _d ){
          // get the value of a key for
          // either the current scope ':' or local scope '@'
          if ( k.slice(0,9) == ( ':requests') ){
            d = d3.ml.requests
            k = ':' + k.slice(10)
          }
          
          if (k[0] == '@'){    
          // return data from the local scope
            d = _d;
          }

          if ( d3.ml.helper.intersect( k , [':','@'] ) ){
            return d
          } else if ( d3.ml.helper.intersect( k[0] , [':','@'] ) ){
            return k.slice(1).split('.')
             .reduce( function( p, n){ 
                if (p[n]){
                  // recurse object through intersect
                  return p[n]
                } else {
                  // default if key doesn't exist
                  return {}
                }

               }, d );
          } else {
            return k;
          }

        }
    },
    task: function ( s, t, data ){
      // for a selection, s, apply a action defined t
      // using data if it is needed
      if ( t.key == 'call' ){
        // update selection and the data scope is updated in the worker
          s = s[t.key]( function(s){
            d3.ml.worker(s, t.value);
          })
       } else if (  t.key == 'template' ){
          // send a nested template to the worker to execute
          s = d3.ml.build(
            s,
            d3.ml.helper.reduce( 
              t.value, 
              d3.ml.templates 
            ) 
          )
       } else if (  t.key == 'each' ){
          // iterate over a multi-selection array, d3 selection
          s = s[t.key]( function(){
            d3.ml.worker(d3.select(this), t.value);
          })
       } else if (  t.key == 'class' ){
          // Append classes to the selection.
          // d.value is a object that is iterated over
          d3.entries( t.value )
            .forEach( function(_d){
              if (_d.value == null ){
                s.classed( _d.key, true ) 
              } else {
                s.classed( _d.key, _d.value  ) 
              }

            })
       } else if ( 
         d3.ml.helper.intersect( t.key, ['attr','style','property'] ) 
       ){
         // change the style of attributes
         // values are objects like class
          d3.entries( t.value )
            .forEach( function(_d){
               s[t.key]( _d.key, function(__d){
                 return (
                   d3.ml.helper.reduce( _d.value, data, __d ) 
                 )
               })
            })
       } else if ( 
         d3.ml.helper.intersect(  t.key, ['enter','exit','remove'] ) 
       ){
         // modified data in selections
         s = s[t.key]()
       } else if ( 
         d3.ml.helper.intersect( t.key, ['data'] ) 
       ){
         // update data in for a selection
         s = s[t.key]( function(_d){
           return d3.ml.helper.reduce( t.value, data, _d )
         })
       } else if ( 
         d3.ml.helper.intersect( t.key, ['xml','json','yaml','yml','aml','plain','csv','tsv'] ) 
       ){
         // append data from the archie base
         // update selection
         var parse = function(d){ return d;}
         if ( d3.ml.helper.intersect( t.key, ['yaml','yml' ] ) ){
              t.key = 'text'
              parse = function(d){
                return jsyaml.load(d);
              }
          } 
         if ( d3.ml.helper.intersect( t.key, ['aml' ] ) ){
              t.key = 'text'
              parse = function(d){
                return archieml.load(d);
              }
          } 
         if ( d3.ml.helper.intersect( t.key, ['plain' ] ) ){
              t.key = 'text'
          } 
         d3[t.key]( t.value, function(d){
           if ( t.key == 'aml' ){
              if( window['archieml']){
                d = archieml.load( d )
              }
            } 
            s = d3.ml.task( s, {
               key: 'datum',
               value: parse(d)
             }, data)

         })
       } else if ( d3.ml.helper.intersect( t.key, ['datum'] ) ){
         // append data-on-the-fly  
         s = s[t.key]( function(_d){
            // previously attached data
            if (_d ){
              // merge objects
              if (typeof t.value == 'string'){
                // access predefined variables
                // allows arbitrary data
                t.value =  d3.ml.helper.reduce( t.value, data, _d)
              }
              return (
                d3.ml.helper.extend( _d, t.value, {} )
              )
            } else {
              // attach data if it hasnt been assigned
              return (_d);
            }
         })
       } else if ( d3.ml.helper.intersect( t.key, ['selectAll','select'] ) ){
         // selection changes
           s = s[t.key]( t.value );  
       } else if ( d3.ml.helper.intersect( t.key, ['append','insert'] ) ){
         // selection changes
         if (t.value[0] == '$'){

           // I wish i knew regular expressions
           // this can probably be done with the function update by converting to a template
           // $tag.class1-name.class2-name#id
           var path = t.value.slice(1).split('.');
           if ( (path[0].length > 0) && ( path[0][0] != '#' ) ){
             // dont forget to update teh selection
             s = s.append( path[0] )
           } 
           // add classes
           path.slice(1).filter( function(path){
             return (path[0] != '#') && ( path[0].length > 0 )
           }).forEach( function(path){
             s.classed( path.split('#')[0], true);
           })
           path.filter( function(path){
             return (path.split('#')[1])
           }).forEach( function(path){
             // this will only happen once
             s.attr( 'id', path.split('#')[1] );
           })
         } else {
           // normal append
           s = s[t.key]( t.value );  
         }

       } else if ( d3.ml.helper.intersect( t.key, ['text','html'] ) ){
         // append data from the d3 base
          s[t.key]( function(_d){
              return d3.ml.helper.reduce( t.value, data, _d)
          })
       } else {
         // don't use any other commands yet
       }
      return s;
    }
  }
})();