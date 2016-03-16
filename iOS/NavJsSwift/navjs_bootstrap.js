
//document.body.innerHTML += "<p>haobtc.inc</p>";

(function () {
  var arr = document.getElementsByTagName('a');
  var len = arr.length;
  for(var i=0; i<len; i++) {
    var a = arr[i];
    var tgt = a.target;
    if(tgt && !!a.href) {
      console.info(a);
      a.href = 'navjs://localhost/url/open?u=' + escape(a.href) + '&tgt=' + escape(tgt);
      console.info('xxx', a);
    }
  }
})()

var navjs =
    (function() {
      var inst = {};
      inst.log = function() {
        var msgs = [];
        for(var i=0; i<arguments.length; i++) {
          msgs.push(arguments[i]);
        }
        window.location = 'navjs://localhost/console/log?msg=' + escape(msgs.join(" "));
      };
      inst.open = function(href, target) {
        target = target || '_blank';
        window.location = 'navjs://localhost/url/open?u=' + escape(href) + '&gt=' + escape(target);
      };
      
      inst.emit = function(name, args) {
        var arr = [];
        Object.keys(args).forEach(function(k){
          var vs = args[k];
          if(!(vs instanceof Array)) {
            vs = [vs]
          }
          vs.forEach(function(v) {
            arr.push(k + '=' + escape(v))
          })
        })
        var loc = 'navjs://localhost/event/' + name + '?' + arr.join('&');
        window.location = loc;
      };
      
      inst.dispatch = function(name, args) {
        Object.keys(args).forEach(function(k) {
          var v = args[k];
          if(v instanceof Array && v.length == 1) {
            args[k] = v[0];
          }
        });
        var evt = new Event(name);
        evt.args = args;
        document.dispatchEvent(evt);
      }
      return inst;
    })()

// Tests
/*
  navjs.log("hello", "world", "bridge ok");

  navjs.emit("hello", {mygoods: "pipi", nick: 234})

  document.addEventListener('hello', function(e) {
    navjs.log("event received hello", e.args.text);
    document.body.innerHTML += JSON.stringify(e.args);
  }, false)
*/
