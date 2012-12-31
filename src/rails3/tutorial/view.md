---
layout: page 

title: Views 
---

## ERB テンプレート 

ビュー生成には ERB が用いられます。PHP のように Ruby 構文を含めることができます。

    <ul>
      <% 1.upto(10) do |n| %>
      <li><%= sprintf('Item %d', n) %></li>
      <% end %>
    </ul>

    <% time = Time.new %>
    Last updated at <%= time.strftime('%Y/%m/%d') %>

    <%# これはコメントブロックです。出力されません %>

Rails3 からはデフォルトでHTMLエスケープされた結果が出力されます。HTMLエスケープをスキップするには `raw` メゾッドを使います

    <!-- &lt;strong&gt;foo&lt;/strong&gt; -->
    <%= '<strong>foo<strong>' %>

    <!-- <strong>foo</strong> -->
    <%= raw '<strong>foo<strong>' %>
    <!-- <%== .... %> 構文も使えます -->
    <%== '<strong>foo<strong>' %>


## テンプレートからレイアウトテンプレートにコンテンツを渡す

* [ActionView::Helpers::CaptureHelper](http://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html) 

`content_for` メゾッドを使います。

`app/views/(:controller)/(:action).html.erb`:

    <% content_for :link do %>
    <link rel="next" href="..." />
    <link rel="prev" href="..." />
    <% end %>
    <% content_for :title do %>Home<% end %>
    <h1><%= content_for :title %></h1>

`app/views/layouts/*.html.erb`:

    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title><%= content_for?(:title) ? sprintf('%s | Sandbox', (yield :title)) : 'Sandbox' %></title>
      <%= yield :link >
    </head>
    <body>
    <%= yield %>
    </body>
    </html>

## 他ファイルのインクルード

* [ActionView::Helpers::RenderingHelper](http://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html) 
* [ActionView::PartialRenderer](http://api.rubyonrails.org/classes/ActionView/PartialRenderer.html)

`render` メゾッドにより他のファイルを差し込むことができます。

`app/views/(:controller)/_(name_of_partial).html.erb` のように先頭にアンダースコアを付与したファイル名を読み込みます。

    <!-- app/views/(:controller)/_item.html.erb -->
    <%= render :partial => 'item' %>

    <!-- app/views/layouts/_navs.html.erb -->
    <%= render :partial => 'layouts/navs' %>

`:locals` により、インクルードファイルに変数を渡すことができます。

      ....
      <%= render :partial => 'layouts/footer', :locals => { :time => Time.new } %>
      </body>
    </html>

`app/views/layouts/_footer.html.erb`:

    <div class="footer">Last updated: <%= time.strftime('%Y/%m/%d') %></div>

`:collection` でリストを渡して繰り返すことができます。`:partial` で指定した `item` がローカル変数として割り当てられます。`(partial_name)_counter` にはリストのインデックス値が割り当てられます。

    <%= render :partial => 'item', :collection => @items %>

`app/views/(:controller)/_item.html.erb`:

    <li><%= item_counter + 1 >. <%= item %></li>

partial_name を明示的に指定するには `:as` で指定します。

    <%= render :partial => 'product', :collection => @products, :as => 'element' %>


## URLの一元管理

* [ActionView::Helpers::UrlHelper](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html) 

`url_for` メゾッドで `config/routes.rb` で設定したマッピングで URL を取得できます。

    <%= url_for :controller => 'pages', :action => 'help', :format => 'html' %>

`(name_of_route)_path` `(name_of_route)_url` メゾッドで指定することもできます。

    <!-- /pages/help.html -->
    <%= pages_help_path(:format => 'html') %>

    <!-- http://www.exmaple.net/pages/help.html -->
    <%= pages_help_url(:format => 'html') %> #

`link_to` メゾッドでリンク記述を簡略化できます。

    <%= link_to :controller => 'pages', :action => 'help', :format => 'html' do %>Help<% end %>
    <%= link_to 'Back To Home', pages_home_path(:format => 'html') %>

