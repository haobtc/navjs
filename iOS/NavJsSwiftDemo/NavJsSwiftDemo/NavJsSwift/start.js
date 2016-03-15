
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
    return inst;
})()

navjs.log("hello", "world", "bridge ok");