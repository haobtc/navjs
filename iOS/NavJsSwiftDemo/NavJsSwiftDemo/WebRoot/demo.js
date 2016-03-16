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

function callActionSheet() {
  navjs.emit("actionsheet.open",
             {"title": "Choose friend",
              "message": "Who would be the friend?",
              "cancel": "Cancel",
              "sequence": "123",
              "actions": ["Mike", "Jake", "Merry", "Rose"]});
  if(!window.boundActionSheet) {
    window.boundActionSheet = true;
    document.addEventListener('actionsheet.clicked', function(e) {
      if (e.args.title) {
        var span = document.getElementById('friend');
        span.innerHTML = 'Choosed ' + e.args.title;
      }
    });
  }
}
