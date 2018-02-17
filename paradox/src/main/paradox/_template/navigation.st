<div class="panel panel-default">
  <div class="panel-heading">
    <h3 class="panel-title" style="text-align: center; font-size: 11px; text-transform: uppercase; color: #999">Table of Contents</h3>
  </div>
  <div class="panel-body" id="jsNavigationHolder">
  </div>
  <div id="jsNavigationForest" style="display: none">
  $page.navigation$
  </div>
</div>
<script src="$page.base$assets/javascripts/jquery.toctree.js"></script>
<script type="text/javascript">
(function(jq) {
  jq(function() {
    jq('#jsNavigationHolder').toctree({ selector: '#content :header', offset: 1, depth: 1 });
  });
})(window.jQuery);
</script>
<!--
<script type="text/javascript">
(function(jq) {
  jq(function() {
    var navbase = jq('.pankuzu > ul > li:nth-child(2)').text();
    jq('#jsNavigationHolder').html(
      jq('#jsNavigationForest > ul > li > a[class="page"]:contains("' +navbase + '")').parent().html()
    )
  });
})(window.jQuery);
</script>
<script type="text/javascript">
(function(jq) {
  jq(function() {
    if (!window.location.pathname.match(/\/index.html\$/)) {
      jq('h1').after('<div id="toc"></div>');
      jq('#toc').toctree({ selector: '#content :header', offset: 1, depth: 1 });
    }
  });
})(window.jQuery);
</script>
-->
