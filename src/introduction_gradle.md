---
title: 'ぼくのための Gradle 入門'
date: '2018-08-01'
description: 'Gradle に入門しつつ、とりあえず Hello,World. と Java プログラムを書くまで'
keywords:
  - Java
  - Gradle
---

Ruby な会社から Java な会社に転職したぼく。その前に立ちはだかるのは３つのビルドツールだった。
Java で一番新しいビルドツールは Gradle と聞いたぼくは、早速 Gradle の使い方について調べるのでした。

# What is Gradle

とりあえず Java で Hello,World できるようなプログラムを考えましょう。
何も使用せずに生でソースコード (例えば `HellWorld.java`) を書き、 変更するたびに、コンパイル (`javac HelloWorld.java`) し、そして実行 (`java HelloWorld.class`) しても良いのですが、作業が煩雑です。
特に、プログラムが大きくなったあと、ライブラリを持ってきたり、ライブラリとリンクしたりするあたりや、コンパイルオプションが増え始めた後は面倒です。

そこで登場するのがビルドツールで、Java の世界では長らく [Ant](https://ant.apache.org) が使われてきました。
ところがどっこいビルドスクリプトの肥大化や複雑化が大変になることが多く、管理コストが悩みのタネになりがちでした。（当たり前だけど使わないよりかははるかにマシではある）
そこで出てきたのが [Maven](https://maven.apache.org) で、ビルドライフサイクルというよくある手順の形式化や依存関係の自動解決などが提供されとても流行しました。
しかし、暗黙の設定の多さや規約から外れようとした時の手間という弱点が薄々認知されれるようになったある日、 [Gradle](https://gradle.org/) が登場したのです。

Gradle では Maven の良さを取り入れつつ、柔軟性を高めるためにスクリプトの記述言語に Groovy が採用されました。

# Gradle ですぐにビルド・実行ができる、 Hello,World を表示する java アプリを作ろう

さて、 *Gradleの便利さ* を試すために、素の Java と Gradle を使った場合とでどのように違うのか、実際にプログラムを書きながら見ていきましょう。
先ずは、何はともあれ "Hello,World." を表示するプログラムを書いていきます。

もちろん、単純なプログラムであれば Gradle を使った方が煩雑です。

ですが、この後に述べていく通り、複数ファイルで構成されるプログラムや、外部ライブラリを使うプログラムなら Gradle を使うメリットがはっきりわかるはずです。


## 素の Java で書くとどうなる？

さて、素の Java プログラムで Hello,World. を表示するプログラムを書いてみましょう。ひとまず、ディレクトリを用意し、 git リポジトリを用意します。

```console
$ mkdir vanilla_java
$ cd vanilla_java
$ git init
$ git commit --allow-emtpy -m 'Initial commit'
```

そして、アプリケーションコードを作ってみましょう。とりあえず、 Application.java という名前にします。

```java:Application.java
public class Application {
  public static void main(String[] args) {
    System.out.println("Hello, World.");
  }
}
```

こいつをコンパイルして、クラスファイルを作り、実行してみましょう。うまくいけば、 Hello,World. と表示されるはずです。

```console
$ javac Application.java
$ ls
Application.class Application.java
$ java Application
Hello, World.
```

毎回正確なコマンドを打つのは面倒ですよね？　ですので、実行可能な jar ファイルを生成しておきましょう。

まず、マニフェストファイルを作ります。このファイルの中には、どのクラスを最初に実行するかを記しておきます。

```text:Manifest.txt
Manifest-Version: 1.0
Main-Class: Application
```

次に下記のコマンドでファイルをまとめます

```
$ jar cvfm app.jar Manifest.txt Application.class
```

これで `app.jar` というファイルができたはずです。この jar ファイルを java コマンドから実行すると、次のようにきちんと実行できるはずです。

```
$ java -jar app.jar
Hello, World.
```

ここまでのコードは [ayasuda/sandox/vannila_java](https://github.com/ayasuda/sandbox/tree/master/vanilla_java) にあります。

## Gradle を使った Hello,World プロジェクト

さて、上記と同じことを Gradle を使ってやっていきます。
まずは作業用ディレクトリを用意し、Gradle のビルドファイル、ついでに git リポジトリを用意しておきましょう。

```console
$ mkdir with_gradle
$ cd with_gradle
$ git init
$ gradle init
```

Gradle のウリとしてプラグイン機構があり java アプリであれば [Gradle Java Plugin](https://docs.gradle.org/current/userguide/java_plugin.html) を組み込むことで、
いろんなタスクやその他諸々が自動で設定されます。(ただし規約に従う必要がある)
そんなわけで `gradle init` で生成された `build.gradle` に次の１行を足します。

```groovy:build.gradle
apply plugin: 'java'
```

Gradle Java Plugin は、デフォルトで `src/main/java` に java のソースが置かれているものとしてコンパイルタスクなどが組まれています。
ですので、今回作るアプリの Main クラスを `src/main/java/パッケージ名/` 以下に置くことにしましょう。
ひとまず、パッケージ名を with_gradle として以下のようにディレクトリとファイルを作ります。

```console
$ mkdir -p src/main/java/with_gradle
$ vim src/main/java/with_gradle/Application.java
```

今回は "Hello,World." と表示するだけのプログラムなので、
内容は以下のとおりです。

```java:src/main/java/with_gradle/Application.java
package with_gradle;

public class Application {
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
ビルドをすることで `Application.class` が `build/classes/jaav/main` 以下にできたはずです。
ですので、 `-classpath` オプションを指定して実行します。

```console
$ java -classpath ./build/classes/java/main with_gradle.Application
Hello, World
```

しかし、毎回クラスパスを指定するのは面倒です。ですので、簡単に実行できるように jar ファイルを作りましょう。
実行可能な jar ファイルを作るためにはマニフェストが必要でした。 gradle を使う場合、方法は次の３通りです。

1. 自分でマニフェストファイルを書いて、実行可能な jar ができるようにする
2. Gradle Java Plugin の manifest file プロパティを指定して、実行可能な java ができるようにする
3. Gradle Applicatoin Plugin を使う

自分でマニフェストファイルを書く方法についてはよくわからなかったので、ここでは 2, 3 についてみて行きましょう。

Gradle Java Plugin の jar オブジェクトには manifest プロパティがあり、そこで値を設定することで、
jar タスクにてパッケージする際の `MANIFEST.MF` の内容を設定できます。
今回は、 `Main-Class` を `with_gradle.Application` にしたいので、 `build.gradle` を下記のように書き換えます。

```buidl.gradle
apply plugin: 'java'

jar {
  manifest {
    attributes('Main-Class': 'with_gradle.Application')
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
$ java -jar build/libs/with_jar.jar
Hello, World.
```

なお、 jar ファイルの名前は `jar.baseName` で変更可能です。

```buidl.gradle
apply plugin: 'java'

jar {
  baseName = 'app'
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

# 2 つのファイルに別れた Java アプリ

ここまでの話では、 *Gradle を使うメリットなんて感じられない* と思います。煩雑になっただけにしか見えないかと思います。
ですが、実際のプログラミングでは1ファイルで済むことはあまりありませんし、外部のライブラリを使わないこともあまりありません。
次に、バニラと Gradle を使った場合とで複数ファイルのプログラミングはどのように違うのかをみていきたいと思います。

## 素の Java で書くと？

まず、 Hello, World. の文字列を別のクラスから取得するようにしましょう。特に、~面倒臭く~ それっぽくするために、ディレクトリを切ってその下にクラスを置くようにしてみましょう。

```java:generators/GreetingMessageGenerator.java
package generators;

public class GreetingMessageGenerator {
  public String generate() {
    return "Hello, World.";
  }
}
```

```java:Application.java
import generators.GreetingMessageGenerator;

public class Application {
  public static void main(String[] args) {
    String message = new GreetingMessageGenerator().generate();
    System.out.println(message);
  }
}
```

この２つのクラスをそれぞれコンパイルしてみましょう。

```console
$ javac Application.java generators/GreetingMessageGenerator.java
$ java Application
```

そしてパッケージ化します

```console
$ jar cvfm app.jar Application.class generators/GreetingMessageGenerator.class
$ java -jar app.jar
```

ここまでなら先ほどまでとそこまで変わらないから大丈夫ですよね？？

さて、次にメッセージを書き換えてみましょう。

```java:generators/GreetingMessageGenerator.java
package generators;

public class GreetingMessageGenerator {
  public String generate() {
    return "Hello, Java.";
  }
}
```

書き換えたのは GreetingMessageGenerator.java だけなので、コンパイルし直すのはそのファイルだけです。

```console
$ javac generators/GreetingMessageGenerator.java
$ java Application
Hello, World.
```

パッケージの中のクラスファイルも更新する必要があります。

```console
$ jar -uf app.jar generators/GreetingMessageGenerator.class
$ java -jar app.jar
Hello, World.
```

複数ファイルのプログラムでは、ファイルを更新するごとにこの処理が必要になります。
もちろん、毎回全てのファイルをコンパイルし直しやパッケージの作り直しをしてもかまいませんが、プログラムのサイズが大きくなればなるほど時間がかかるようになってしまいます。

## Gradle を使った場合

Gradle を使ったプロジェクトも同様にしましょう。ディレクトリは全て `src/main/java/with_gradle` 以下に作りましょう。

```java:src/main/java/with_gradle/generators/GreetingMessageGenerator.java
package generators;

public class GreetingMessageGenerator {
  public String generate() {
    return "Hello, World.";
  }
}
```

```java:src/main/java/with_gradle/Application.java
import generators.GreetingMessageGenerator;

public class Application {
  public static void main(String[] args) {
    String message = new GreetingMessageGenerator().generate();
    System.out.println(message);
  }
}
```

さて、ビルドや実行手順はファイルが１つだろうが複数だろうが、変わりません。

```console
$ ./gradlew build
$ java -jar build/libs/app.jar
Hello, World.
$ ./gradlew run
Hello, World.
```

また、更新されていないプログラムは無駄にコンパイルされないなど、便利な機能がいっぱいです！

# 外部のライブラリを使う Java アプリ

よくある処理はライブラリにまとめられていることがほとんどです。例えば、yaml のパースをするなら [SnakeYAML](https://bitbucket.org/asomov/snakeyaml/wiki/Documentation) などがあります。
次に、素の Java と Gradle を使った場合とでライブラリを用いたプログラムの比較をしてみましょう。

## 素の Java で書くと？

まず、素の java プログラムを書くのであれば、ライブラリをダウンロードしてくる必要があります。
ひとまず SnakeYAML の最新版は [https://repo1.maven.org/maven2/org/yaml/snakeyaml/1.21/snakeyaml-1.21.jar](https://repo1.maven.org/maven2/org/yaml/snakeyaml/1.21/snakeyaml-1.21.jar) にあります。

```console
$ cd path/to/vanilla_java
$ wget https://repo1.maven.org/maven2/org/yaml/snakeyaml/1.21/snakeyaml-1.21.jar
```

さて、このライブラリファイルですが、基本的には git 管理しません。
なぜ管理しないかは色々あるのですが、簡単にいうと

* 外部ライブラリのバージョン管理は外部ライブラリ側でやるので自前でバージョン管理する必要はない
* git リポジトリが肥大化するので避けたい

みたいな理由です。

さて、早速このライブラリを使ったクラスを作成し、 Application.java からそれを使うように修正してみましょう。

```java:src/main/java/with_gradle/generators/YamlMessageGenerator.java
package generators;
import org.yaml.snakeyaml.Yaml;

public class YamlMessageGenerator {
  public String generate() {
    String document = "message: Hello, YAML";
    Yaml yaml = new Yaml();
    Message message = (Message) yaml.loadAs(document, Message.class);
    return message;
  }

  public static class Message {
    String message;

    public String getMessage() {
      return this.message;
    }
    public void setMessage(String message) {
      this.message = message;
    }
  }
}
```

```java:Application.java
import generators.YamlMessageGenerator;

public class Application {
  public static void main(String[] args) {
    String message = new YamlMessageGenerator().generate();
    System.out.println(message);
  }
}
```

このプログラムをコンパイル・実行するときには、クラスパスにカレントディレクトリとライブラリとを指定する必要があります。

```console
$ javac -classpath .:snakeyaml-1.21.jar Application.java
$ java -classpath .:snakeyaml-1.21.jar Application
```

また、jar ファイルにまとめるときには Class-Path をマニフェストに設定する必要があります。

```Manifest.txt
Manifest-Version: 1.0
Main-Class: Application
Class-Path: snakeyaml-1.21.jar
```

jar にまとめた後、app.jar と snakeyaml-1.21.jar とが同じディレクトリにあるときに実行可能です。

```console
$ jar cvfm app.jar Manifest.text Application.class generators/*.class
$ java -jar app.jar
```

もちろん、使用するライブラリが増えれば増えるほど、クラスパスへの追加が増えていきますし、使用するライブラリのバージョン管理も大変です。

## Gradle を使った場合

Gradle を使っていれば、もう少し話は簡単になります。

先ずはソースコードを用意しましょう。

```java:gererators/YamlMessageGenerator.java
package with_gradle.generators;
import org.yaml.snakeyaml.Yaml;

public class YamlMessageGenerator {
  public String generate() {
    String document = "message: Hello, YAML";
    Yaml yaml = new Yaml();
    Message message = (Message) yaml.loadAs(document, Message.class);
    return message;
  }

  public static class Message {
    String message;

    public String getMessage() {
      return this.message;
    }
    public void setMessage(String message) {
      this.message = message;
    }
  }
}
```

```java:src/main/java/with_gradle/Application.java
import with_gradle.generators.YamlMessageGenerator;

public class Application {
  public static void main(String[] args) {
    String message = new YamlMessageGenerator().generate();
    System.out.println(message);
  }
}
```

次に、Gradle のビルドファイルに、外部ライブラリへの依存関係を記します。

ついでに、Fat-Jar (依存するライブラリなども全て含めた jar ファイル) を作るための [Shadow Plugin](http://imperceptiblethoughts.com/shadow/) も導入します。

```groovy:build.gradle
// Gradle でのビルド中に Shadow プラグインを使う
buildscript {
  repositories {
    jcenter()
  }
  dependencies {
    classpath 'com.github.jengelman.gradle.plugins:shadow:2.0.4'
  }
}
apply plugin: 'java'
apply plugin: 'application'
apply plugin: 'com.github.johnrengelman.shadow'
mainClassName = 'with_gradle.Application'

jar {
  manifest {
    baseName = 'app'
    attributes('Main-Class': mainClassName)
  }
}

// ライブラリを Maven リポジトリから取得する
repositories {
  mavenCentral()
}

// 依存関係として snakeyaml の 1.21 を追加する
dependencies {
  compile group: 'org.yaml', name: 'snakeyaml', version: '1.21'
}
```

さて準備ができたら早速ビルドしてみます。

```
$ ./gradlew build
$ java -jar build/libs/with_gradle-all.jar # fat-jar になっているので、直接実行できます
Hello, YAML
$ ./gradlew run
Hello, YAML
```

この後は、使用するライブラリが増えてもビルドスクリプトに追加するだけで済みますし、また、使用するライブラリのバージョンも明記されており、管理が簡単です。

ここまでのコードは [ayasuda/sandox/with_gradle](https://github.com/ayasuda/sandbox/tree/master/with_gradle) にあります。

# まとめ

ここまで Gradle を使った場合と使わないで手作業でやった場合とで Java プログラムの書き方を比較して見ましたがいかがでしょうか？
みなさんも、ぜひ Gradle を使って見てください。
