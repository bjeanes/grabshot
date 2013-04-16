(function($) {
  $(function() {
    var grabshot,
        rbApi = 'http://requestb.in/api/v1/bins',
        form = $('#demo form');

    if(!$.support.cors) {
      form.hide();
      return;
    } else {
      $('#demo .alert.cors').hide();

      form.on('submit', function(event) {
        var img = $('<img>').attr({
          'data-src': 'holder.js/205x154/text:Fetching...'
        }).appendTo($('#demo .output'));

        Holder.run();

        $.post(rbApi, function(postbin) {
           var url = 'http://requestb.in/' + postbin.name;
           var link = '<a href="' + url + '?inspect">' + url + '</a>';
           var content = 'Using ' + link + ' as callback URL';
           form.find('small.note').html(content);
           grabshot(postbin, img);
         });

        return event.preventDefault();
      });
    }

    grabshot = function(postbin, img) {
      var binUrl = rbApi + '/' + postbin.name;

      var params = {
        url: form.find('input[name="url"]').val(),
        callback: 'http://requestb.in/' + postbin.name,
        height: form.find('input[name="height"]').val(),
        width: form.find('input[name="width"]').val()
      };

      $.post('/snap', params, function() {
        var fn = function() {
          $.get(binUrl, function(data) {
            if(data["request_count"] > 0) {
              $.get(binUrl + '/requests', function(data) {
                var data = $.parseJSON(data[0].body);
                img.attr({
                  src: 'data:image/png;base64,' + data.imageData,
                  'data-src': null,
                  alt: data.title
                });
              });
            } else {
              window.setTimeout(fn, 100);
            }
          });
        };
        window.setTimeout(fn, 100);
      });
    }

  });
})(jQuery);
