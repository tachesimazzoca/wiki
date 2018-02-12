<div class="panel panel-default">
  <div class="panel-heading">
    <h3 class="panel-title" style="text-align: center; font-size: 11px; text-transform: uppercase; color: #999">Table of Contents</h3>
  </div>
  <div class="panel-body">
    <div id="toc"></div>
  </div>
</div>
<script src="$page.base$assets/javascripts/jquery.toctree.js"></script>
<script type="text/javascript">
(function(jq) {
  jq(function() {
    jq('#toc').toctree({ selector:'#content :header', offset:1, depth:1 });
  });
})(window.jQuery);
</script>
