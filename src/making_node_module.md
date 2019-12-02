---
title: 'はじめての npm パッケージ'
description: 'UIコンポーネントのライブラリわかりやすくするために Storybook を使ってみようって記事'
keywords:
  - Javascript
  - NPM
  - Package
---

# はじめての npm パッケージ


## 準備編

TODO: 書く
(public にする場合)
まず npm にアカウントを作ります。
npm コマンドで認証をします。

(private にする場合)
??
3 通りの方法がある。
手元で使うだけならディレクトリを分けておけば十分。ただし、この場合当たり前だがCIとかにはとても載せられない。
CIやクローズドなチームなどで使うなら private な remote リポジトリに push する方法が考えられる
大規模にやりたいなら registory を自前で立てる方法がある。

## 作る編

さて、準備ができたら早速パッケージを作って行きましょう。
まずはディレクトリを作って移動します。

```
$ mkdir /path/to/my-first-npm-package
$ cd /path/to/my-first-npm-package
```

npm のパッケージとは "package.json で記述されたファイルまたはディレクトリ" でした。
そんなわけで package.json を記述していきましょう。
[Creating a package.json file](https://docs.npmjs.com/creating-a-package-json-file) を参考に生で書いても良いですし、
コマンドラインツールを使用しても良いです。

```javascript:package.json
{
  "name": "my-first-npm-package",
  "version": "0.0.1",
  "description": "my first test package",
  "main": "index.js",
  "author": "Atsushi Yasuda",
  "private": true,
  "license": "ISC"
}
```

main に index.js を指定しました。
と、いうわけで、 index.js に実装を書いていきます。
今回はテスト的に関数を１個だけ使えるようにして見ましょう。

```javascript:index.js
exports.hello = function() {
  console.log("Hello,World.");
}
```

以上です。

## publish 編

npm publish します。
TODO: 家でやる。


## github の private リポジトリでホストする場合

npm でパッケージを公開しなくても、パッケージを使うことができます。

まず、上で作った foo パッケージを github の private リポジトリに push します。

```
$ cd /path/to/foo
$ git init
$ git add .
$ git commit -m 'publish private repository'
```

さて、早速このパッケージを使ったプロジェクトを作って見ましょう。
まずは、ディレクトリを作ってそこに移動し、 package.json を作成します。

```
$ mkdir /path/to/sample
$ cd /path/to/sample
```

```javascript:package.json
{
  "name": "sample",
  "version": "0.0.1",
  "description": "a sample code using foo package",
  "main": "index.js",
  "author": "Atsushi Yasuda",
  "private": true,
  "license": "ISC"
}
```

そんなわけで `npm install` でライブラリをインストールします。

```
$ npm install ayasuda/my-first-npm-package
```

インストールしたら、 `my-first-npm-package` を使うコードを書いて見ましょう。

```javascript:index.js
const mfnp = require("my-first-npm-package");

mfnp.hello();
```

コードができたら実行して見ましょう。

```
$ node index.js
Hello,World.
```

きちんと、ライブラリが使えいるのがわかるかと思います。


## ローカルから直接使う場合

実のところ、完全にローカルだけで今作ったパッケージを使うこともできます。

さて、早速このパッケージを使ったプロジェクトを作って見ましょう。
まずは、ディレクトリを作ってそこに移動し、 package.json を作成します。

```
$ mkdir /path/to/sample
$ cd /path/to/sample
```

```javascript:package.json
{
  "name": "sample",
  "version": "0.0.1",
  "description": "a sample code using foo package",
  "main": "index.js",
  "author": "Atsushi Yasuda",
  "private": true,
  "license": "ISC"
}
```

そんなわけで `npm install` でライブラリをインストールします。

```
$ npm install /path/to/my-first-npm-package
```

インストールしたら、 `my-first-npm-package` を使うコードを書いて見ましょう。

```javascript:index.js
const mfnp = require("my-first-npm-package");

mfnp.hello();
```

コードができたら実行して見ましょう。

```
$ node index.js
Hello,World.
```

きちんと、ライブラリが使えいるのがわかるかと思います。
