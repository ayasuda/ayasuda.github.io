webpack とは
=====

[webpack](https://webpack.js.org/) とは、JavaScript モジュールのビルドツールです。
他のビルドツールとの違いを知るために、誕生背景を [motivation](http://webpack.github.io/docs/motivation.html) から抜粋しましょう。

現在のモダンなウェブサイトではたくさんの JavaScript が使われています。
また、これらの JavaScript コードはモジュールの集まりとして実装されています。

これらのモジュールをどうのようにブラウザに読み込ませるかについては、大まかに言って２つのアプローチがありました。
１つの大きな JavaScript ファイルにまとめ１回のリクエストで読み込ませるか、
１リクエストで１モジュールを返すこととして複数回のリクエストを行わせるかです。
前者はリクエスト数が少なくなり、キャッシュもしやすいですが、ブラウザは余計なスクリプトを読み込まなければいけません。
後者はブラウザが読み込むスクリプトは最低限ですが、リクエスト数が膨大になります。

webpack はこの中間として、「ほどほどの塊のほどほどの JavaScript ファイルを作りやすくすること」
を主目的として開発された新しいビルドツールです。

もう少し詳しく理解したいなら [４つのコンセプト](https://webpack.js.org/concepts/) について見ていくことが重要です。

まず１つ目は Entry です。

webpack はアプリケーションの依存グラフを作りますが、グラフの根のことをエントリーポイントと呼んでいます。
webpack はエントリーポイントからグラフを辿りながら、どのモジュールをまとめるかを判断していきます。

２つ目は Output です。

依存するファイルをまとめ上げたとして、
どこに結果を吐き出すかを webpack では `output` 属性として定義できます。

３つ目は Loaders です。

webpack の目的はアセットをブラウザの関心ごとから webpack の関心ごとにすることです。
ですので、 webpack は JavaScript 以外のすべてのファイルをモジュールとして扱える必要があります。

Loader は webpack が scss や jpeg のような JavaScript 以外のファイルもモジュールとして扱わせるための機構です。

最後は Plugin です。

Loader はあくまでもファイルごとに webpack がモジュールとしてファイルを扱えるようにするための機構としてしか使えませんでした。
Plugin はよりなんでもできるようにさせた拡張機構です。

最初の一歩
----

- [ ] install
- [ ] first step
- [ ] split js file
- [ ] chunk and async load
- [ ] extract NOT js code (extract css)

reference
-----

- [Webpack の本質とそれがよく分かるチュートリアル - 彼女からは、おいちゃんと呼ばれています]
  (http://blog.inouetakuya.info/entry/2016/12/11/201419)
- [Webpack your bags | Webpack 1.13.0 日本語リファレンス | js STUDIO]
  (http://js.studio-kingdom.com/webpack/getting_started/webpack_your_bags)
