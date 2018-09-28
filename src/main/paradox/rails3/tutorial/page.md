# HTMLページ出力

## ページ出力フロー

`config/routes.rb` でURLマッピングを設定します。

    Sandbox::Application.routes.draw do
      match 'pages/home' => "pages#home", :as => pages_home
    end


上記例では URL `pages/home` に対し、`pages` コントローラの `home` アクションにマッピングし `pages_home` という設定名を付けています。`rake routes` コマンドで設定を確認できます。

    % bundle exec rake routes
    pages_home GET /pages/home(.:format) pages#home

`match ':controller/:action' => '(:controller)#(:action)'. :as => (:controller)_(:action)` のフォーマットであれば、以下のように省略できます。

    Sandbox::Application.routes.draw do
      match 'pages/home'
    end

`app/controllers/pages_controller.rb` を作成し home メソッドを定義します。

    class PagesController < ApplicationController
      def home
      end
    end

テンプレート `app/views/pages/home.html.erb` を作成します。

    <h1>Home</h1>
    <p>Hello World!</p>

レイアウトテンプレート `app/views/layouts/application.html.erb` を作成します。`yield` 文の箇所に `app/views/pages/home.html.erb` が差し込まれます。

    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Sandbox</title>
    </head>
    <body>
    <%= yield %>
    </body>
    </html>

`/pages/home` または `/pages/home.html` で作成したページが表示されることがわかります。

このページをルートURL `/` で表示させてみましょう。`public/index.html` が存在するとこのファイルが表示されますので削除しておきます。

    % rm public/index.html

`root :to => '(:controller)#(:action)'` と指定すると、URL `/` で表示されることが確認できます。

    Sandbox::Application.routes.draw do
      root :to => 'pages#home'
    end
