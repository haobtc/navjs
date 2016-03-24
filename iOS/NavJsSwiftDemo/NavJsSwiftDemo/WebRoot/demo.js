function runDemo() {
  navjs.log("hello", "world", "bridge ok");
  
  navjs.emit("hello", {mygoods: "pipi", nick: 234})

  if(!window.boundHello) {
    window.boundHello = true;
    document.addEventListener('hello', function(e) {
      navjs.log("event received hello", e.args.text);
      document.body.innerHTML += JSON.stringify(e.args);
    }, false);
  }
}

function callAdd() {
  navjs.call("add", {a: 3, b: 5}, function(res) {
    document.body.innerHTML += JSON.stringify(res);
  });
}

function callActionSheet() {
  navjs.call("menu.open",
             {"title": "Choose friend",
              "message": "Who would be the friend?",
              "cancel": "Cancel Name",
              "sequence": "123",
              "actions": ["Mike", "Jake", "Merry", "Rose"]}, function(res) {
               var span = document.getElementById('friend');
               if (res.title) {
                 span.innerHTML = 'Choosed ' + res.title;
               } else if(res.cancel) {
                 span.innerHTML = 'Choosed None';
               }
             });
}
