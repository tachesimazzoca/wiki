---
layout: page

title: Action Verbs
---

<table data-url="data/action_verbs.json" class="table">
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
