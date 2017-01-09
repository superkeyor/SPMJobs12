// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

(function() {
// Bootstrap support for Dart scripts on the page as this script.
if (navigator.userAgent.indexOf('(Dart)') === -1) {
  // TODO:
  // - Support in-browser compilation.
  // - Handle inline Dart scripts.
  //console.log("OK now JS id="+window.location);
  var loc = new String(window.location.protocol);
  var r=loc.substr(0,4);
  var extra='.dart.js';
  
  if (r != "http" && r!="file")
    extra=".dart.precompiled.js";
     
  console.log('extra='+extra+", "+r+"("+loc+")"); 
    
  // Fall back to compiled JS. Run through all the scripts and
  // replace them if they have a type that indicate tha they source
  // in Dart code (type="application/dart").
  var scripts = document.getElementsByTagName("script");
  var length = scripts.length;
  for (var i = 0; i < length; ++i) {
    if (scripts[i].type == "application/dart") {
      // Remap foo.dart to foo.dart.js.
      if (scripts[i].src && scripts[i].src != '') {
        var script = document.createElement('script');
        script.src = scripts[i].src.replace(/\.dart(?=\?|$)/, extra);
        var parent = scripts[i].parentNode;
        // TODO(vsm): Find a solution for issue 8455 that works with more
        // than one script.
        document.currentScript = script;
        parent.replaceChild(script, scripts[i]);
      }
    }
  }
}
})();