---
title: 'Language Server 事始め'
draft: true
description: 'エディタの補完を専門のサーバで行う Language Server と vim からの使用方法について簡単にまとめます。'
keywords:
- Language Server
- Vim
---

MEMO: 先に vim の補完について少し調べないと無理だわ

IDE や高機能なエディタの特徴としてコード補完があります。
例えば、 `printf()` 関数が定義されているとして、`pri` まで入力した後特定のキー操作で自動的に残りの `ntf()` が入力されるというのが
IDE やエディタのメリットです。

コード補完は IDE のプラグインやエディタがその役割を担っていましたが、2016年に Microsoft が公開した
[Microsoft/language-server-protocol](https://github.com/Microsoft/language-server-protocol) によって、大きく考え方が前進しました。

コードの解析や補完機能をバックグラウンドの Language Server で行い、各種エディタと Language Server は Language Server Protocol を使って
情報をやり取りする。それにより、どのエディタ・IDEでも同一の補完を実現できるようになったのです。

本文書では Vim に Language Server Protocol を使用するプラグインを導入しつつ、具体的な使い方について記していきます。

Whtat is Language Server Protocol?
====

必要な情報は [本家サイト](https://microsoft.github.io/language-server-protocol/) に大体書かれています。

今まではコードの自動補完や定義への移動、コメントの表示などはエディタごとのプラグインやIDEごとに、
それぞれ個別に実装されていました。
つまり、新しい言語が登場したり新たなエディタが誕生するごとに同じような機能の実装をバラバラに行なっていました。
これを解決するのが Language Server Protocol (LSP) です。

各エディタと別のプロセスで専用の Language Server を立ち上げ、エディタとサーバとは [JSON-RPC](https://www.jsonrpc.org/) で通信し、
エディタ上で様々な機能を実現させます。
これにより、新しい言語やエディタが登場したとしても、このプロトコルに沿ったプラグインやサーバを用意するだけで
今までと同じように自動補完や定義への移動が可能になります。

プロトコルの概要は[Overview](https://microsoft.github.io/language-server-protocol/overview) に記されています。
抜粋すると以下の通りです。

[](https://microsoft.github.io/language-server-protocol/img/language-server-sequence.png) // 画像

この図の Development Tool は IDE やエディタ、 Language Server は言語ごとのサーバを示しています。

最初にユーザがファイルを開くと `Notification: textDocument/didOpen; Params: document` がエディタから Language Server に送られているのが
わかります。
また、そのあとユーザの操作によって、 `textDocument/didChange` や `Request: textDocument/definition` など様々なイベントが送られているのが
わかるかと思います。

ここでのやり取りは JSON-RPC で行われます。
例えば、ユーザが IDE 上で「定義へ移動」を行なった時に呼び出される `Request: textDocument/definition` では、具体的に以下の JSON が
Language Server へ送られます。

```json
{
  "jsonrpc": "2.0",
  "id" : 1,
  "method": "textDocument/definition",
  "params": {
    "textDocument": {
      "uri": "file:///p%3A/mseng/VSCode/Playgrounds/cpp/use.cpp"
    },
    "position": {
      "line": 3,
      "character": 12
    }
  }
}
```

そして、Language Server からは以下のレスポンスが返されます。

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "uri": "file:///p%3A/mseng/VSCode/Playgrounds/cpp/provide.cpp",
    "range": {
        "start": {
          "line": 0,
          "character": 4
        },
        "end": {
          "line": 0,
          "character": 11
        }
    }
  }
}
```

各エディタ・IDE向けの LSP サポート実装は [Tools supporting the LSP](https://microsoft.github.io/language-server-protocol/implementors/tools/) に、
プログラミング言語別の Language Server 実装は [Language Servers](https://microsoft.github.io/language-server-protocol/implementors/servers/) に
それぞれまとまっています。
また、 [Langserver.org](https://langserver.org/) にも、各種実装がまとまっています。
また、 Language Server を実装するための SDK については [SDKs for the LSP](https://microsoft.github.io/language-server-protocol/implementors/sdks/) に
まとまっています。

Language Server
----

簡単な ruby プロジェクトを作り、language server を立ち上げ、 JSON-RPC プロトコルで会話してみる

Develop tools
----

偽 language serever を作り、エディタのプラグインから呼び出してみる

```
$ git clone git@github.com:redmine/redmine.git
$ cd redmine

