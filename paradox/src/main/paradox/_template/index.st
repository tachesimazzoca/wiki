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
    $if (!page.home.active)$
    <div class="container-fluid">
      <div class="pankuzu">
        $page.breadcrumbs$
      </div>
    </div>
    $endif$
    <div class="container-fluid">
      <div class="row">
        <div class="col-md-12">
          $if (page.source_url)$
          <div class="btn-group pull-right">
            <a class="btn btn-default" href="$page.source_url$">Source</a>
          </div>
          $endif$
          $page.content$
        </div>
      </div>
    </div>
  </div>
  <!--/#main-->
  $footer()$
</div>
<!--/#wrapper-->
</body>
</html>
