(function($) {

  $.fn.flashcard = function(option) {

    option = option || {};

    var converter = option['converter'] || function(data) { return data; };

    var _escape = function(str) {
      return str.replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
    }
    var _foreach = function(xs, f) {
      var i;
      for (i = 0; i < xs.length; i++) {
        f(xs[i]);
      }
    }
    var _map = function(xs, f) {
      var i;
      var ys = [];
      for (i = 0; i < xs.length; i++) {
        ys[i] = f(xs[i]);
      }
      return ys;
    }

    var _renderer = function(rows) {
      var title = option['title'] || 'Untitled';
      var html = '<div class="carousel-inner">';
      html += '<div class="item active">';
      html += _escape(title);
      html += '</div>';
      _foreach(rows, function(row) {
         html += '<div class="item">';
         html += _escape(row);
         html += '</div>';
      });
      html += '</div>';
      html += '<a class="left carousel-control" role="button" data-slide="prev">';
      html += '<span class="glyphicon glyphicon-chevron-left"></span>';
      html += '</a>';
      html += '<a class="right carousel-control" role="button" data-slide="next">';
      html += '<span class="glyphicon glyphicon-chevron-right"></span>';
      html += '</a>';
      return html;
    }

    return this.each(function() {
      var url = option['dataUrl'] || this.getAttribute('data-url');
      var $elem = $(this);
      $.getJSON(url, function(data) {
        $elem.html(_renderer(converter(data)));
        $elem.carousel({
          interval: false
        });
        $elem.find('[data-slide=prev]').click(function() {
          $elem.carousel('prev');
        });
        $elem.find('[data-slide=next]').click(function() {
          $elem.carousel('next');
        });
      });
    });
  }
})(window.jQuery);
