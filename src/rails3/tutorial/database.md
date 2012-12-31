---
layout: page 

title: データベース操作
---
## データベース設定 

`config/database.yml` にデータベースの設定を記述します。

`mysql2` アダプタを用いた場合の記述例です。
    
    development:
      adapter: mysql2
      encoding: utf8
      reconnect: false
      database: sandbox_development
      pool: 5
      username: root
      password:
      socket: /var/lib/mysql/mysql.sock
    
    test:
      adapter: mysql2
      encoding: utf8
      reconnect: false
      database: sandbox_test
      pool: 5
      username: root 
      password:
      socket: /var/lib/mysql/mysql.sock
    
    production:
      adapter: mysql2
      encoding: utf8
      reconnect: false
      database: sandbox
      pool: 5
      username: root 
      password:
      socket: /var/lib/mysql/mysql.sock

[ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html) の [establish_connection](http://api.rubyonrails.org/classes/ActiveRecord/Base.html#method-c-establish_connection) メゾッドを通じて、この設定ファイルが読み込まれます。

    #!/usr/bin/env ruby

    require ::File.expand_path('../config/boot',  __FILE__)
    require "active_record"

    ActiveRecord::Base.establish_connection(YAML.load_file('/path/to/rails/config/database.yml')['development'])

    adapter = ActiveRecord::Base.connection
    result_set = adapter.exec_query("SELECT * FROM users")
    ....

## Active Record Migraions

[ActiveRecord::Migration](http://api.rubyonrails.org/classes/ActiveRecord/Migration.html) の仕組みを用いてデータベース管理を容易にします。

### データベース作成/削除 

設定したユーザに、データベース作成権限があれば、`rake` コマンドで作成/削除ができます。

    # データベース作成
    % bundle exec rake db:create
    # データベース削除
    % bundle exec rake db:drop

### テーブル作成 

`db/migrate/(バージョン番号)_create_(テーブル名).rb` の命名規則でファイルを作成します。

`products` テーブルを例にします。

`db/migrate/1_create_products.rb`

    class CreateProducts < ActiveRecord::Migration
      def change
        create_table(:products, :primary_key => 'id') do |t|
          t.string :code, :null => false, :default => ''
          t.string :name, :null => false, :default => ''
          t.text :description
          t.integer :price, :null => false, :default => 0 
          t.datetime :open_date
          t.datetime :close_date
          t.timestamp :deleted_at

          t.timestamps
        end
      end
    end

`db:migrate` でテーブルを作成します。

    % bundle exec rake db:migrate

間違えた場合は `db:rollback` でやり直すことができます。 

    % bundle exec rake db:rollback
    % vim db/migrate/1_create_products.rb
    ....
    % bundle exec rake db:migrate

