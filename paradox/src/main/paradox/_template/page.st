<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$page.title$ | tachesimazzoca - Wiki</title>
<link href="$page.base$assets/lib/bootstrap-3.2.0/css/bootstrap.min.css" media="screen" rel="stylesheet" type="text/css">
<link href="$page.base$assets/stylesheets/style.css" media="screen" rel="stylesheet" type="text/css">
<script src="$page.base$assets/lib/jquery-1.11.1/jquery.min.js"></script>
<script src="$page.base$assets/lib/bootstrap-3.2.0/js/bootstrap.min.js"></script>
$gtm()$
</head>
<body>
<div id="wrapper">
  $header()$
  <div id="main">
    <div class="container-fluid">
      <div class="pankuzu">
        $page.breadcrumbs$
      </div>
    </div>
    <div class="container-fluid">
      <div class="row">
        <div class="col-md-3 col-sm-4 hidden-xs">
          <div id="navigation" data-spy="affix" data-offset-top="110" data-offset-bottom="100">
          $navigation()$
          </div>
        </div>
        <div class="col-md-9 col-sm-8">
          $if(page.source_url)$
          <div class="btn-group pull-right">
            <a class="btn btn-default" href="$page.source_url$">Source</a>
          </div>
          $endif$
          <div id="content">
          $page.content$
          </div>
        </div>
      </div>
    </div>
  </div>
  <!--/#main-->
  $footer()$
</div>
<!--/#wrapper-->
<style type="text/css">@import "$page.base$assets/lib/prettify/prettify.css";</style>
<script type="text/javascript" src="$page.base$assets/lib/prettify/prettify.js"></script>
<script type="text/javascript">
(function(jq) {
  jq(function(){
    window.prettyPrint && prettyPrint();
  });
})(window.jQuery);
</script>
</body>
</html>
