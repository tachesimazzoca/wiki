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
<script src="$page.base$assets/javascripts/jquery.ajaxtable.js"></script>
<script src="$page.base$assets/javascripts/jquery.flashcard.js"></script>
<script type="text/javascript">
(function(jq) {
  jq(function() {
    jq('#jsFlashcardTable').ajaxtable({
      dataUrl: '$page.properties.("data_url")$'
    });
    jq('#jsJpEnFlashcardCarousel').flashcard({
      title: '$page.title$',
      dataUrl: '$page.properties.("data_url")$',
      converter: function(data) {
        var i;
        var rows = data['rows'];
        rows.sort(function(a, b) {
          return Math.random() - 0.5;
        });
        var items = [];
        for (i = 0; i < rows.length; i++) {
          items.push(rows[i]['definition']);
          items.push(rows[i]['term']);
        }
        return items;
      }
    });
  });
})(window.jQuery);
</script>
<style type="text/css">
<!--
.flashcard .carousel-inner .item {
  padding: 30px;
  font-size: 24px;
  font-weight: bold;
  text-align: center;
}
.flashcard a.carousel-control {
  background-image: none;
}
-->
</style>
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
        <div class="col-md-12">
          $if(page.source_url)$
          <div class="btn-group pull-right">
            <a class="btn btn-default" href="$page.source_url$">Source</a>
          </div>
          $endif$
          <div id="content">
            $page.content$
            <button type="button" class="btn btn-success"
                data-toggle="modal" data-target="#jsJpEnFlashcard">Flashcard</button>
            <div id="jsJpEnFlashcard" class="modal fade" tabindex="-1" role="dialog">
              <div class="modal-dialog">
                <div class="modal-content">
                  <div class="modal-body">
                    <div id="jsJpEnFlashcardCarousel" class="flashcard slide"></div>
                  </div>
                </div>
              </div>
            </div>
            <table id="jsFlashcardTable" class="table">
            </table>
          </div><!--/#content-->
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
