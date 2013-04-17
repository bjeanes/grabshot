var page = require('webpage').create(),
    system = require('system'),
    fs = require('fs');

setTimeout(function() {
  phantom.exit(1);
}, 2000);

var userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17';

var url    = system.args[1];
var format = system.args[2] || "PNG";
var width  = parseInt(system.args[3]) || 1280;
var height = parseInt(system.args[4]); // default: fit content
var crop   = true;

// NOTE: This does not work as "window" size, so height will
// not do as expected here.
//
// See https://github.com/ariya/phantomjs/issues/10619
page.viewportSize = {
  width: width,
  height: height
};

page.customHeaders = {
  Referer: url
};

page.settings.userAgent = userAgent;

function render() {
  var result = page.evaluate(function () {
    return {
      title: document.title,
      width: document.body.clientWidth,
      height: document.body.clientHeight,
    };
  });

  if(crop && height && result.height > height) {
    // Cropping isn't exactly what we want, but PhantomJS does
    // not yet have a "window size" concept (See NOTE above).
    page.clipRect = {
      top: 0,
      left: 0,
      width: width,
      height: height
    };

    result.height = height;
    result.width  = width;
  }

  result.imageData = page.renderBase64(format);
  result.format = format;

  console.log(JSON.stringify(result));
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
};

page.open(url);
