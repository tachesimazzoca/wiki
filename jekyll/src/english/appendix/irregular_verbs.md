---
layout: page

title: Irregualr Verbs
---

<table data-url="data/irregular_verbs.json" class="table">
</table>

<script src="{% relative_path path:'/assets/javascripts/jquery.ajaxtable.js' %}"></script>
<script type="text/javascript">
(function($) {
  $(function() {
    $('[data-url]').ajaxtable();
  });
})(window.jQuery);
</script>
---
