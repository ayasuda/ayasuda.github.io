なぜ今更静的サイトをゼロから作るのか？　理由と方法
=====

2017年も1/3が終わるこのご時世に、なぜ Github Pages で静的なサイトを作ろうと思ったのでしょうか？
理由は単純で、モダンな技術を使って Web1.0 をやってみたかった。
そう「やってみたかったから」という理由だけです。

この記事では、静的な HTML ページを作るための、モダンな開発環境の揃え方の１例を紹介していきます。

早速、プロジェクトディレクトリを作り、開発を始めましょう。

```
$ mkdir proj
$ cd proj
$ git init
$ git commit --allow-empty -m 'Initial Commit for static html site.'

ビルドスクリプトと周辺技術
----

静的サイトを作り始めるにあたって、最初の１ページを作り始める前にまずはビルドツールを揃えましょう。

モダンな技術を使うわけですから、まさか生の html をガリガリ書き始めるわけがありません。
コンテンツは markdown で、スタイルは css-next で、スクリプトは es-2016 で書きたいものです。

node, yarn, webpack

# yarn はパッケージマネージャでビルドツールじゃないよ
さて、ビルドツールは様々出ていますが、今回は yarn を使います。
インストールについては割愛するとして、早速 yarn で管理されたプロジェクトを作りましょう。
同時に、プロジェクトディレクトリをバージョン管理下に置いておきます。

```
$ yarn init
yarn init v0.20.3
question name (proj): 
question version (1.0.0): 
question description: 
question entry point (index.js): 
question repository url: 
question author: 
question license (MIT): 
success Saved package.json
✨  Done in 8.54s.
```



下記ページによれば、master ブランチに直接 index.html を置くしかありません。
https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/

でも、それ嫌はなので、基本的には public/ 以下に全部 publish するようにしましょう。
その上で、作業ブランチの結果を master にコミットするようにしてみましょう。

### webpack

webpack はモダンな JavaScript アプリケーション向けのモジュールバンドラ（ここに説明）です。

*Entry*

webpack はアプリケーションの依存グラフを作ります。
依存グラフのスタート地点は「エントリーポイント」です。
エントリーポイントは webpack にどこからグラフを辿れば良いかを指定し、何をまとめるかを支持します。
アプリケーションのエントリポイントは「コンテキストごとのルート」か「アプリケーションを開始する最初の場所」と考えれば良いです。

webpack では「エントリポイント」を `entry` プロパティで定義できます。

```javascript:webpack.config.js
module.exports = {
  entry: './path/to/my/entry/file.js'
}
```

*Output*

webpack に *どこに* アプリケーションをバンドルするかを設定します。 `output` プロパティを使って定義します。

```javascript:webpack.config.js
const path = require('path')

module.exports = {
  entry: './path/to/my/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'my-first-webpack.bundle.js'
  }
}
```

この例では `output.filename` と `output.path` という２つのプロパティを使って、 webpack がどこにファイルをバンドルするかを設定しています。

*Loader*

目標は、プロジェクト内のすべての資産をブラウザの問題ではなくWebpackの関心事にすることです。
（これはすべてが一緒に束ねられなければならないというわけではありません）。
webpackは、すべてのファイル（.css、.html、.scss、.jpgなど）をモジュールとして扱います。ただし、webpackはJavaScriptのみを認識します。

webpack のローダーは、ファイルが依存グラフに加えられた際にモジュールに変換します。

*Plugin*

css-next
babel
