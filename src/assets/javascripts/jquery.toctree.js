(function($) {

    $.fn.toctree = function(option) {

        option = option || {};
        option.selector = option.selector || ':header';
        option.offset = parseInt(option.offset) || 0;
        option.depth = parseInt(option.depth) || 3;
        option.prefix = option.prefix || 'toctree-';

        var $toc = this;

        var ul = $toc.append('<ul></ul>').children('ul');

        var last = 1;
        var section = '';
        var counter = 0;

        return this.each(function() {
            $(option.selector).each(function() {
                var num = parseInt(this.tagName.replace(/^h([1-6])$/i, '$1'));
                if (num == NaN || num <= option.offset || option.depth < num - option.offset) {
                    return;
                }
                var $header = $(this);
                if (last != num) {
                    ul = $toc.children('ul');
                    section = '';
                    for (var n = 1; n < (num - option.offset); n++) {
                        if (ul.find('> li:last').length === 0) {
                            ul.append('<li><ul></ul></li>');
                        }
                        if (ul.find('> li:last > ul').length === 0) {
                            ul.find('> li:last').append('<ul></ul>');
                        }
                        section += ul.find('> li').length + '-';
                        ul = ul.find('> li:last').children('ul');
                    }
                    counter = ul.find('> li').length;
                }
                counter++;
                anchor = option.prefix + section + counter;
                ul.append('<li><a href="#' + anchor + '">' + $header.text() + '</a></li>');
                $header.before('<a id="' + anchor + '"></a>');
                last = num;
            });
        });
    }
})(window.jQuery);
