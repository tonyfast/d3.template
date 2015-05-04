d3.getScript = (src, callback) ->
  #{http://stackoverflow.com/questions/16839698/jquery-getscript-alternative-in-native-javascript}
  script = document.createElement 'script'
  #{script.async = 1}
  prior = document.getElementsByTagName('script')[0]
  prior.parentNode.insertBefore script, prior
  script.onload = script.onreadystatechange = ( _, isAbort ) ->
    if isAbort or not script.readyState or /loaded|complete/.test script.readyState
      script.onload = script.onreadystatechange = null
      script = undefined

      unless isAbort
        if callback
          callback()
  script.src = src  