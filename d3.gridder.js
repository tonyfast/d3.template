(function() {
  d3.select('body').append('div').style('width', 60).style('height', 60).style('position', 'fixed').style('right', 0).style('top', 0).style('background-color', 'green').style('z-index', 100).text('show data').style('opacity', '.6').on('click', function() {
    return d3.select(this).datum(function(d) {
      if (d) {
        if (d['active']) {
          d = {
            active: false
          };
          return d3.select('#overlay').remove();
        } else {
          return d = {
            active: true
          };
        }
      } else {
        return d = {
          active: true
        };
      }
    }).call(function(s) {
      console.log(s.data());
      if (s.datum()['active']) {
        return d3.gridder('body');
      }
    });
  });

  d3.gridder = function(el) {
    var children, d, h, overlay, w;
    children = function(s, d) {
      var n;
      n = [].slice.call(s.node().children);
      n.forEach(function(n) {
        if (d3.select(n).datum()) {
          d.push(n.getBoundingClientRect());
        }
        return d = children(d3.select(n), d);
      });
      return d;
    };
    d = [];
    d3.select(el).call(function(s) {
      return d = children(s, []);
    });
    w = d3.max(d, function(d) {
      return d['right'];
    });
    h = d3.max(d, function(d) {
      return d['bottom'];
    });
    return overlay = d3.select('body').append('svg').attr('id', 'overlay').attr('width', w).attr('height', h).style('position', 'absolute').style('top', 0).style('left', 0).selectAll('rect').data(d).enter().append('rect').each(function(d, i) {
      return d3.select(this).attr('x', d['left']).attr('y', d['top']).attr('width', d['width']).attr('height', d['height']).style('fill', 'blue').style('stroke', 'black').style('stroke-width', 2).style('opacity', '.1');
    });
  };

}).call(this);
