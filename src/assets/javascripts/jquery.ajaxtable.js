(function($) {

  $.fn.ajaxtable = function(option) {

    option = option || {};
    var converter = option['converter'] || function(data) { return data };

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

    var _tableRenderer = function(data) {
      var html = '';
      var fields = data['fields'] || [];
      var rows = data['rows'] || [];
      if (fields.length > 0) {
        html += '<thead>';
        _foreach(fields, function(x) {
          html += '<th>';
          html += _escape(x['name']);
          html += '</th>';
        });
        html += '</thead>';
      }
      _foreach(rows, function(row) {
        html += '<tr>';
        var keys = _map(fields, function(field) {
          return field['key'];
        });
        _foreach(keys, function(key) {
          html += '<td>';
          html += _escape(row[key]);
          html += '</td>';
        });
        html += '</tr>';
      });
      return html;
    }

    return this.each(function() {
      var url = this.getAttribute('data-url');
      var renderer;
      if (this.tagName.toLowerCase() == 'table') {
        renderer = _tableRenderer;
      } else {
        return;
      }
      var $elem = $(this);
      $.getJSON(url, function(data) {
        $elem.html(renderer(converter(data)));
      });
    });
  }
})(window.jQuery);
