// Generated by CoffeeScript 1.9.3
(function() {
  var templater;

  d3.selection.prototype.template = function(template, data, opts) {

    /*
    Convert a structured javascript object into executable d3 commands
    data - optional data
    opts - optional rules and callbacks
     */
    return this.each(function(d, i) {
      if (data == null) {
        data = new Object;
      }
      if (opts == null) {
        opts = new Object;
      }
      if (data.state == null) {
        data.state = d;
      }
      if (data.index == null) {
        data.index = i;
      }
      return new templater(template, d3.select(this), data, opts);
    });
  };

  templater = (function() {
    var createNode, nullSelection, reduceKey, updateNode, updateSelection;

    function templater(template, selection1, data1, opts1) {
      this.selection = selection1;
      this.data = data1;
      this.opts = opts1;

      /*
      @opts - Javascript objects loaded into a template
        callback - callback functions registered with d3.template
       */
      this.init();
      template.forEach((function(_this) {
        return function(_template) {

          /*
          For each element in the template parse the d3.template syntax
          create key, value, callback for @template
          Use the current template to execute the commands
          return the selection
           */
          _this.template = _this.parseArgs(_template);
          return _this.build();
        };
      })(this));
      this.selection;
    }

    templater.prototype.update = function(obj, opts) {

      /*
      Update keys for the state, rules, data
       */
      return d3.entries(opts).forEach(function(d) {
        return obj[d.key] = d.value;
      });
    };

    templater.prototype.config = function(opts) {

      /*
      Used to create custom and standard rules and callbacks
       */
      return d3.entries(opts).forEach(function(opts) {
        var base, name;
        return this.update((base = this.opts)[name = opts.key] != null ? base[name] : base[name] = new Object, opts.value);
      });
    };

    templater.prototype.build = function() {

      /*
      Implement a rule for the current state, selection, data, opts
       */
      var c, ref;
      if (this.opts.rule[this.opts.state.key] != null) {
        if ((ref = this.opts.state.key) === 'text' || ref === 'html') {
          c = ' ';
          if (Array.isArray(this.template.value)) {
            this.template.value = this.template.value.map((function(_this) {
              return function(d) {
                return _this.parseValue({
                  value: d
                });
              };
            })(this)).join(c);
          }
        }
        return this.selection = this.opts.rule[this.opts.state.key](this.opts.state, this.selection, this.data, this.opts);
      }
    };

    templater.prototype.init = function() {

      /*
      Initialize the state of the template.
       */
      var base, base1;
      this.update((base = this.opts).state != null ? base.state : base.state = new Object, {

        /*
        key - existing rule
        value - value for the rule to execute
        callback - a callback function to apply to the value before it is created.
         */
        key: null,
        value: null,
        callback: function(d) {
          return d;
        }
      });
      this.update((base1 = this.opts)['rule'] != null ? base1['rule'] : base1['rule'] = new Object, {
        selectAll: updateSelection,
        select: updateSelection,
        template: updateSelection,
        datum: updateSelection,
        data: function(template, selection) {
          if (typeof template.value === 'object' && !Array.isArray(template.value)) {
            template.value = d3.entries(template.value);
          }
          return updateSelection(selection, template);
        },
        enter: nullSelection,
        exit: nullSelection,
        remove: nullSelection,
        call: function(template, selection, data, opts) {
          return selection['call']((function(_this) {
            return function(selection) {
              return selection['template'](template.value, data, opts);
            };
          })(this));
        },
        each: function(template, selection, data, opts) {

          /*
          Pass the template, data, and current configurations
          to each iteration
           */
          return selection.each(function(d, i) {
            var ref;
            ref = [d, i], data.state = ref[0], data.index = ref[1];
            return d3.select(this).template(template.value, data, opts);
          });
        },
        insert: createNode,
        append: createNode,
        style: updateNode,
        attr: updateNode,
        property: updateNode,
        'class': updateNode,
        classed: updateNode,
        text: updateSelection,
        html: updateSelection,
        on: function(template, selection, data, opts) {
          var events;
          events = ['click'];
          events.forEach(function(d) {
            return selection.on(d, function() {
              return d3.select(this).template(template.value[d], data, opts);
            });
          });
          return selection;
        },
        js: function(template, selection) {
          eval(template.value);
          return selection;
        }
      });
      return this.opts.rule.child = this.opts.rule.call;
    };

    updateSelection = function(template, selection) {

      /*
      selection.method( callback( value ) )
       */
      var ref;
      if ((ref = template.key) === 'scripts') {
        debugger;
      }
      return selection[template.key](template.callback(template.value));
    };

    createNode = function(template, selection) {
      var classed, id, tag;
      if (template.value[0] === '$') {
        id = template.value.split('#');
        tag = id[0].slice(1).split('.');
        id = id[1];
        classed = tag.slice(1);
        tag = tag[0];
      } else {
        tag = template.value;
      }
      if (tag.length) {
        selection = selection[template.key](tag);
      }
      if (classed) {
        classed.forEach(function(d) {
          return selection.classed(d, true);
        });
      }
      if (id) {
        selection.attr({
          id: id
        });
      }
      return selection;
    };

    nullSelection = function(template, selection) {

      /*
      selection.key()
       */
      return selection[template.key]();
    };

    updateNode = function(template, selection) {

      /*
      iterate over objects to defined multiple classes and attributes at once
       */
      var f;
      f = function(d) {
        return d;
      };
      if (template.key.startsWith('class')) {
        template.key = 'classed';

        /* If the value is null then assume the class is true */
        f = function(d) {
          if (d === null) {
            return true;
          } else {
            return d;
          }
        };
      }
      d3.entries(template.value).forEach(function(d) {
        return selection[template.key](d.key, template.callback(f(d.value)));
      });
      return selection;
    };

    templater.prototype.parseArgs = function(template) {

      /* 
      Convert key and value to the key, value, and callback
      key.callback: {[value]}
       */
      return this.opts.state = {
        key: d3.keys(template)[0].split('.')[0],
        callback: this.parseCallback(template),
        value: this.parseValue(template)
      };
    };

    templater.prototype.parseCallback = function(template) {

      /*
      get callback 
      list of callbacks in config with function
       */
      var t;
      t = d3.keys(template)[0].split('.');
      if (t[1]) {
        return this.opts.callback[t[1]];
      } else {
        return function(d) {
          return d;
        };
      }
    };

    templater.prototype.parseValue = function(template) {

      /*
      parse template value
       */
      var t;
      t = d3.values(template)[0];
      if (typeof t === 'string') {
        if (t.slice(0, 6) === '@this') {

          /* d3.select(this).property( args ) */
          t = t[0] + t.slice(5);
          t = reduceKey(t, this.selection.node());
        } else if (t.slice(0, 3) === '@i') {

          /* index of the selection */
          t = this.data.index;
        } else if (t[0] === '@') {

          /* the data in the current selection */
          t = reduceKey(t, this.data.state);
        } else if (t[0] === ':') {

          /* :arg1.arg2 -- windows[arg1][arg2] */
          t = reduceKey(t, window);
        } else if (t[0] === '\\') {

          /* escape character */
          t = t.slice(1);
        }
      } else {
        t;
      }
      return t;
    };

    reduceKey = function(k, v) {

      /*
      Recurse through an object and return the value
       */
      return k.slice(1).split('.').reduce(function(p, n) {
        if (p[n]) {
          return p[n];
        } else {
          return p;
        }
      }, v);
    };

    return templater;

  })();

}).call(this);

//# sourceMappingURL=_d3.template.js.map
