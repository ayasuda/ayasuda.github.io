---
title: '俺のための Maven 入門'
date: '2017-12-12'
description: '初めて Maven に触れる人向けに、５分でわかる Maven の流れをまとめておきました'
tags:
  - Java
keywords:
  - Java
  - Maven
  - Maven入門
---

なにもかもを忘れっぽい自分のために、 [Apache Maven](https://maven.apache.org) の入門記事をまとめておこうと思う。

*毎度のことだけど、正しい情報は公式サイト読もうね*

Apache Maven
====

Apache Maven はプロジェクトマネジメントツールで、Project Object Model (POM) というモデルをコンセプトとしている。
Maven を使うことで、プロジェクトのビルドやドキュメンテーションなど様々なことを行うことができる。

インストール方法とかは *公式サイト読もうね*

使い方
----

コマンドとオプションは下記の通り。

```shell
$ mvn [options] [<goal(s)>] [<phase(s)>]
```

細かいオプションは `mvn -h` しよう。

さて、 Maven life cycle phase に基づいた Maven project を構成しているなら、典型的には下記のコマンドでパッケージを作成できる。

```
$ mvn package
```

ビルトインのライフサイクルと各フェイズは次の順になっている。

* clean - pre-clean, clean, post-clean
* default - validate, initialize, generate-sources, process-sources, generate-resources, compile, process-classes, generate-test-sources, process-test-sources, generate-test-resources, process-test-resources, test-compile, process-test-classes, test-compile, process-test-classes, test, prepare-package, package, pre-integration-test, integration-test, post-integration-test, verify, install, deploy
* site - pre-site, site, post-site, site-deploy

これはなに？
----

Maven は Jakarta Turbine project のビルドプロセスを簡単にするために開発されました Ant の後継ツールで、Java ベースのプロジェクトを運用しやすくするために作られている。
Maven のゴールは開発者が短時間に開発状態などを理解しやすくさせることだ。つまり、下記の５点をゴールとしている。

* ビルドプロセスを簡単にできること
* 一定のビルドシステムを提供すること
* 高水準のプロジェクト情報を提供すること
* 開発のベストプラクティスやガイドラインを提供すること
* 新しい機能へ簡単に移行できること

まあ噛み砕いて言えば、「プロジェクトにアサインされた時、最初に使えば何となくわかるツール」みたいなものだ。

これだけ見ればとりあえず動かしたり、テストしたり、ドキュメントを生成できたりできるようになる、そんなはずのツールだ。

主な使い方
----

さあ、Maven に慣れるために、早速使い始めてみよう。

まずは Maven プロジェクトを作ってみよう。
[archetype:generate](http://maven.apache.org/archetype/maven-archetype-plugin/generate-mojo.html) で、
一般的な Maven プロジェクトを開始できる。

このコマンドでは「アーキタイプ」を用いてプロジェクトを作成する。
アーキタイプとは、例えば "シンプルなJavaプロジェクト" や
"GUIプロジェクト", "サーバサイドアプリ" などのことだ。

早速、実行してみよう。

```
$ mavn archetype:generate
```

さて、このコマンドに特にオプションを指定しない場合、自動的にウィザードが立ち上がって、それに答えることで設定が行われていく。

そんなわけで、下記に示すように、いきなり「アーキタイプ」の選択肢が *2012個ほど* 提示される。

```
2011: remote -> us.fatehi:schemacrawler-archetype-plugin-dbconnector (-)
2012: remote -> us.fatehi:schemacrawler-archetype-plugin-lint (-)
Choose a number or apply filter (format: [groupId:]artifactId, case sensitive contains): 1095:
```

大抵のなにが何だかわからないが、とりあえず今回はデフォルトの 1095 を使うこととする。
ちなみに 1095 は _An archetype which contains a sample Maven project._ とのことで、サンプルプロジェクトらしい。

デフォルトのままで良いのでそのまま Enter キーを押すと、次にバージョンが聞かれる

```
Choose org.apache.maven.archetypes:maven-archetype-quickstart version:
1: 1.0-alpha-1
2: 1.0-alpha-2
3: 1.0-alpha-3
4: 1.0-alpha-4
5: 1.0
6: 1.1
Choose a number: 6:
```

これもそのままで良いので Enter キーを押す。
すると、次に groupId が聞かれる。
groupId はプロジェクトを一意に識別する名前だ。
例えば、example.com というグループで alice というプロジェクトを行なっているなら
`com.example.alice` を入れる。
groupId の次は artifactId だ。これはプロジェクトの成果物を表す名前で、JAR や WAR, EAR ファイルの名前に使われる。
その次は現在のバージョン入力が求められる。これはデフォルトのままで良い。
そして package 名が求められる。ここも基本的にはデフォルトのままでよい。

```
Define value for property 'groupId': com.example.alice
Define value for property 'artifactId': hello
Define value for property 'version' 1.0-SNAPSHOT: :
Define value for property 'package' com.example.alice: :
```

ここまで入力すると、最後に確認が表示される。OKなら `Y` を入力する。

```
Confirm properties configuration:
groupId: com.example.alice
artifactId: hello
version: 1.0-SNAPSHOT
package: com.example.alice
 Y: :
```

ここまでの入力が終わったら自動的にプロジェクトが作られる。

```
% tree
.
└── hello
    ├── pom.xml
    └── src
        ├── main
        │   └── java
        │       └── com
        │           └── example
        │               └── alice
        │                   └── App.java
        └── test
            └── java
                └── com
                    └── example
                        └── alice
                            └── AppTest.java

12 directories, 3 files
```

さて、プロジェクトディレクトリに移動して、コンパイルをしてみよう。
デフォルトで、上の方に示した goal, phase が全て定義済みとなっているが、よく使うのはこの辺りのコマンドだ。

| `mvn compile` | Java のコードをコンパイルして target ディレクトリに配置する |
| `mvn test` | 単体テストを実行する |
| `mvn package` | パッケージを生成して target ディレクトリに配置する |
| `mvn install` | 作成されたパッケージをローカルリポジトリにインストールする。これにより、ローカル内の他のプロジェクトから参照可能になる。 |
| `mvn deploy` | 作成されたパッケージをリモートリポジトリに配置する。これにより、登録されたリモートリポジトリへのアクセス権がある他の開発者が参照可能になる。 |
| `mvn clean` | compile, test, package, などで生成された成果物を削除する |
| `mvn javadoc:javadoc` | Javadoc を生成する |

早速、パッケージを作成し、実行してみよう。上にも示した通り、パッケージの作成は `mvn package` から行う。

```
$ cd hello
$ mvn package
```
こんな風に、作成に成功した風なメッセージが出れば OK だ。

```
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.977 s
[INFO] Finished at: 2017-12-12T17:36:01+09:00
[INFO] Final Memory: 18M/307M
[INFO] ------------------------------------------------------------------------
```

作成できたパッケージは、 `java` コマンドから実行できる。`-cp` オプションで、classpath をパッケージから読み込み、
今回作成したアプリのメインクラスである `com.example.alice.App` を指定してやれば実行結果が見られるはずだ。

```
$ java -cp target/hello-1.0-SNAPSHOT.jar com.example.alice.App
Hello, World.
```

どうだろう。これで何となく Maven の世界観が分かったと思う。
