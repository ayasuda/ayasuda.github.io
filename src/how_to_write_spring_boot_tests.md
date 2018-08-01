Spring Boot のテスト事始め

Spring Boot ではテストしやすいような様々な機構を用意してくれています。
テスト支援は次の二つのモジュールで行われます。 `spring-boot-test` はテストのコア機能が、
`spring-boot-test-autoconfigure` はテストで使える自動設定機能が含まれています。

大抵の場合は、Spring Boot のその他の機能の例にもれず 'Starter' を使います。
具体的には `spring-bot-starter-test` を依存に組み込めば上記の 2 モジュールを自動的に読み込んでくれます。

これにより、以下のライブラリがテスト時に使えるようになります。

* JUnit
* Spring Test
* AssertJ
* Hamcrest
* Mockito
* JSONassert
* JsonPath

DI のメリットの一つとして、単体テストが容易になるという特徴があります。
依存関係にあるオブジェクトをモックに代替することが容易に行えるためです。

Spring Boot のアプリケーションは Spring の `ApplicationContext` にすぎません。
ですので、テストをするのに特別なことをする必要はなく、素の Spring context と同じようにテストをできます。

Spring Boot では `@SpringBootTest` アノテーションが提供されています。これは、Springboot の機能が必要な時に
標準的な `Spring-test` `@ContextConfiguration` の代わりに用いることができます。
このアノテーションはテスト中で `SpringApplication` により `ApplicationContext` が作成されるように動きます。

また、 `webEnvironment` を `@SpringBootTest` アノテーションの属性として使うことができます。
このアノテーションを使うことで、テストをより明示的にすることができます。

`@SpringBootTest(webEnvironment=MOCK)` のように下記の値を指定することができます。

* `MOCK`: `WebApplicationContext` をロードし、モックのサーブレット環境を提供します。
* `RANDOM_PORT`: `EmbededWebApplicationContext` をロードし、サーブレット環境を提供します。組み込まれたサーブレットコンテナはランダムなポートで起動します。
* `DEFINED_PORT`: `EmbededWebApplicationContext` をロードし、サーブレット環境を提供します。組み込まれたサーブレットコンテナは `application.properties` で指定されたポートまたは `8080` で起動します。
* `NONE`: `ApplicationContext` をロードします。サーブレット環境は提供しません。

テストには `@RunWith(SpringRunner.class)` をつけるのを忘れないでください。通常のテストランナーでは、Spring Boot のテスト用アノテーションが無視されてしまいます。
