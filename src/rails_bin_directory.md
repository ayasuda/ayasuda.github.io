---
title: 'rails new するとできる bin ディレクトリまとめ'
description: 'rails new するとできる bin ディレクトリの役割と、それぞれの内容についてメモ程度にまとめてみました。'
date: '2017-11-06'
keywords:
  - rails
  - script
  - binstub
---

# Rails の各種コマンドは bin ディレクトリから

`rails new APP` すると出来上がる rails プロジェクトでは、
ルートディレクトリに `bin` ディレクトリが生成されます。

この中には、サーバを起動したり、テストをしたり、アプリケションを管理する
様々なスクリプトファイルが置かれます。

```
$ ls bin
bundle  rails   rake    setup   spring  update  yarn
```

この文書では、これらのコマンドそれぞれの役割についてまとめてみたいと思います。

## そもそも論の binstub

詳しくは [rbenv/rbenv/wiki/Understanding-binstubs](https://github.com/rbenv/rbenv/wiki/Understanding-binstubs) を
見るのが良いでしょう。

binstub は実行可能なラッパースクリプトです。

複数の Rails プロジェクトをメンテナンスしていたり、その他の ruby プロジェクトを行き来していると
例えば、それぞれのプロジェクトで `rspec` のバージョンが違ったりして、システムにインストールした
`rspec` をそのまま使うのが辛いシチュなどがざらにあります。

そこで登場するのが binstub で、要するに、プロジェクトごとに `bin/rspec` みたいなラッパースクリプトを用意して
ラッパーの中で必要な環境を整えてから、`rspec` を起動させようとします。

例えば、 Rails 4.2.8 で作ったプロジェクト foo と Rails 5.1.4 で作ったプロジェクト bar がある時、
binstub 経由でそれぞれのバージョンを確認すると、次のようにいい感じにバージョンが表示されるのがわかるかと思います。

```
$ cd path/to/foo
$ ./bin/rails --version
Rails 4.2.8
$ cd path/to/bar
$ ./bin/rails --version
Rails 5.1.4
```

そんなわけで、 Rails プロジェクトでは binstub がデフォルトで作成されています。

## bundle, rails, rake, spring, yarn

説明不要ですね。

それぞれ

* [bundler](http://bundler.io/)
* [rails](http://rubyonrails.org/)
* [rake](https://github.com/ruby/rake)
* [spring](https://github.com/rails/spring)
* [yarn](https://yarnpkg.com/ja/)

の binstub です。

## setup

Rails が用意する、「アプリケーションを初期化するスクリプト」です。

[プルリクエスト](https://github.com/rails/rails/pull/15189) を見れば意図は明白ですが、
ある Rails プロジェクトをコピー・クローン・チェックアウトなどした後のセットアップをこのスクリプトに納めさせしむものです。

ですので、このスクリプトをきちんと書くことで、例えばこの２コマンドで rails プロジェクトの初期化ができるようになります。

```
$ git clone path/to/your/rails/project
$ cd project
$ bin/setup
# bundle install
# rake db:setup
# other steps...
```

実際のところは、デフォルトで最小限のセットアップ構成が書かれているだけです。

短いので以下にファイルを転載します。ご覧の通り、本当に最小限のスクリプトです。
このスクリプトをメンテナンスすることで、プロジェクトに新しいメンバーがアサインされた際などの手間が省けます。

```ruby
#!/usr/bin/env ruby
require 'pathname'
require 'fileutils'
include FileUtils

# アプリケーションのルートパス
APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

chdir APP_ROOT do
  # このスクリプトはアプリケーションのセットアップの第一ステップとなります。
  # ですので、必要なステップをこのファイルに追加していってください

  puts '== Installing dependencies =='
  system! 'gem install bundler --conservative'
  system('bundle check') || system!('bundle install')

  # JavaScript の依存ライブラリを yarn を使ってインストールします
  # system('bin/yarn')


  # puts "\n== Copying sample files =="
  # unless File.exist?('config/database.yml')
  #   cp 'config/database.yml.sample', 'config/database.yml'
  # end

  puts "\n== Preparing database =="
  system! 'bin/rails db:setup'

  puts "\n== Removing old logs and tempfiles =="
  system! 'bin/rails log:clear tmp:clear'

  puts "\n== Restarting application server =="
  system! 'bin/rails restart'
end
```

## update

Rails が用意する、「アプリケーションを更新するスクリプト」です。

[プルリクエスト](https://github.com/rails/rails/pull/20972) を見れば意図は明白ですが、
ある Rails プロジェクトを更新、例えば `git pull origin` した後などに、変更されたすべてを更新させるスクリプトです。

ですので、このスクリプトをきちんと書くことで、例えばこの２コマンドで rails プロジェクトの更新ができるようになります。

```
$ git pull origin master
$ bin/update
# gem の更新
# rake db:migrate
# ログの更新
# rails のリスタート
```

このスクリプトも setup と同じく大変短いスクリプトです。
面倒臭がらずにきちんとメンテナンスすることで、チーム開発に *大変役立ちます* ので、ぜひ運用してください。

## Scripts To Rule Them All

セットアップ方法や更新方法を１スクリプトにまとめようというのは、様々なプロジェクトでよく見られる光景です。
しかしながら、どのようなスクリプトを用意すれば良いかについては、往々にして必要になってから考案されます。

GitHub 社が社内で用意している、プロジェクト管理用のスクリプトと運用方法についてまとめたのが
[Scripts to Rule Them All | GitHub Engineering](https://githubengineering.com/scripts-to-rule-them-all/) です。

GitHub社でも社内で様々なプロジェクトを開発しているようで、それらのプロジェクトを `git clone` してから
開発環境で立ち上げ、そして各種作業をするためのコマンドを統一することでエンジニアの負荷を下げています。

大抵のプロジェクトでは、エンジニアは次の４つのタスクを必ず行います。

* 開発環境の立ち上げ
* テストの実行
* CI の実行
* アプリの起動

GitHub社ではこれらの作業を標準化するために、すべてのプロジェクトで同じコマンドを用意しています。
これが「Script to Rule Tehm All」とのことです。

さて、彼らは具体的には７つのスクリプトを用いています。

* `script/bootstrap` : すべての依存ライブラリをインストール・更新する
* `script/setup` : プロジェクトをセットアップする（クローン直後に使用する）
* `script/update` : プロジェクトを更新する
* `script/server` : アプリをスタートする
* `script/test` : すべてのテストを実行する
* `script/cibuild` : CI サーバが実行し、すべてのテストを実行する
* `script/console` : コンソールを開く

このようなスクリプトをきちんと用意すれば、初めてアサインされたプロジェクトでも
すぐにアプリを立ち上げられ、テストを動かせ、そしてコンソールでデータの操作ができます。

GitHub 社はこのパターンについての指針などをまとめたリポジトリを
[github/scripts-to-rule-them-all](https://github.com/github/scripts-to-rule-them-all) として
公開していますので、是非ご覧になってください。

[bin/update を追加したプルリクエスト](https://github.com/rails/rails/pull/20972) を見れば意図は明白ですが、

## なんで script ディレクトリじゃないの？

`script/` が廃止され、`bin/` が導入されたのは Rails 4.0 からです。

実際に導入された [プルリクエスト](https://github.com/rails/rails/pull/8786) を見るとわかりますが、
binstub に合わせた為です。

## direnv 使って楽するといいと思うよ

binstub のお供に最適なのが [direnv](https://direnv.net/) です。

このツールはとても単純で、「特定のディレクトリに cd すると、設定された profile を読み込む」というツールなのですが、

このツールを使って、 PATH に `RAILS_ROOT/bin` を追加することで、例えば、 `rails` コマンドや `bundle` コマンドを自然に使えるようになります。
