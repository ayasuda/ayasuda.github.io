---
title: '俺のための Spring 入門かつ再整理'
---
俺のための Spring 入門かつ再整理

Spring というフレームワーク
  色々入ってる
  DI と AOP がきも・・・なんだよね？
  アプリケーション
  コンポーネント
  設定
  インジェクションとオートワイアリング

# Spring って何さ？

Java のフレームワークだよ！

……だけだとあまりにも酷すぎるのでちゃんと説明すると、かなり広範囲な部分をサポートするフルスタックのフレームワーク *群* です。
その全体像は [Projects](https://spring.io/projects) ページにある通りで多数あります。

初めての場合は、とりあえず、 [Spring Boot](https://spring.io/projects/spring-boot) から始めるのが良いでしょう。

## Spring Boot で雰囲気に触れてみよう！

Spring Boot は、プロダクションレベルの Spring アプリケーション開発をすぐに始められるようにしたものです。
Spring は広範囲な部分をサポートする反面、どのプロジェクトやライブラリを組み合わせれば良いかがわかりにくくなってしまっています。
そこで登場したのが Spring Boot です。Spring Boot を使うと様々な設定が自動で行われます。
例えば、ログ設定や DI (Dependency Injection) で使う Bean の定義などが自動で行われるので、ほんのすこしの設定をするだけで動くアプリケーションが作成できます。

早速試してみましょう。
まず、[Spring Initializr](https://start.spring.io/) にアクセスし、Generate `Gradle Project` with `Java` and Spring Boot `2.0.4` と設定し、
その他設定はそのままで「Generate Project」してみましょう。

生成され、ダウンロードできた zip ファイルを展開して、早速実行してみましょう。 `gradle bootRun` で実行可能です。

```
$ cd path/to/zip
$ unzip demo.zip
$ cd demo
$ ./gradlew bootRun

...

.   ____          _            __ _ _
/\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
\\/  ___)| |_)| | | | | || (_| |  ) ) ) )
'  |____| .__|_| |_|_| |_\__, | / / / /
=========|_|==============|___/=/_/_/_/
:: Spring Boot ::        (v2.0.4.RELEASE)
```

すぐに実行が終わってしまいますが、単体の Spring アプリケーションが立ち上がり（そして終了）したのがわかるかと思います。

もう一度、今度は Web アプリケーションを試してみましょう。 Spring Initializr にて、今度は Dependencies に `Web` を追加して、
プロジェクトを生成し、ダウンロードした zip ファイルを展開してから同じように実行してみましょう。

今度は Web サーバが立ち上がったかと思いますので、ブラウザで http://localhost:8080 にアクセスし、ページを開いてみましょう。
見事、 *エラーページが* 表示されたかと思います（よく見ると、 404 Not Found 的なエラーが表示されているかと思います）。

唯一のコードである `src/main/java/com/example/demo/DemoAppplication.java` をざっと読むと、驚くほど *何も書かれていない* ことがわかるかと思います。

### コマンドラインアプリ実行コンポーネントと HelloWorld コンポーネント

さて、ここからリクエストハンドラやコンポーネントなどを追加していくことでアプリケーションを作るわけですが……

今回は簡単に、コマンドラインアプリとしてアプリケーションを実行するコンポーネントと、ログとして HelloWorld を表示するコンポーネントを追加してみましょう。

先ずは Hello,World とコマンドラインに表示するだけのコンポーネントを `src/main/java/com/example/demo/Runner.java

先ずはコマンドラインアプリとしてアプリケーションを実行できるようにするコンポーネントを `src/main/java/com/example/demo/Runner.java` に追加します。

```java:src/main/java/com/example/demo/Runner.java

```

本文書では、先に Spring の基礎部分を解説していきたいと思います。

## Spring のコア部分 - (狭義の) Spring Framework

[Spring Framework](https://spring.io/projects/spring-framework) は各種 Spring フレームワークのコア部分で、
いわゆる DI (依存性注入) やイベント処理、リソース管理、i18N対応、バリデーション、AOP機能がサポートされます。

と、いうわけで、ここから Spring Framework だけを使って、各機能を見ていきましょう。

