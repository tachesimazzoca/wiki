---
layout: page

title: Idioms
---

<table data-url="data/idioms.json" class="table">
</table>

<script src="{% relative_path path:'/assets/javascripts/jquery.ajaxtable.js' %}"></script>
<script type="text/javascript">
(function($) {
  $(function() {
    $('[data-url]').ajaxtable();
  });
})(window.jQuery);
</script>
