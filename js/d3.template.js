// Generated by CoffeeScript 1.9.3
(function() {
  var cbToString, initTemplate, mixinToCoffee, mountDOM, nullSelection, objToString, selectionCall, selectionEach, templateToCoffee, updateDOM, updateData, updateInner, updateOpts, updateSelection,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  d3.selection.prototype.template = function(template, opts) {

    /*
    template - a nested array object
      ```yaml
      - key.filter: value
      ```yaml
    
      key - d3 and user-defined actions.
      filter - manipulates data
      value - Javascript object that complies with the action.
    
    opts - append filters, rules, and useful data.
     */

    /* initialize document.__data__ and d3.template objects */
    var __data__, coffee, key, ref;
    initTemplate();

    /* Append any custom operations */
    __data__ = updateOpts(opts);

    /* split key and value from template if they exist. */
    ref = (function() {
      if (!Array.isArray(template)) {
        return [d3.keys(template)[0], d3.values(template)[0]];
      } else {

        /* Array valued template - the template not stored on the document */
        return [null, template];
      }
    })(), key = ref[0], template = ref[1];

    /* Track current selection */
    document.__data__.current = {
      selection: this,
      template: template
    };
    if (key) {
      document.__data__.block[key] = {
        object: template,
        __data__: __data__
      };
    }

    /* convert actions to coffeescript */
    coffee = templateToCoffee(template, ["selection=document.__data__.current.selection", "data=selection.node().__data__", "selection"], 1, -1);
    document.__data__.block[key].coffee = key ? coffee : void 0;
    document.__data__.block[key].js = CoffeeScript.compile(coffee, {
      bare: true
    });
    eval(document.__data__.block[key].js);
    return document.__data__.block[key].html = document.__data__.current.selection.html();
  };


  /* Convert to values instead of strings */

  objToString = function(value, noQuote) {

    /* Transform rule object to coffeescript string prefix */
    var ref, ref1, ref2, stringvalue, templateToValueString;
    templateToValueString = function(value) {

      /* 
      split dot separated strings 
      @this.key1.key2.lastkey -- @['key1']['key2']['lastkey']
       */
      if (value) {
        value = value.split('.').join("']['");
        return "['" + value + "']";
      } else {
        return "";
      }
    };
    if (value && ((ref = typeof value) === 'string')) {
      stringvalue = d3.entries(document.__data__.prefix).filter(function(prefix) {
        return value.startsWith(prefix.key);
      })[0];
      if (stringvalue) {

        /* Do not wrap is single quotes */
        if ((ref1 = stringvalue.key) === '$') {
          return "" + value;
        } else if ((ref2 = stringvalue.key) === '@i') {
          return "" + stringvalue.value;
        } else if (stringvalue.value) {
          return "" + stringvalue.value + (templateToValueString(value.slice(1)));
        } else {

          /* wrap in single quotes */
          return "\"" + stringvalue.value + "\"";
        }
      } else if ((noQuote != null) && noQuote) {

        /* wrap in double quotes to activate string interpolation */
        return "" + value;
      } else {
        return "\"" + value + "\"";
      }
    } else {
      return value;
    }
  };

  selectionCall = function(template) {

    /* 
    The Call option 
    Can isolate data transforms and requests also it can great dom children
     */
    return ".call (selection)-> \n\tdata=selection.node().__data__ ? null\n\tselection";
  };

  selectionEach = function(template) {

    /* Iterates over an existing dom selection */
    return ".each (data,index)->\n\td3.select @";
  };

  mountDOM = function(template) {

    /* 
    Short hand notaton: 
      $tagName.className1.className2.className3#anchor-id
    =>
      <tagName class="className1 className2 className3" id="anchor-id"></tagName>
    Make many changes to DOM insert new objects 
    
    * There is no reason for filter here.  Shit yes there is what is a class value changes.  col-sm-6
     */
    var classes, id, len, obj, output, ref, ref1, tagName;
    output = [];
    if (template.value.startsWith('$')) {
      if (indexOf.call(template.value, '.') < 0) {
        output.push("." + template.key + " " + template.filter + "\"" + (template.value.slice(1)) + "\"");
      } else {
        ref = template.value.slice(1).split('.'), tagName = ref[0], classes = 2 <= ref.length ? slice.call(ref, 1) : [];
        len = classes.length - 1;
        if (len > 0 && indexOf.call(classes[len], '#') >= 0) {
          ref1 = classes[len].split('#'), classes[len] = ref1[0], id = ref1[1];
        }
        if (tagName != null) {
          output.push("." + template.key + " " + template.filter + "'" + tagName + "'");
        }
        if (classes != null) {
          obj = {};
          classes.forEach(function(d) {
            return obj[d] = obj != null ? true : {
              d: true
            };
          });
          output.push(updateDOM({
            key: 'classed',
            filter: template.filter,
            value: obj
          }));
        }
        if (id != null) {
          output.push(updateDOM({
            key: 'attr',
            filter: template.filter,
            value: {
              id: id
            }
          }));
        }
      }
      return output.join('\n');
    } else {
      return "." + template.key + " " + template.value;
    }
  };

  updateData = function(template) {
    var ref, ref1, ref2, valueString;
    if ((ref = typeof template.value) === 'object') {
      d3.entries(template.value).forEach(function(d) {
        return template.value[d.key] = objToString(d.value, true);
      });
      valueString = JSON.stringify(template.value);
    } else {
      valueString = template.value;
    }
    if ((ref1 = template.key) === 'data') {
      if (((ref2 = typeof template.value) === 'object') && !Array.isArray(template.value)) {

        /* Convert object to d3.entry */
        valueString = JSON.stringify(d3.entries(template.value));
      }
    }
    return "." + template.key + " " + template.filter + valueString;
  };

  updateSelection = function(template) {

    /* selection */
    var ref;
    return "." + template.key + " " + template.filter + ((ref = template.value) != null ? ref : null);
  };

  updateDOM = function(template) {

    /* attr whatever */
    var classProcess, ref;
    classProcess = (ref = template.key) === 'classed' ? function(d) {
      return "" + (d != null);
    } : function(d) {
      return "" + d;
    };
    d3.entries(template.value).forEach(function(value) {
      template.value[value.key] = objToString(value.value, true);
      if (template.value[value.key] === value.value) {
        return template.value[value.key] = "'" + template.value[value.key] + "'";
      }
    });
    return d3.entries(template.value).map(function(d, i) {
      return "." + template.key + " '" + d.key + "', " + template.filter + (classProcess(d.value));
    }).join('\n');
  };

  nullSelection = function(template) {

    /* enter, exit, transition, remove */
    return ".call (selection)->\n\tselection." + (template.key.split('-')[1]) + "()";
  };

  updateInner = function(template) {

    /* Update inner text */
    var ref, ref1, value;
    if (Array.isArray(template.value)) {
      value = template.value.map(function(d) {
        var _d, hasPre;
        _d = objToString(d, true);
        hasPre = d3.keys(document.__data__.prefix).filter(function(prefix) {
          return d.startsWith(prefix);
        }).length;
        if (hasPre > 0) {
          _d = "\#\{" + _d + "\}";
        }
        return _d;
      }).join('');
    } else {
      value = (ref = template.value) != null ? ref : '';
    }
    if ((ref1 = template.key) === 'html') {
      return "." + template.key + " " + template.filter + " \"\"\"\n" + value + "\n\"\"\"";
    } else {
      return "." + template.key + " " + template.filter + value;
    }
  };

  cbToString = function(template) {
    if (template['filter'] && (document.__data__.filter[template['filter']] != null)) {
      return "document.__data__.filter['" + template.filter + "'] ";
    } else {
      return "";
    }
  };

  initTemplate = function(opts) {

    /* 
    Agnostic to template
    A template converts structured data to javascript and coffeescript 
    Init Template initializes the document data and sets the template settings
    
    * return __data__ to append to template object
    mixin and default take different arguments
     */
    var init;
    init = {
      include: {},
      current: {
        selection: null,
        template: null
      },
      block: {},
      filter: {
        echo: function(d) {
          console.log(d);
          return d;
        },
        markdown: function(d) {
          return marked(d);
        },
        jade: function(d) {
          return jade.render(d);
        }
      },
      template: {
        call: selectionCall,
        each: selectionEach,
        insert: mountDOM,
        append: mountDOM,
        data: updateData,
        datum: updateData,
        select: updateSelection,
        selectAll: updateSelection,
        attr: updateDOM,
        property: updateDOM,
        style: updateDOM,
        classed: updateDOM,
        'call-enter': nullSelection,
        'call-exit': nullSelection,
        'call-transition': nullSelection,
        'call-remove': nullSelection,
        text: updateInner,
        html: updateInner
      },
      mixin: {
        test: function(selection, obj) {
          return console.log('test rule echos: ', obj);
        },
        js: function(selection, obj) {
          return eval(obj.value);
        },
        request: function(selection, obj, onComplete) {
          var makeRequest;
          makeRequest = function(req) {
            var name, ref, type;
            if (req.length === 0 && onComplete) {
              return onComplete();
            } else {
              ref = req[0].key.split('.'), name = ref[0], type = ref[1];
              if (document.__data__.include[name]) {
                selection.datum(function(d) {
                  if (d == null) {
                    d = {};
                  }
                  d[name] = document.__data__.include[name];
                  return d;
                });
                return makeRequest(req.slice(1));
              } else {
                return d3[type != null ? type : 'text'](req[0].value, function(e, d) {
                  document.__data__.include[name] = d;
                  selection.datum(function(d) {
                    if (d == null) {
                      d = {};
                    }
                    d[name] = document.__data__.include[name];
                    return d;
                  });
                  return makeRequest(req.slice(1));
                });
              }
            }
          };
          return makeRequest(d3.entries(obj).filter(function(d) {
            var ref;
            return !((ref = d.key) === 'call' || ref === 'baseurl');
          }));
        }
      },
      prefix: {
        '$': "",
        '@this': "@",
        '@i': "index",
        '@': "data",
        ':d3.templates': "document.__data__.block",
        ':': "window",
        '_': "document.__data__.current.template.__data__",
        '\\': ""
      }
    };
    if (document['__data__'] == null) {
      document['__data__'] = {};
    }
    return d3.entries(init).forEach(function(opt) {
      var base, name1;
      if ((base = document['__data__'])[name1 = opt.key] == null) {
        base[name1] = {};
      }
      return document['__data__'][opt.key] = d3.extend(document['__data__'][opt.key], opt.value);
    });
  };

  updateOpts = function(opts) {
    var __data__, ref, ref1;
    if (opts) {
      ref1 = [
        (ref = opts.__data__) != null ? ref : null, d3.entries(opts).filter(function(d) {
          var ref1;
          return !((ref1 = d['key']) === '__data__');
        })
      ], __data__ = ref1[0], opts = ref1[1];
      if (opts != null) {
        opts.forEach(function(opt) {
          return document.__data__[opt.key] = d3.extend(document.__data__[opt.key], opt.value);
        });
      }
      return __data__;
    }
  };


  /* mixins convert yaml syntaxes to coffeescript code */

  mixinToCoffee = function(template) {

    /* Creates string representations of JS objects in coffee */
    var reserved, val;
    if (document.__data__.template[template.key]) {

      /* default d3 actions */
      return document.__data__.template[template.key](template);
    } else if (document.__data__.mixin[template.key]) {

      /*  write execution of custom mixin in coffeescrippt */
      reserved = ['call', 'each'];
      if (typeof template.value === 'string') {
        val = template.value;
      } else {
        val = {};
        d3.entries(template.value).filter(function(d) {
          var ref;
          if (ref = d.key, indexOf.call(reserved, ref) >= 0) {
            return false;
          } else {
            return true;
          }
        }).forEach(function(d) {
          return val[d.key] = d.value;
        });
      }

      /* Append more templates to selection on next pass */
      return ".call (selection)->\n\tdocument.__data__.mixin['" + template.key + "'] selection, " + (JSON.stringify(val)) + ", ()=> \n\t\tdata=selection.node().__data__ ? null\n\t\tselection";
    } else {
      return ".call (selection)->\n\tconsole.log 'The is no rule " + template.key + " defined'";
    }
  };

  templateToCoffee = function(template, output, level, index) {

    /*
    level: hierarchy in object
    index: value of array loop (-1 : not Array)
     */
    var indentBlockString;
    if (template) {
      indentBlockString = function(indent, lines) {
        return lines.split('\n').map(function(line) {
          return "" + indent + line;
        }).join('\n');
      };
    }
    level = level + 1;
    template.forEach(function(template) {
      var indent, onCompleteKey, parsed, ref, ref1, ref2, ref3, ref4;
      template = d3.entries(template)[0];
      ref = template['key'].split('.'), template['key'] = ref[0], template['filter'] = ref[1];

      /* classed is a dumb name */
      if ((ref1 = template['key']) === 'class') {
        template['key'] = 'classed';
      }

      /* Stringified version of filter in coffee */
      template['filter'] = cbToString(template);

      /* stringify value if necessary */
      if (ref2 = template['key'], indexOf.call(d3.keys(document.__data__.template).filter(function(d) {
        return d !== 'html';
      }), ref2) >= 0) {

        /* text and html can concatentate array elements as a special case */
        template['value'] = objToString(template['value']);
      }

      /* Coffeescript is whitespace aware and is lovely to read */
      indent = d3.range(level).map(function(d) {
        return '';
      }).join('\t');
      parsed = mixinToCoffee(template);
      output.push(indentBlockString(indent, parsed));
      if ((ref3 = template['key'].slice(0, 4)) === 'call' || ref3 === 'each') {

        /* Branching data and null selections */
        output.push(templateToCoffee(template.value, [], level, index));
      }
      if (ref4 = template['key'], indexOf.call(d3.keys(document.__data__.mixin), ref4) >= 0) {

        /* mixins */
        onCompleteKey = d3.keys(template.value).filter(function(d) {
          return d === 'call' || d === 'each';
        })[0];
        if ((template.value['call'] != null) || (template.value['each'] != null)) {
          return output.push(templateToCoffee(template.value[onCompleteKey], [], level + 1, index));
        }
      }
    });
    return output.join('\n');
  };


  /* Append some d3 utilities */

  d3.extend = function(obj1, obj2) {
    d3.entries(obj2).forEach(function(d) {
      var name1;
      return obj1[name1 = d.key] != null ? obj1[name1] : obj1[name1] = d.value;
    });
    return obj1;
  };


  /* similar to $.ready() */

  d3.getScript = function(src, callback) {
    var prior, script;
    script = document.createElement('script');
    prior = document.getElementsByTagName('script')[0];
    prior.parentNode.insertBefore(script, prior);
    script.onload = script.onreadystatechange = function(_, isAbort) {
      if (isAbort || !script.readyState || /loaded|complete/.test(script.readyState)) {
        script.onload = script.onreadystatechange = null;
        script = void 0;
        if (!isAbort) {
          if (callback) {
            return callback();
          }
        }
      }
    };
    return script.src = src;
  };

}).call(this);

//# sourceMappingURL=d3.template.js.map
