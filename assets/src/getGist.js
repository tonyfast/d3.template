getGist = function(gistid){
  $.ajax({
    url: 'https://api.github.com/gists/'+gistid,
    type: 'GET',
    dataType: 'jsonp'
  }).success( function(gistdata) {
    // This can be less complicated if you know the gist file name
    var objects = [];
    for (file in gistdata.data.files) {
      if (gistdata.data.files.hasOwnProperty(file)) {
        var o = JSON.parse(gistdata.data.files[file].content);
        if (o) {
          objects.push(o);
        }
      }
    }
    if (objects.length > 0) {
      // DoSomethingWith(objects[0])
    }
  }).error( function(e) {
    // ajax error
  });
}

