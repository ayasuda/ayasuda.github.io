---
title: 'プログラムの引数に関する考え方 (コマンドライン引数・環境変数・設定ファイルの優先順位)'
date: '2100-12-31'
description: ''
keywords:
  - Java
  - Maven
---

コマンドラインツールを作る際に引数をプログラムに渡す方法として、次の3つの方法があります。
コマンドライン引数、環境変数、設定ファイルです。

ここでは、それぞれの使い分けと優先順位について、私見を述べていきます。

コマンドライン引数、環境変数、設定ファイル
====

コマンドライン引数はプログラム実行時に渡すことのできる値です。例えば、 `rm` コマンドにはコマンドライン引数としてファイル名を渡すことができます。

```
$ rm some_file # some_file がコマンドライン引数
```

コマンドライン引数は実行時にユーザが指定するので、プログラム実行時に最も柔軟に設定可能な値です。
ですので、他の2つの方法で設定した値などもコマンドライン引数で上書き可能にしておくのが良いでしょう。

例えばあなたのプログラムが環境変数 `EDITOR` で設定されたエディタを立ち上げるとして、
コマンドライン引数でもエディタを設定できるなら、コマンドライン引数の設定が優先して使われるようにします。

```
$ export EDITOR=/usr/local/bin/vim # 例えば EDITOR を設定しておくとして
$ yourprogram # この場合は環境変数 `EDITOR` が使われる
$ yourprogram --editor /usr/bin/nano # コマンドラインオプションで使用するエディタを上書きできる
```

環境変数は Linux では3つの階層で設定できる値です。
まず全てのユーザで共通して設定できるシステム環境変数があります。
例えば `/etc/profile` に設定してある環境変数は、その Linux に登録された全てのユーザで共通して読み込むことができます。
次に設定可能なのはユーザごとの環境変数で、これはそれぞれのホームディレクトリにある設定ファイルで設定します。
例えば bash なら `~/.bash_profile` などで設定可能な値です。
最後にシェルの実行中に環境変数を上書きすることもできます。
例えば、`export` コマンドで環境変数を上書き可能です。

```
$ export EDITOR=/usr/bin/nano
```

設定ファイルは最も柔軟に設計することが可能ですが、ユーザが実行時に気軽に変更するものではありません。
また、設定ファイルも階層をつけることもできます。

例えば MySQL の設定ファイル my.cnf は `/etc/my.cnf`, `/etc/mysql/my.cnf` `~/my.cnf` など複数ファイルで定義することができ、後に行くほど設定が優先されます。


https://stackoverflow.com/questions/7443366/argument-passing-strategy-environment-variables-vs-command-line
https://dzone.com/articles/configuration-files
https://12factor.net/config
https://support.cloud.engineyard.com/hc/en-us/articles/205407508-Environment-Variables-and-Why-You-Shouldn-t-Use-Them
https://gist.github.com/telent/9742059
https://www.cs.ait.ac.th/~on/O/oreilly/unix/upt/ch06_01.htm
