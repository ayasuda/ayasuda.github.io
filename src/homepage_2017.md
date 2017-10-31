---
title: 'これはタイトルです'
---

# 2017年の「ホームページ」作り忘備録

手作業で「ホームページ」のHTMLを組んでいた時代から早15年くらい。
タグの使い分けもスタイルもわからなかった頃から比べて、多少は Web の世界に慣れてきたかなと思う今日この頃です。

さて、あの頃から随分と知識が身についた気がするわけなのですが、果たして本当に技術力は上がったのでしょうか？

復習も兼ねて、たまにはホームページを１から作ってみると、いったい何が出来上がるのか試してみようと思った次第です。

## 大枠のマークアップ

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <base href="https://ayasuda.github.io/">
    <title>ayasuda.github.io</title>
  </head>
  <body>
    <nav>
    </nav>
    <header>
      <h1>ayasuda.github.io</h1>
    </header>
    <aside>
    </aside>
    <article>
      <h1>ここに記事のタイトルとか</h1>
    </article>
    <footer>
      コピーライトとか
    </footer>
  </body>
</html>
```

久しぶりの白紙から作る html です。まずは文書型宣言から書いてきましょう。

HTML5 になり、文書型宣言は随分と簡単になりました。dtdを指定していた頃が嘘のようです。
今や `<!DOCTYPE html>` だけで十分です。

次に書くのはルート要素である [html](https://developer.mozilla.org/ja/docs/Web/HTML/Element/html) タグです。



それに続く [head](https://developer.mozilla.org/ja/docs/Web/HTML/Element/head)
[body](https://developer.mozilla.org/ja/docs/Web/HTML/Element/body) はいつも通りですが、
`<meta charset="utf-8" />` は MDN を読むと強く推奨されています。
( [meta](https://developer.mozilla.org/ja/docs/Web/HTML/Element/style) )

その他、
[title](https://developer.mozilla.org/ja/docs/Web/HTML/Element/title)
[base](https://developer.mozilla.org/ja/docs/Web/HTML/Element/base)
[link](https://developer.mozilla.org/ja/docs/Web/HTML/Element/link)
[style](https://developer.mozilla.org/ja/docs/Web/HTML/Element/style)
あたりを適宜書いていきましょう。

さて、HTML5 では
[セクションとアウトラインに関するタグ](https://developer.mozilla.org/ja/docs/Web/HTML/Sections_and_Outlines_of_an_HTML5_document)
が追加されました。

まず
[section](https://developer.mozilla.org/ja/docs/HTML/Element/section)
と
[article](https://developer.mozilla.org/ja/docs/HTML/Element/article)
により、ページ内の内容の境界が明確に分離可能になりました。

`section` も `article` もそれぞれ文書の一かたまりを示しますが、 `article` には「独立したコンテンツ」というニュアンスが含まれます。
ですので、個別の記事ページを作りたいのであれば、記事全体を `article` で囲ってやるのが良いでしょう。

また、 `section` も `article` もそれぞれ別個の文書の塊を示せるため、それぞれが `h1` - `h6` までの見出しを持てるようになりました。
ですので、例えば `body` 直下にサイト全体のタイトルを示す `h1` を置きつつ、個別の記事のタイトルを `article` 直下の `h1` におけるようになりました。

その他にも、主要なナビゲーションを示す
[nav](https://developer.mozilla.org/ja/docs/Web/HTML/Element/nav)
や、メインコンテンツとの関連が希薄なセクションである
[aside](https://developer.mozilla.org/ja/docs/Web/HTML/Element/aside)
（サイドバーやコラムに用いることが想定されています）なども追加されました。

これらのセクションそれぞれにヘッダやフッタを示す
[header](https://developer.mozilla.org/ja/docs/Web/HTML/Element/header)
や
[footer](https://developer.mozilla.org/ja/docs/Web/HTML/Element/footer)
も使えるようになりましたので、様々なものが、よりスッキリと書けるようになりました。

例えば、ブログの個別記事ページなどでは次のように書くことができます。

```html
<body>
  <header>
    <h1>Hogeのブログ</h1>
  </header>
  <nav>
    ブログ全体のナビゲーション
  </nav>
  <aside>
    サイドバーや広告枠など
  </aside>
  <article>
    <header>
      個別記事のヘッダ
      <h1>個別記事のタイトル</h1>
      <span>投稿日時とか</span>
    </header>
    <section>
      記事の本文
      ...
    </section>
    <footer>
      個別記事のフッタ。パーマリンクなど
    </footer>
  </article>
  <footer>
    ブログ全体のフッター、コピーライトなど
  </footer>
</body>
```

## コンテンツ・スタイル・スクリプト

大枠はできました。
ブラウザに表示して、白と黒の画面を眺めながら、
どうやってコンテンツを作っていくか考えましょう。

全てのコンテンツで生 html を書くのは常軌を逸しています。
また、どうせならコンテンツは markdown で書いていきたいものです。

markdown を html に変換する方法は幾つかありますが、
単一の markdown を単一の html に変換しやすいという観点から言えば
pandoc が一番素直でしょう。

```
$ pandoc -f markdown -t html5 foo.md > foo.html
```

pandoc はテンプレート、メタデータもサポートしているので、たとえば
以下の構成でファイルを用意しておく

template.html
metadata.yml
pages/foo.md
publish/

特定の拡張子のファイルを特定の拡張子のファイルに変換するなら
なんだかんだで make は使いやすい。

なので、こんな Makefile を用意しておく

どうせスタイルとスクリプトは使う

スタイルとスクリプトを用意しておこう
個人的な趣味から、コンポーネント志向でいきたい。

そもそもコンテンツは何があるか

pages 以下に個別の記事を作っていく
pages 以下のアレを index から見られる

スタイルは何はなくとも postCSS を使いたいし、js は es-2017 を使いたい
bundle.js と application.css を作る

postcss-cli, postcss-cssnext 使えば cc っぽくいける

```
$ yarn init
$ yarn add postcss-cli postcss-cssnext
```

```javascript:postcss.config.js
module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-cssnext')
  ]
}
```

css は全体で一つの css を使うのか？　それとも個別 css を使うのか？
とりあえず一つの css を使う。


## スタイル

reset.css

まずはブラウザごとのスタイル、ユーザーエージェントスタイルをリセットしたいので、リセットCSS を適用しましょう。
リセットCSSは流派ごとの違いがあります。
http://friends.o2p.jp/index.html

それが終わったら、今回はアトミックデザインでデザインを作ってみたい。

まず、基本要素で構成された html ファイルを用意してみる。


モバイルファースト


## その他

> どうやってビルドして、どうやって配信するか？
>
> 今は2017年ですので、cssやjsはモダンなものを使いたいものです。
> また、コンテンツはどうせなら Markdown で書いていきたいものです。
> 
> 詳細は「ホームページ作り」から大きく外れてしまいm
> 何も考えずに github pages を使うことにしました。

markdown で書いて、pandoc で html にコンパイル
あああ
