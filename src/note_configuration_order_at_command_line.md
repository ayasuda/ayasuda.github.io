---
title: 'コマンドラインツールでの設定値の優先順（設定ファイル・環境変数・コマンドライン引数）'
date: '2019-07-22'
description: 'コマンドラインツールを作る時、プログラムがユーザから値を受ける方法は何通りもあります。特に代表的なのが設定ファイル・環境変数・コマンドライン引数です。本記事では、一般的にこれらをどのような優先順位で扱うかを調べていきます。'
tags:
  - Tips
  - プログラミング作法
keywords:
  - Command Line Tool
  - Option
  - Configuration
  - Programming Note
---

コマンドラインツールを作る時、プログラムがユーザから値を受ける方法は何通りもあります。
特に代表的なのが設定ファイル・環境変数・コマンドライン引数です。
自分でプログラムを書く場合、これらの値を自分の好きな順番で扱えます。
ただ、自分の好きな順番で扱えるからこそ、何をどのような優先順位で処理すべきか迷うこともあるでしょう。
本記事では、各種値を一般的にはどのように処理していくかを調べていきます。

結論
====

[environment variables - What order of reading configuration values? - Stack Overflow](https://stackoverflow.com/questions/11077223/what-order-of-reading-configuration-values) でも言及されていますが、下記の優先順位で値を設定するのがベターでしょう。

1. コマンドライン引数
2. コマンドライン引数で明示的に指定された設定ファイルからの値
3. 環境変数
4. ローカルの設定ファイル
5. グローバルな設定ファイル

# 他のプロダクトではどうなっているか？

## SpringBoot における設定の優先順位

Java のフレームワークである SpringBoot では次の順番で設定が読み込まれます。
https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html

1. ホームディレクトリにある [Devtool のグローバルな設定](https://docs.spring.io/spring-boot/docs/current/reference/html/using-boot-devtools.html#using-boot-devtools-globalsettings) (devtool が有効になっておりかつ `~/.spring-boot-devtools.properties` がある場合)
2. テストに記されている `[@TestPropertySource](https://docs.spring.io/spring/docs/5.1.8.RELEASE/javadoc-api/org/springframework/test/context/TestPropertySource.html)` アノテーションの値
3. [アプリケーションの一部をテストするため](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-testing.html#boot-features-testing-spring-boot-applications-testing-autoconfigured-test) の `[@SpringBootTest](https://docs.spring.io/spring-boot/docs/2.1.6.RELEASE/api/org/springframework/boot/test/context/SpringBootTest.html)` で設定されたテスト用の値
4. コマンドライン引数の値
5. 環境変数 `SPRING_APPLICATION_JSON` の値
6. `ServletConfig` の初期化値
7. `ServletContext` の初期化値
8. `java:comp/env` で設定された JNDI の値
9. Java System properties
10. OS の環境変数

(11 以上は略)

## AWS Coomand Line interface における設定の優先順位

AWS CLI では下記の順番で値が読み込まれます。
https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html

> * If you specify an option by using one of the environment variables described in this topic, it overrides any value loaded from a profile in the configuration file.
> * If you specify an option by using a parameter on the CLI command line, it overrides any value from either the corresponding environment variable or a profile in the configuration file.

つまり、

1. コマンドライン引数
2. 環境変数
3. 設定ファイル

の順番です。

# 参考

* https://stackoverflow.com/questions/11077223/what-order-of-reading-configuration-values
* https://dzone.com/articles/configuration-files
