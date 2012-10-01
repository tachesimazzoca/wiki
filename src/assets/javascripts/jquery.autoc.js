(function($) {

    $.fn.toc = function(option) {

        options = option || {};
        option.offset = parseInt(option.offset) || 0;
        option.depth = parseInt(option.depth) || 3;
        option.selector = option.selector || ':header';

        var toc = this;

        var ul = toc.append('<ul></ul>').children('ul');

        var last = 1;
        var section = '';
        var counter = 0;

        return this.each(function() {
            $(option.selector).each(function() {
                var num = parseInt(this.tagName.replace(/^h([1-6])$/i, '$1'));
                if (num == NaN || num <= option.offset || option.depth < num - option.offset) {
                    return;
                }
                var header = $(this);
                if (last != num) {
                    ul = toc.children('ul');
                    section = '';
                    counter = 0;
                    for (var n = 1; n < (num - option.offset); n++) {
                        if (ul.find('> li:last').length === 0) {
                            ul.append('<li><ul></ul></li>');
                        }
                        if (ul.find('> li:last > ul').length === 0) {
                            ul.find('> li:last').append('<ul></ul>');
                        }
                        section += ul.find('> li').length + '_';
                        ul = ul.find('> li:last').children('ul');
                    }
                }
                counter++;
                anchor = 'section_' + section + counter;
                ul.append('<li><a href="#' + anchor + '">' + $(this).text() + '</a></li>');
                header.before('<a id="' + anchor + '"></a>');
                last = num;
            });
        });
    }
})(window.jQuery);
