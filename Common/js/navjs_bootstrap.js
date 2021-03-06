window.navjs =
    (function() {
      var inst = {};
      inst.callbacks = {};
      inst.callId = 1000;
      
      inst.bootstrap = function () {
        var arr = document.getElementsByTagName('a');
        var len = arr.length;
        for(var i=0; i<len; i++) {
          var a = arr[i];
          var tgt = a.target;
          if(tgt && !!a.href) {
            a.href = 'navjs://localhost/url/open?href=' + escape(a.href) + '&target=' + escape(tgt);
          }
        }
        return inst;
      };

      // Print log information
      inst.log = function() {
        var msgs = [];
        for(var i=0; i<arguments.length; i++) {
          msgs.push(arguments[i]);
        }
        window.location = 'navjs://localhost/console/log?msg=' + escape(msgs.join(' '));
      };

      // Open a url by pushing a new navigation item
      inst.open = function(href, opts) {
        opts = opts || {}
        opts.target = opts.target || '_blank'
        opts.trans = opts.trans || 'push'
        var h = '';
        Object.keys(opts).forEach(function(k) {
          h += '&' + k + '=' + escape(opts[k]);
        })
        var loc = 'navjs://localhost/url/open?href=' + escape(href) + h;
        window.location = loc;
      };

      // Emit an event
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

      // Dispatch a event
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
      };

      inst.call = function(name, args, cb) {
        var arr = [];
        inst.callId++;
        var callId = 'c' + inst.callId;
        inst.callbacks[callId] = cb;

        Object.keys(args).forEach(function(k){
          var vs = args[k];
          if(!(vs instanceof Array)) {
            vs = [vs]
          }
          vs.forEach(function(v) {
            arr.push(k + '=' + escape(v))
          })
        })
        var loc = 'navjs://localhost/call/' + name + '/' + callId + '?' + arr.join('&');
        window.location = loc;
      };

      inst.callReturn = function(callId, result) {
        var cb = inst.callbacks[callId];
        if(cb) {
          Object.keys(result).forEach(function(k) {
            var v = result[k];
            if(v instanceof Array && v.length == 1) {
              result[k] = v[0];
            }
          });
          
          cb(result);
          delete inst.callbacks[callId];
        } else {
          inst.log('callback not found', callId);
        }
      };
      
      return inst;
    })().bootstrap();

// Tests

