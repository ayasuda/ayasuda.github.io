---
title: 'これはタイトルです'
---
Spring の Context を理解したいだけの１日だった。

いきなり Spring Boot から触り始めたゆとり世代の私は、 Context とかよくわからずにプログラムを書いているのでした。
一体なにが *Auto-configuration* されているかもよくわかっていなかった今日この頃、自分のために改めて Context とはなんなのかを再学習するのです。

# 結論

[JavaDoc](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/ApplicationContext.html) に書いてある通りやった！
単なる設定なんや！

・・・まぁ、とはいえ Spring のコア機能は含んでいるわけですね。具体的には次の５機能をサポートしているのです。

1. Bean ファクトリ。いわゆる DI するためのあれ。Autowired とか動くのは大体これのおかげ。
2. ファイルとか読むための [Resource Loader](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/io/ResourceLoader.html)
3. アプリケーション全体でイベントリスナを登録して管理できる [ApplicationEventPublisher](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/ApplicationEventPublisher.html)
4. I18n 対応するための [MessageSource](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/MessageSource.html)
5. Context の親子関係作れるようにするあれこれ

この文章では、一番大事な 1 の依存性注入あたりについて、実験しながら示していきます。

# 0. Gradle ですぐにビルド・実行ができる、 Hello,World を表示する java アプリを作ろう

これから、 Java アプリを組みながら Spring がどういう動きをするのか観察をしていきます。
そのため、コードを組んだらすぐに動きが見られるように、
とりあえず Java で Hello,World できるようにビルドスクリプトを組んでおきましょう。

もちろん、ソースコード (例えば `HellWorld.java`) を変更するたびに、コンパイル (`javac HelloWorld.java`) し、そして実行 (`java HelloWorld.class`) しても良いのですが、作業が煩雑です。
特に、ライブラリを持ってきたり、ライブラリとリンクしたりするあたりが面倒です。
そこでビルドツール [Gradle](https://gradle.org/) を使い、気軽にプログラムを実行できるようにしておきます。
(Gradle のインストールは割愛)

まずは作業用ディレクトリを用意し、Gradle のビルドファイル、ついでに git リポジトリを用意しておきましょう。

```console
$ mkdir what-is-context
$ cd what-is-context
$ git init
$ gradle init
```

Gradle のウリとしてプラグイン機構があり java アプリであれば [Gradle Java Plugin](https://docs.gradle.org/current/userguide/java_plugin.html) を組み込むことで、
いろんなタスクやその他諸々が自動で設定されます。
そんなわけで `gradle init` で生成された `build.gradle` に次の１行を足します。

```groovy:build.gradle
apply plugin: 'java'
```

Gradle Java Plugin は、デフォルトで `src/main/java` に java のソースが置かれているものとしてコンパイルタスクなどが組まれています。
ですので、今回作るアプリの Main クラスを `src/main/java/パッケージ名/` 以下に置くことにしましょう。
ひとまず、パッケージ名を what_is_context として以下のようにディレクトリとファイルを作ります。

```console
$ mkdir -p src/main/java/what_is_context
$ vim src/main/java/what_is_context/Hello.java
```

今回は "Hello,World." と表示するだけのプログラムなので、
内容は以下のとおりです。

```java:src/main/java/what-is-context/Hello.java
package what_is_context;

public class Hello {
  public static void main(String[] args) {
    System.out.println("Hello, World");
  }
}
```

プログラムを書いたら早速ビルドして...

```console
$ ./gradlew build
```

そして、実行してみましょう。
ビルドをすることで `Hello.class` が `build/classes/jaav/main` 以下にできたはずです。
ですので、 `-classpath` オプションを指定して実行します。

```console
$ java -classpath ./build/classes/java/main what_is_context.Hello
Hello, World
```

しかし、毎回クラスパスを指定するのは面倒です。ですので、簡単に実行できるようにしましょう。
方法は次の３通りです。

1. 自分でマニフェストファイルを書いて、実行可能な jar ができるようにする
2. Gradle Java Plugin の manifest file プロパティを指定して、実行可能な java ができるようにする
3. Gradle Applicatoin Plugin を使う

自分でマニフェストファイルを書く方法についてはよくわからなかったので、ここでは 2, 3 についてみて行きましょう。

Gradle Java Plugin の jar オブジェクトには manifest プロパティがあり、そこで値を設定することで、
jar タスクにてパッケージする際の `MANIFEST.MF` の内容を設定できます。
今回は、 `Main-Class` を `what_is_context.Hello` にしたいので、 `build.gradle` を下記のように書き換えます。

```buidl.gradle
apply plugin: 'java'

jar {
  manifest {
    attributes('Main-Class': 'what_is_context.Hello')
  }
}
```

書き換えたら早速ビルドしてみましょう。

```console
$ ./gradlew build
```

これにより、正しく Main-Class が設定されたマニフェストファイルを含んだ jar ファイルが `build/libs/` 以下にできたはずです。
と、いうわけで実行してみましょう。

```console
$ java -jar build/libs/what_is_context.jar
Hello, World.
```

なお、 jar ファイルの名前は `jar.baseName` で変更可能です。

```buidl.gradle
apply plugin: 'java'

jar {
  baseName = 'wic'
  manifest {
    attributes('Main-Class': 'what_is_context.Hello')
  }
}
```

単に実行をしたいだけならば [Application Plugin](https://docs.gradle.org/current/userguide/application_plugin.html) を使うのが最も簡単です。
このプラグインを読み込んで、 `mainClassName` 属性を設定することで、アプリケーションを実行する `run` タスクが使えるようになります。

```buidl.gradle
apply plugin: 'java'
apply plugin: 'application'
mainClassName = 'what_is_context.Hello'
```

上記の様にファイルを変更すれば、下記の様に `run` タスクを実行するだけです。

```console
$ ./gradlew run
Hello, World
```

ここまでのソースコードは TODO で確認できます。

# Spring を読み込んでみる

早速 Spring を組み込んでみましょう。ビルドスクリプトに依存ライブラリとして Spring を組み込んでみます。

```buidl.gradle
apply plugin: 'java'
apply plugin: 'application'

repositories {
  mavenCentral()
}

mainClassName = 'what_is_context.Hello'

jar {
  manifest {
    attributes('Main-Class': 'what_is_context.Hello')
  }
}

dependencies {
  compile 'org.springframework:spring-context:5.0.6.RELEASE'
}
```

まずはContainerにBeanを登録して、Main内からBeanを取ってくる。の実装例として、interface Greeter, MockGreeter と ColoredGreeter を用意して、
