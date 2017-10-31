---
title: 'これはタイトルです'
---
# YARD のアーキテクチャ

YARD は主に３つのコンポーネントに分けられています。

* Code Parsing & Processing
* Data Storage
* Post Processing & Output Generation

主な流れとしては次の通りです。
まず、 Code Parsing & Processing コンポーネントが
文書化対象のファイルをパースし、その結果を Data Storage コンポーネント内に格納します。
次に Post Processing & Output Generation コンポーネントが
Data Storage の内容を参照しながらドキュメントを出力します。

実装を見てみましょう。 `yardoc foo.rb` コマンドを実行した時に呼び出されるのは
[YARD::CLI::Yardoc.rub](http://www.rubydoc.info/gems/yard/YARD/CLI/Yardoc#run-instance_method)
です。
このメソッドの実装は上で説明した通りとなっています。
コマンドライン引数のパースなどを省き、メインとなる処理を抜き出すと次のようになります。

```rb
if save_yardoc
  Registry.lock_for_writing do
    # Code Parsing & Processing コンポーネントを呼び出し
    # 対象ファイルをパースし、結果を Data Storage コンポーネントの Registry に書き込む
    YARD.parse(files, excluded)

    # Data Storage コンポーネントの Registry の内容を永続化する
    Registry.save(use_cache)
  end
else
  # Code Parsing & Processing コンポーネントを呼び出し
  # 対象ファイルをパースし、結果を Data Storage コンポーネントの Registry に書き込む
  YARD.parse(files, excluded)
end

if generate
  # Post Processing & Output Generation コンポーネントを呼び出し
  # Storage の内容を書き出す
  run_generate(checksums)
  copy_assets
elsif list
  print_list
end
```

基本となる動きをなんとなく把握しましたら、次に各コンポーネントの中を深堀りしていきましょう。

## Code Parsing & Processing Component

文書化対象のファイルをパースし、その構造を Data Storage コンポーネントの
[YARD::Registory](http://www.rubydoc.info/gems/yard/YARD/Registry)
に突っ込むコンポーネントです。

このコンポーネントは以下に示す４つのサブコンポーネントで構成されています。

* [Parser](http://www.rubydoc.info/gems/yard/file/docs/Parser.md): ソースファイルを解析し、ステートメントごとに登録されている Handler に渡します
* [Handlers](http://www.rubydoc.info/gems/yard/file/docs/Handlers.md): ステートメントを受け取り、 CodeObject を生成します
* [CodeObjects](http://www.rubydoc.info/gems/yard/file/docs/CodeObjects.md): 解析した結果作られるオブジェクトのツリーで、 Registroy に突っ込まれます
* [Tags](http://www.rubydoc.info/gems/yard/file/docs/Tags.md): Handler などにより CodeObject に添付されるメタデータです

## Data Storage Component

このコンポーネントの実装は
[YARD::Registory](http://www.rubydoc.info/gems/yard/YARD/Registry)
です。

Code Parsing & Processing Component によ生成されたデータはこの Registroy 内に格納され、永続化され、そしてアクセスされます。
YARD は拡張可能であり、その気になればより良いストレージなどに Registory を置き換え可能です。

## Post Processing & Output Generation Component

このコンポーネントは Registroy に記録された CodeObject を元に、様々な種類のアウトプットを生成するコンポーネントです。
アウトプットのフォーマットやデザイン、どのようにアウトプットするかなどはすべて変更可能で、詳細は
[Templates Archtecture](http://www.rubydoc.info/gems/yard/file/docs/Templates.md)
に記載されています。

# Parser

YARD が文書化をする際、最初に呼び出されるコンポーネントが Parser です。
Parser の役割は、ソースファイルを解析し、次に起動する
[Handlers](http://www.rubydoc.info/gems/yard/file/docs/Handlers.md)
が理解出来る「ステートメント」のセットに変換することです。

`YARD.parse(files, excluded)` からの流れを見てみましょう。
[YARD.parse](http://www.rubydoc.info/gems/yard/YARD#parse-class_method) は実装を見ればわかりますが、そのまま
[YARD::Parser::SourceParser](http://www.rubydoc.info/gems/yard/YARD/Parser/SourceParser) の `.parse` を呼び出します。

```rb
# File 'lib/yard.rb', line 20
def self.parse(*args) Parser::SourceParser.parse(*args) end
```

`YARD::Parser::SourceParser` の主な役割は
[YARD::Parser::Base](http://www.rubydoc.info/gems/yard/YARD/Parser/Base)
の具象クラスのファクトリです。

ファイルごとに拡張子や内容などを見て、どの Parser を使ってソースを解析するかを決め、パースをします。
YARD はデフォルトで
[YARD::Parser::Ruby](http://www.rubydoc.info/gems/yard/YARD/Parser/Ruby)
と
[YARD::Parser::C](http://www.rubydoc.info/gems/yard/YARD/Parser/C)
が同梱されているので、 Ruby と C のコードをパースできます。

YARD::Parser::Base を継承したクラスを定義し、
[YARD:：Parser：：SourceParser.register_parser_type](http://www.rubydoc.info/gems/yard/YARD/Parser/SourceParser#register_parser_type-class_method)
でパーサを登録することで、他言語のパースをすることも可能です。
例えば、[pvande/yard-perl-plugin](https://github.com/pvande/yard-perl-plugin) では perl のパーサが定義されています。

さて、`YARD::Parser::SourceParser.parse` はファイルの並び替えや無視するファイルの整理などをした後、
ファイルごとに
[YARD::Parser::SourceParser#parse](http://www.rubydoc.info/gems/yard/YARD%2FParser%2FSourceParser:parse)
を呼び出します。

ソースから重要なところを抜粋しましょう。
`parse` メソッドではファイルごとにパーサを作り、ファイルをパースしています。
パースすることで、ソースコードがステートメントごとに分解されます。
その後 `post process` メソッドを呼び出しています。

`post process` メソッドでは `Handlers::Processor` を作り、
`Handlers::Processor#process` を呼ぶことで Handlers が呼び出されます。

```rb
# 以下、各行の間に中略いっぱいあります
def parse(content = __FILE__)
  @file = File.cleanpath(content)
  @parser = parser_class.new(content, file)
  @parser.parse
  post_process
  @parser
end

private

def post_process
  return unless @parser.respond_to?(:enumerator)
  enumerator = @parser.enumerator
  if enumerator
    post = Handlers::Processor.new(self)
    post.process(enumerator)
  end
end
```

もう少し詳しくパースを行うところを見ていきましょう。
普通の ruby プログラムのファイルが指定されている時、パーサクラスは
[YARD::Parser::Ruby::RubyParser](http://www.rubydoc.info/gems/yard/YARD/Parser/Ruby/RubyParser) が使われます。
このパーサの内部では
[Ripper](https://docs.ruby-lang.org/ja/latest/class/Ripper.html)
が使われており、ParseTree などと似た様な S式ライブラリと同じ様な構文木を生成します。
構文木の各ノードは
[YARD::Parser::Ruby::AstNode](http://www.rubydoc.info/gems/yard/YARD/Parser/Ruby/AstNode)
のサブクラスで構成されています。
