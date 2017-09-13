１ファイルくらいのスクリプト向け bundler
====

ruby のパッケージ管理ツール [Bundler](http://bundler.io/) はとても便利です。
便利ですが、ちょっとした、ちょうど 1 ファイルくらいの軽量スクリプト書くときには、いちいち `Gemfile` を書いたりするのは面倒です。
そんな時、たいていの場合は bundler を使わず、普通に `gem install hogehoge` みたいにライブラリをインストールし、
`require 'hogehoge'` してライブラリを読み込んでいるかと思います。
でも、たまたまこのスクリプトファイルを共有する時とかに、ライブラリのバージョン差異が出て地味に不便なんですよね。

そんなわけで、 Bundler にはインラインで依存ライブラリを指定する記法が用意されています。

https://github.com/bundler/bundler-features/issues/47

です。　

・・・この issue を読むと、誕生背景やサンプルコード、実装内容に制限事項が網羅されているので解説など不要な気がしますが、
将来の自分のために日本語でまとめておきましょう。
なお、詳しい情報は [APIドキュメント](https://github.com/bundler/bundler/blob/master/lib/bundler/inline.rb) に載っていますので、
使いたい方はそちらをご参照ください。

```rb
#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'to_gunma', '0,0.2'
end

array = [1,2,3]
array.to_gunma!
puts array.to_s
```

上記に示すサンプルコードのように、 `require 'bundler/inline'` することで
インラインで Gemfile を宣言する `gemfile` メソッドを使えるようになります。

このファイルを実行する環境で gem がインストール済みであれば、 `gemfile` メソッドのブロック内で定義した
ライブラリを自動的に require までしてくれます。

また、第一引数に `true` を設定することで、未インストールの時に自動的にインストールまでしてくれます。

使いみち
-----

サンプルコードを gist に貼ったりするときのお供にどうぞ！
