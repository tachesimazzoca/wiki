---
layout: page 

title: Light Verbs
---

<table data-url="data/light_verbs.json" class="table">
</table>

<script src="{% relative_path path:'/assets/javascripts/jquery.ajaxtable.js' %}"></script>
<script type="text/javascript">
(function($) {
  $(function() {
    $('[data-url]').ajaxtable();
  });
})(window.jQuery);
</script>
