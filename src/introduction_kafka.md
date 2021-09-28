---
title: 'Apache kafka ことはじめ'
date: '2100-12-31'
description: ''
keywords:
  - Java
  - Maven
---

Apache kafka はオープンソースのイベントストリーミングプラットフォームです。
公式サイトは https://kafka.apache.org/ です。

オープンソースのイベントストリームプラットフォームとは？
====

何かのサーバアプリケーションがイベントを投げると、別の何かのサーバアプリケーションがイベントを受け取って処理をする。
そんなシステムを作りたくなることがまれによくあると思います。

そんな時にいつも迷うのは、イベントのキュー、つまりイベントを投げる先・イベントを取得する元として何を使うかでしょう。

Kafka はイベントストリーム、つまり以下の特徴を備えたシステムを提供します。

* 他のシステムからイベントを書き込み (publish) および読み込み (subscribe) することができる
* 必要なだけイベントを保存できる
* 必要なだけイベントを遡って処理できる


さて、単なるイベント用のキューでなのであれば、MySQL や Redis 、はたまたその他の何かではダメなのでしょうか？
Kafka はイベントストリーミングに特化しているため、以下の特徴を備えます。

* 高スループット: 単位時間あたりのデータ転送量が他システムよりも優れています。大きなイベントデータをいっぱい送れます。
* 低遅延
* 障害を許容: Kafka クラスタ内のノードに障害があっても問題がない様に設計されています。
* 耐久性: イベントはキューに保存されます
* スケーラビリティ: ノードの追加時にダウンタイムが発生しませんし、最初からスケーラブルな分散システムとして設計されています。
* 統合: 外部システムにイベントをエクスポートしたり、逆にインポートしたりが簡単に行えます

Kafka のコンセプト
---

Kafka のコンセプトを理解するために、次の４つの用語、イベント、プロデューサー、コンシュマー、トピックを理解するのが一番です。

*「イベント」* は Kafka に送りつけられる何かで、 *「レコード」* や *「メッセージ」* とも呼ばれます。
イベントはキーと値、日時そしていくつかのメタデータで構成されます。
以下がイベントの例です。

* キー: "UNIX時間"
* 値: "カウントスタート！"
* 日時: "1970年1月1日午前0時0分0秒"

*「プロデューサー」* はこのイベントを Kafka に投げるクライアントアプリケーションで、*「コンシュマー」* はイベントを受け取るアプリケーションです。

イベントは *「トピック」* ごとに Kafka に保存されます。複数のプロデューサー、コンシュマーが１つのトピックを使うことが可能ですし、
Kafka 内に複数のトピックを設定することも可能です。
トピックに保存されたイベントは、コンシュマーがイベントを読み取ったあと *削除されません*。イベントは Kafka に設定されたイベントの保存時間経過後に削除されます。
ですので、イベントは必要なら何度でも読むことが可能です。

トピックは Kafka ブローカー、つまりは Kafka が提供する分散キューの中に分割して保存されます。
より正確に言うと、Kafka は複数のブローカーで構成されており、１つのブローカーが１つのサーバーで、１つのブローカーは複数のパーティションを持っており、
１つのイベントは多数のパケットに分割されパーティションの中に書き込まれます。
この辺りについては、下記にも紹介している記事の [システム構成](https://qiita.com/sigmalist/items/5a26ab519cbdf1e07af3#%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0%E6%A7%8B%E6%88%90) がわかりやすいので
適宜ご参照ください。

Kafka のより詳しい設計などについては公式ドキュメントの [DESIGN](https://kafka.apache.org/documentation/#design) か、
日立製作所 OSSソリューションセンタの方が書いた Qiita の記事、[Apache Kafkaの概要とアーキテクチャ - Qiita](https://qiita.com/sigmalist/items/5a26ab519cbdf1e07af3) が参考になるでしょう。


Kafka をつかってみよう (MacOS編)
====

インストール
----

```
$ brew install kafka

To start kafka:
  brew services start kafka
Or, if you don't want/need a background service you can just run:
  /usr/local/opt/kafka/bin/kafka-server-start /usr/local/etc/kafka/server.properties
```

起動は `brew services start kafka` で行えます。
設定ファイルは `/usr/local/etc/kafka/server.properties` にあります。

```
$ brew services start kafka
==> Successfully started `kafka` (label: homebrew.mxcl.kafka)
```

Kafka をインストールすると、一緒に Kafka 管理用のサービスである zookeeper もインストールされます。
Kafka の管理は、 Zookeeper を通して行います。
ですので、 Zookeepr も起動しておきます

```
$ brew services start zookeeper
==> Successfully started `kafka` (label: homebrew.mxcl.kafka)
```

Zookeeper のデフォルトポートは `/usr/local/etc/kafka/server.properties` の `zookeeper.connect` に記載があり、デフォルトは 2181 番です。

トピックを作る
----

```
$ kafka-topics --list --zookeeper localhost:2181
$ kafka-topics --create --zookeeper localhost:2181 --topic test-topic --partitions 1 --replication-factor 1
Created topic test-topic.
$ kafka-topics --list --zookeeper localhost:2181
test-topic
$ kafka-topics --describe --zookeeper localhost:2181 --topic test-topic
Topic: test-topic       TopicId: 06sO9V5mSzO_O2U3js2JvA PartitionCount: 1       ReplicationFactor: 1    Configs:
        Topic: test-topic       Partition: 0    Leader: 0       Replicas: 0     Isr: 0
```


イベントを書き込む
---


イベントを読みこむ
---




https://deeeet.com/writing/2015/09/01/apache-kafka/
https://qiita.com/sigmalist/items/5a26ab519cbdf1e07af3
https://data-flair.training/blogs/advantages-and-disadvantages-of-kafka/
