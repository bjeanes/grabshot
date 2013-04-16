var page = require('webpage').create(),
    system = require('system'),
    fs = require('fs');

var userAgent = "Grabshot"

var url  = system.args[1];
var format = system.args[2] || "PNG"

page.viewportSize = {
  width: 1280
  // height: ...
}

function render() {
  result = {
    title: page.evaluate(function() { return document.title }),
    imageData: page.renderBase64(format),
    format: format
  }

  console.log(JSON.stringify(result))
  phantom.exit();
}

page.onError = phantom.onError = function() {
  console.log("PhantomJS error :(");
  phantom.exit(1);
};

page.onLoadFinished = function (status) {
  if (status !== 'success') {
    phantom.exit(1);
  }

  setTimeout(render, 300);
}

page.open(url);
