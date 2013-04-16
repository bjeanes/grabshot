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
        $.post(rbApi, function(postbin) {
           var url = 'http://requestb.in/' + postbin.name;
           var link = '<a href="' + url + '?inspect">' + url + '</a>';
           var content = 'Using ' + link + ' as callback URL';
           form.find('small.note').html(content);
           grabshot(postbin);
         });

        return event.preventDefault();
      });
    }

    grabshot = function(postbin) {
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
                var data = $.parseJSON(data[0].body),
                attrs = {
                  src: 'data:image/png;base64,' + data.imageData,
                  alt: data.title,
                  width: 205,
                  height: 154
                },
                img = $('<img>').attr(attrs);

                $('#demo').append(img);
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
