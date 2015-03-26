(function() {
  d3.selection.prototype.template = function(template) {

    /*
    d3.[selection].template extends a d3 selection by 
    iterating over an object that contains repeatable d3 
    code patterns.
    
    template adds data to the DOM and modifies selections.  It
    allows data to be attached to its presentation layers within the
    DOM.
    
    also, template handles requests inline.  when a request is complete.
    the last call state with continue to build teh template
    
    d3.selection.template modifies d3.selection.prototype.template and d3.requests
     */
    var build, reduce, rules;
    build = function(s, t, state) {
      if (!state) {
        state = {};
      }
      t.forEach(function(t) {
        var _ref;
        t = d3.entries(t)[0];
        if (rules[t.key]) {
          return s = rules[t.key](s, t.value, state);
        } else if ((_ref = t.key) === 'selectAll' || _ref === 'select') {
          return s = s[t.key](t.value);
        } else {
          return s = s[t.key](function(d) {
            return reduce(t.value, d, state);
          });
        }
      });
      return s;
    };
    rules = {
      text: function(s, t, state) {
        return s.text(function(d, i) {
          if (Array.isArray(t)) {
            return t.map(function(_d, i) {
              return reduce(_d, d, state);
            }).join('');
          } else {
            return reduce(t, d, state);
          }
        });
      },
      js: function(s, t) {
        eval(t);
        return s;
      },
      template: function(s, t, state) {
        return build(s, reduce(t, null, state));
      },
      data: function(s, t, state) {
        return s.data(function(d) {
          t = reduce(t, d, state);
          if (!Array.isArray(t)) {
            t = d3.entries(t);
          }
          return t;
        });
      },
      datum: function(s, t, state) {
        return s.datum(function(d) {
          return reduce(t, d, state);
        });
      },
      attr: function(s, t, state) {
        d3.entries(t).forEach(function(t) {
          if (!t.value) {
            t.value = true;
          }
          return s.attr(t.key, function(d) {
            return reduce(t.value, d, state);
          });
        });
        return s;
      },
      style: function(s, t, state) {
        d3.entries(t).forEach(function(t) {
          if (!t.value) {
            t.value = true;
          }
          return s.style(t.key, function(d) {
            return reduce(t.value, d, state);
          });
        });
        return s;
      },
      'class': function(s, t, state) {
        d3.entries(t).forEach(function(t) {
          if (!t.value) {
            t.value = true;
          }
          return s.classed(t.key, function(d) {
            return reduce(t.value, d, state);
          });
        });
        return s;
      },
      enter: function(s, t) {
        return s.enter();
      },
      exit: function(s, t) {
        return s.exit();
      },
      remove: function(s, t) {
        return s.remove();
      },
      call: function(s, t, state) {
        return s.call(function(s) {
          return build(s, t, state);
        });
      },
      each: function(s, t, state) {
        return s.each(function(d, i) {
          state['i'] = i;
          return build(d3.select(this), t, state);
        });
      },
      append: function(s, t) {
        var classes, id, tag;
        id = null;
        tag = null;
        classes = null;
        if (t.startsWith('$')) {
          t = t.slice(1).split('#');
          if (t[1]) {
            id = t[1];
          }
          t = t[0].split('.');
          if (t[0]) {
            tag = t[0];
          }
          classes = t.slice(1);
          if (tag) {
            s = s.append(tag);
          }
          if (classes) {
            classes.forEach(function(c) {
              return s.classed(c, true);
            });
          }
          if (id) {
            s.attr('id', id);
          }
        } else {
          s = s.append(t);
        }
        return s;
      },
      child: function(s, t, state) {
        return rules.call(s, t, state);
      },
      requests: function(s, t, state) {
        var l;
        if (t['call']) {
          template = t['call'];
          delete t['call'];
        }
        t = d3.entries(t);
        if (!d3['requests']) {
          d3.requests = {};
        }
        l = t.length - 1;
        t.forEach(function(t, i) {
          var f, get, type;
          t.key = t.key.split('.');
          type = 'text';
          if (t.key[1]) {
            type = t.key[1];
            t.key = t.key[0];
          }
          if (!d3['requests'][t.value]) {
            get = function(type, callback, complete) {
              d3[type](t.value).get(function(e, d) {
                d3['requests'][t.value] = callback(d);
                d3['requests'][t.key] = d3['requests'][t.value];
                console.log(i, l, t.key, t.value);
                if (i === l && template) {
                  return s = s.call(function(s) {
                    return build(s, template);
                  });
                }
              });
              return s;
            };
            f = function(d) {
              return d;
            };
            if (type === 'json' || type === 'xml' || type === 'csv' || type === 'tsv' || type === 'html' || type === 'text') {

            } else if (type === 'yaml' || type === 'yml') {
              type = 'text';
              f = function(d) {
                return jsyaml.load(d);
              };
            }
            return s = get(type, f);
          } else {
            d3['requests'][t.key] = d3['requests'][t.value];
            if (i === l && template) {
              return s = s.call(function(s) {
                return build(s, template, state);
              });
            }
          }
        });
        return s;
      }
    };
    reduce = function(path, d, state) {
      var _ref;
      if (typeof path === 'string' && ((_ref = path[0]) === '@' || _ref === ':')) {
        if (path === '@') {
          return d;
        } else if (path === '@i') {
          return state.i;
        } else {
          if (path[0] === ':') {
            d = window;
          }
          return path.slice(1).split('.').reduce(function(p, k) {
            return p[k];
          }, d);
        }
      } else {
        return path;
      }
    };
    return build(this, template);
  };

}).call(this);
