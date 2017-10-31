---
title: 'もう一度、ホームページを作ってみたい'
---

今更感漂うんですが、大人になったのでもう一回「ホームページ」を作ってみたいと思ったんです。

# この記事では何をするのか？

個人ホームページを、無駄にゼロから作って Github Pages で配信するまでをつらつらと書いてみたいと思います。

とはいえ、生の HTML を１から書き続けるのは辛いもの。個別の記事を markdown で書きつつ、様々なページを増やせるような
そんな仕組みを作ってみたいと思います。

何にせよ、git のリポジトリを用意しましょう。

```
$ mkdir ayasuda.github.io
$ cd ayasuda.github.io
$ git init
$ git commit --allow-empty -m 'initail commit'
```

さて、 index.html を作ってみましょう。

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>ayasuda.github.io</title>
  </head>
  <body>
    <p>Hello, Homepage.</p>
  </body>
</html>
```

## デザインを組み始めるための準備

さすがに白黒なページはちょっとあれです。
もちろん、Webページは中身が大事なので、
「オシャレなデザインや、レスポンシブなレイアウト、魔法のようなスクリプト」
（-- [これはウェブページです](https://justinjackson.ca/words_japan.html)）
がなくても十分ではあります。
しかし、どうせ作るなら、ちょっとくらいはカッコよさげな雰囲気のサイトを作ってみたいものです。

パーツのデザインを組んでいきましょう。
組みながらデザインをしていきますが、CSS は css-next で書いていきたいので
まずはその準備をします。

まずはパッケージマネージャ yarn を使って node モジュールを初期化し、
postcss, postcss-cssnext, postcss-cli をインストールしましょう

```
$ yarn init
yarn init v0.20.3
question name (ayasuda.github.io):
question version (1.0.0):
question description:
question entry point (index.js):
question repository url (git@github.com:ayasuda/ayasuda.github.io.git):
question author (Atsushi Yasuda <atsushi.yasuda.jp@gmail.com>):
question license (MIT):
success Saved package.json
✨  Done in 14.81s.
$ yarn add postcss postcss-cssnext postcss-cli
```

インストールが終わったら postcss 向けの設定ファイル `postcss.config.js` を用意します。

```js:postcss.config.js
module.exports = {
  plugins:[
    require('postcss-cssnext')
  ]
}
```

ビルド自体はできれば１回で何もかもやりたいのです。
~webpack が難しくてよくわからないので~ とりあえず、 Makefile を組んでおきます。
今回は、 `style` ディレクトリ以下に css を放り込んで、行くことにします。

```Makefile
CSS_CC  := node_modules/.bin/postcss
CSS_OPT := style/style.css -c postcss.config.js

CSS_OUT    := publish/assets/style.css
CSS_SRCDIR := style
CSS_SRCS   := $(wildcard $(CSS_SRCDIR)/*.css)

.PHONY: all
all: $(CSS_OUT)

$(CSS_OUT): $(CSS_SRCS)
>-$(CSS_CC) $(CSS_OPT) -o $(CSS_OUT)
```

試しに動かしてみましょう。`publish/asstes` ディレクトリを用意した上で、 `style/style.css` を次のように書いてみます。

```css:style/styel.css
h1 { color: color(red alpha(-10%)); display: flex }
```

スタイルを書いたらコンパイルしてみます。

```
$ make
node_modules/.bin/postcss style/style.css -c postcss.config.js -o publish/assets/style.css
✔ Finished style/style.css (673ms)
```

コンパイルができたら、結果を確認してみましょう。

```css:publish/assets/style.css
h1 { color: rgba(255, 0, 0, 0.9); display: -webkit-box; display: -ms-flexbox; display: flex }
```

正しく cssnext が動いているのがわかるかと思います。

さて、早速デザインに入り・・・たいところですが、もう少し準備をしておきたいところです。
デザインに入る前にいつも通りリセットCSSを掛けたいですよね？
んでもって一つの css にまとめておきたいところです。
ですので、 `import` が効くようにしておきましょう。
post-css を導入済みですので `postcss-import` を使えば簡単にできます。
yarn でインストールして、postcss 向けの設定ファイルを用意しましょう。

```
$ yarn add postcss-import
```

```js:postcss.config.js
module.exports = {
  plugins:[
    require('postcss-import'),
    require('postcss-cssnext')
  ]
}
```

準備ができたら早速試してみましょう。

`style/reset.css` を用意し、 `style/style.css` で読み込んでみます。

```css:style/reset.css
* {
  margin: 0;
  padding: 0;
}
```

```css:style/style.css
@import "reset.css";
h1 { color: color(red alpha(-10%)); display: flex }
```

スタイルシートを修正したら、早速コンパイルし結果を見てみます。

```
$ make
node_modules/.bin/postcss style/style.css -c postcss.config.js -o publish/assets/style.css
✔ Finished style/style.css (673ms)
```

```css:publish/assets/style.css
* {
  margin: 0;
  padding: 0;
}
h1 { color: color(red alpha(-10%)); display: flex }
```

きちんと import されているのがわかるかと思います。

これで準備は整いました。パーツのデザインを組んでいきましょう。
まず、デザインを組むために、要素を列挙していくためのページ design.html を用意します。
もちろん、スタイルシートとして `publish/assets/style.css` を読み込ませておきます。

```html:design.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>ayasuda.github.io</title>
    <link rel="stylesheet" href="publish/assets/style.css">
  </head>
  <body>
    <h1>デザイン用ページ</h1>
    <p>このページを元にデザインを組んでいこう</p>
  </body>
</html>
```

ページができたら、一度ブラウザで確認してみましょう。スタイルが読み込まれているなら、ヘッダが赤くなっているはずです。

## リセットCSSを用意する

さて、早速スタイルを増やしていきたいところですが、リセットCSSが全称セレクタなのはちょっとダサいです。
リセットCSSを組んでいきましょう。

ところで、なぜリセットCSSが必要なのでしょうか？

https://ferret-plus.com/4860
https://creive.me/archives/10438/
http://coliss.com/articles/build-websites/operation/css/reset-css-and-normalize-css.html
http://nicolasgallagher.com/about-normalize-css/



アトミックデザイン
http://suppon.innovator.jp.net/entry/atomic_design



-----以下執筆中

先に index.html を作った方がいい気がする。

そして、markdown で書かれた記事を置いておくディレクトリ `pages` と生成した HTML を置いておくディレクトリの `publish` を用意しましょう。

```
$ mkdir src
$ touch src/.gitkeep
$ mkdir publish
$ touch publish/.gitkeep
$ git add .
```

もっとも単純なのは Pandoc でしょう。

Pandoc を使って markdown を html に変換する環境を用意します。

フロントエンド開発の環境を作る。

とりあえず、本文は markdown で書きたい。記事は pages ディレクトリ以下に置く
スタイルは post-css で書きたい。スタイルは style ディレクトリ以下に置く
スクリプトは es6 で書きたい。

そんなわけで、まずは環境を作る。

Docker だ！　もう Docker でいいや！（環境の取り回しのしやすさから）

