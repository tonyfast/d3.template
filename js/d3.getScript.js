// Generated by CoffeeScript 1.9.2
(function() {
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
