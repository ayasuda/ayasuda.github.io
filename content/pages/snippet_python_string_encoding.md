---
title: 'Python での文字列エンコーディング'
date: '2023-07-12'
description: 'Python で tbd'
tags:
  - Python
keywords:
  - Python
  - String
  - Encoding
---

文字列をプログラムから扱う際に、エンコーディングは避けて通れない問題です。
UTF-8 で記述された文字列を Shift-JIS で読もうとすれば文字化けしてしまいますし、その逆も起こります。
本記事では、Python を用いて各種エンコーディングに関する操作を解説していきます。

## ソースコードを UTF-8 で記述する

Python のソースコードはデフォルトで UTF-8 で記述され、
Python の文字列、つまり str 型は Unicode コードポイントのシーケンスです。

つまり、ごく普通に文字列リテラルのなかに Unicode 文字を含められます。

```python
s = "こんにちは python 🐍"
print(s)
```

```console
こんにちは python 🐍
```

また、変数名やメソッド名など識別子にも Unicode 文字を使うことができます。

```python
文字列 = "識別子に Unicode 文字列を使うこともできます"
print(文字列)
```

```console
識別子に Unicode 文字列を使うこともできます
```

ただし、ライブラリ名としては ASCII 以外の文字を使うことができません。

## ソースコードを UTF-8 以外で記述する

Python2 時代は、ソースコードのデフォルトエンコーディングは ASCII でした。
その時代の名残ですが、マジックコメントを書くことでソースコードを任意のエンコーディングで記述することができます。

マジックコメントとは、ファイルの最初の行、または [Unix のシェバン](https://ja.wikipedia.org/wiki/%E3%82%B7%E3%83%90%E3%83%B3_(Unix)) の次の行に以下のフォーマットで記述したコメントです。

```
# -*- conding: encoding -*-
```

`encoding` には [codecs](https://docs.python.org/3/library/codecs.html#module-codecs) モジュールで取り扱えるエンコーディングを指定できます。
例えば、いわゆる Shift_JIS でソースコードを記述したい場合、以下の通り `cp932` を指定することでソースコードを書くことができます。

```
# -*- coding: cp932 -*-
```

シェバンと同時に記述した例は以下のとおりです。

```
#!/usr/bin/env python3
# -*- coding: cp932 -*-
```

マジックコメントがない場合は、Python はデフォルトの UTF-8 でソースコードが記述されているものとみなします。

## エスケープシーケンスを用いて、入力が難しい Unicode 文字を文字列リテラルの一部に埋め込む

文字の中には直接、文字列の中に埋め込むことが難しい文字もあります。
例えば絵文字は普通のキーボードを使っていると入力が難しいですし、日本語キーボードを使っている人はギリシア文字の入力は難しいでしょう。

このような時はエスケープシーケンスを使うことで、任意の Unicode 文字を文字列リテラルの中にいれることができます。

| エスケープシーケンス | 説明 |
| \N{name} | Unicode データベース中で name という名前を持つ文字。データベースは https://www.unicode.org/ucd/ にあります。 |
| \uxxxx | 16 ビットの値で表した Unicode 文字。コード表は https://ja.wikipedia.org/wiki/Unicode%E4%B8%80%E8%A6%A7%E8%A1%A8 を参照して下さい。 |
| \Uxxxxxxxx | 32 ビットの値で表した Unicode 文字。コード表は https://ja.wikipedia.org/wiki/Unicode%E4%B8%80%E8%A6%A7%E8%A1%A8 を参照して下さい。 |
| \ooo | 8 進数 ooo で表した ASCII 文字。コード表は https://e-words.jp/p/r-ascii.html を参照してください。 |
| \xhh | 16 進数 hh で表した ASCII 文字。コード表は https://e-words.jp/p/r-ascii.html を参照してください。 |

```python
print("Unicode の文字名を使った文字種を '\N{HIRAGANA LETTER WE}' のように表すことができます")
print("Unicode コードを 16 ビットの 16 進数値を用いて '\u3237' のように表すことができます。")
print("Unicode コードを 32 ビットの 16 進数値を用いて '\U000032FF' のように表すことができます。")
print("ASCII コードを 16 進数値を用いて '\x62' のように表すことができます。")
```

```console
Unicode の文字名を使った文字種を 'ゑ' のように表すことができます
Unicode コードを 16 ビットの 16 進数値を用いて '㈷' のように表すことができます。
Unicode コードを 32 ビットの 16 進数値を用いて '㋿' のように表すことができます。
ASCII コードを 16 進数値を用いて 'b' のように表すことができます。
```

## バイト列を文字列にデコードする

ファイルやインターネットから取得したデータなどが UTF-8 ではない場合があります。
その場合は、ひとまずバイト列として扱い、そのうえで文字列に変換する必要があります。

バイト列を文字列に変換するには [decode](https://docs.python.org/ja/3/library/stdtypes.html#bytes.decode) を使います。

```
print(b'abcde'.decode("utf-8"))
print(b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8"))
print(b'\x82\xb1\x82\xea\x82\xcd\x95\xb6\x8e\x9a\x97\xf1\x82\xc5\x82\xb7'.decode("cp932"))
```

```console
abcde
これは文字列です
これは文字列です
```

`decode` は２つの引数をとります。

第1引数はエンコーディングです。デフォルトは 'utf-8' で、省略可能です。

```
# 第1引数を省略した場合、デフォルトの UTF-8 としてデコードします
print(b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode())
```

```console
これは文字列です
```

使用可能なコーデックは [公式サイトの標準エンコーディング](https://docs.python.org/ja/3/library/codecs.html#standard-encodings) のページにまとまっています。
例えば、Windows で使用しているいわゆる Shift_JIS (または MS_Kanji ) は 'cp932' という名前でデコードできます。

```
print(b'\x82\xb1\x82\xea\x82\xcd\x95\xb6\x8e\x9a\x97\xf1\x82\xc5\x82\xb7'.decode("cp932"))
```

```console
これは文字列です
```

なお、[公式サイトの標準エンコーディング](https://docs.python.org/ja/3/library/codecs.html#standard-encodings) にも記載のある 'shift_jis’ ですが、
こちらは MS Windows で使用されている Shift JIS とはことなります。[Wikipedia の Shift_JIS](https://ja.wikipedia.org/wiki/Shift_JIS) にも記載のある通り、
MS Windows では標準的な Shift_JIS を拡張した文字コード (cp932) を使用しているためです。

第2引数はエラー発生時にどうするかを表す定数で、デフォルトは 'strict' です。
指定できる値の一覧は [公式サイトのエラーハンドラ](https://docs.python.org/ja/3/library/codecs.html#error-handlers) のページにまとまっています。

先ほどから使用している以下のバイト列をベースに、動きの違いを見ていきましょう。
'これは文字列です' という UTF-8 のバイト列の途中、
具体的には「字」を表す '\xe5\xad\x97' の間に不正なバイト '\x80' を挿入し、それぞれのエラーハンドラの違いをみていきます。
なお、 '\xe5\xad\x80' は「孀」であり、バイト列としてはこの次に '\x97' という不正なバイトが入った状態になります。


```console
$ python
Python 3.9.1 (default, Jan 17 2021, 16:20:03)
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8")
'これは文字列です'
```

デフォルトでもある 'strict' はエラー発生時に UnicodeDecodeError を発生させます。
不正なバイトとして '\x97' が 15 文字目に入っていることが報告されます。

```console
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x80\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8", "strict")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  UnicodeDecodeError: 'utf-8' codec can't decode byte 0x97 in position 15: invalid start byte
```

'ignore' は不正なデータを無視してデコードを続行します。'\xe5\xad\x80' は「孀」として解釈されました。

```console
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x80\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8", "ignore")
'これは文孀列です'
```

'replace' はエラー部分を 'U+FFFD' (Unicode の REPLACEMENT CHARACTER) に置き換えます。
この文字は [特殊用途文字](https://ja.wikipedia.org/wiki/%E7%89%B9%E6%AE%8A%E7%94%A8%E9%80%94%E6%96%87%E5%AD%97_(Unicode%E3%81%AE%E3%83%96%E3%83%AD%E3%83%83%E3%82%AF) のひとつで
「不明な文字」を表します。


'\xe5\xad\x80' は「孀」として解釈され、つづく '\x97' が REPLACEMENT CHARACTER に置き換えられます。

```console
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x80\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8", "replace")
'これは文孀�列です'
```

'backslashreplace' はエラー部分をバックスラッシュ付きのエスケープシーケンス (\xhh 形式) に置き換えます。

'\xe5\xad\x80' は「孀」として解釈され、つづく '\x97' が '\\x97' となるように置き換えられます。

```console
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x80\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8", "backslashreplace")
'これは文孀\\x97列です'
```

## 文字列をバイト列にエンコードする

ファイルやネットワークへのレスポンスとして UTF-8 ではないデータを書き出したい場合があります。
その場合は、文字列を特定文字コードのバイト列に変換して取り扱います。

文字列はバイト列に変換するには [encode](https://docs.python.org/ja/3/library/stdtypes.html#str.encode) を使います。

TODO: サンプル文字列とアウトプット

```python
s = "こんにちは"
print(s.encode("utf-8"))
print(s.encode("cp932"))
```

`encode` は２つの引数をとります。

第1引数はエンコーディングです。デフォルトは 'utf-8' で、省略可能です。

```
# 第1引数を省略した場合、デフォルトの UTF-8 としてデコードします
print('こんにちは'.encode())
```

使用可能なコーデックは [公式サイトの標準エンコーディング](https://docs.python.org/ja/3/library/codecs.html#standard-encodings) のページにまとまっています。
例えば、Windows で使用しているいわゆる Shift_JIS (または MS_Kanji ) には 'cp932' という名前でエンコードできます。

```
print(b'\x82\xb1\x82\xea\x82\xcd\x95\xb6\x8e\x9a\x97\xf1\x82\xc5\x82\xb7'.decode("cp932"))
```

```console
これは文字列です
```

なお、[公式サイトの標準エンコーディング](https://docs.python.org/ja/3/library/codecs.html#standard-encodings) にも記載のある 'shift_jis’ ですが、
こちらは MS Windows で使用されている Shift JIS とはことなります。[Wikipedia の Shift_JIS](https://ja.wikipedia.org/wiki/Shift_JIS) にも記載のある通り、
MS Windows では標準的な Shift_JIS を拡張した文字コード (cp932) を使用しているためです。

第2引数はエラー発生時にどうするかを表す定数で、デフォルトは 'strict' です。
指定できる値の一覧は [公式サイトのエラーハンドラ](https://docs.python.org/ja/3/library/codecs.html#error-handlers) のページにまとまっています。

日本語の含まれた文字列を、日本語のエンコーディングが存在しない "ascii" に変換することでエラーを発生させて、動きの違いを見ていきましょう。


```console
$ python
Python 3.9.1 (default, Jan 17 2021, 16:20:03)
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8")
'これは文字列です'
```

デフォルトでもある 'strict' はエラー発生時に UnicodeDecodeError を発生させます。
不正なバイトとして '\x97' が 15 文字目に入っていることが報告されます。

```console
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x80\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8", "strict")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  UnicodeDecodeError: 'utf-8' codec can't decode byte 0x97 in position 15: invalid start byte
```

'ignore' は不正なデータを無視してデコードを続行します。'\xe5\xad\x80' は「孀」として解釈されました。

```console
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x80\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8", "ignore")
'これは文孀列です'
```

'replace' はエラー部分を 'U+FFFD' (Unicode の REPLACEMENT CHARACTER) に置き換えます。
この文字は [特殊用途文字](https://ja.wikipedia.org/wiki/%E7%89%B9%E6%AE%8A%E7%94%A8%E9%80%94%E6%96%87%E5%AD%97_(Unicode%E3%81%AE%E3%83%96%E3%83%AD%E3%83%83%E3%82%AF) のひとつで
「不明な文字」を表します。


'\xe5\xad\x80' は「孀」として解釈され、つづく '\x97' が REPLACEMENT CHARACTER に置き換えられます。

```console
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x80\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8", "replace")
'これは文孀�列です'
```

'backslashreplace' はエラー部分をバックスラッシュ付きのエスケープシーケンス (\xhh 形式) に置き換えます。

'\xe5\xad\x80' は「孀」として解釈され、つづく '\x97' が '\\x97' となるように置き換えられます。

```console
>>> b'\xe3\x81\x93\xe3\x82\x8c\xe3\x81\xaf\xe6\x96\x87\xe5\xad\x80\x97\xe5\x88\x97\xe3\x81\xa7\xe3\x81\x99'.decode("utf-8", "backslashreplace")
'これは文孀\\x97列です'
```

## 1 文字のUnicode 文字列を作成する - chr()

キーボードから入力が難しい特定の１文字だけが必要な場合、 [chr](https://docs.python.org/ja/3/library/functions.html#chr) を用いることで
1文字の Unicode 文字を得ることができます。

引数としては整数値を入れることができます。

例えば、「イ」は U+30a4 ですので、`30a4` を 10 進数表記した `12452` を引数とするか、引数を 16 進数表記 `0x30a4` とすることで得られます。

```python
print(chr(12452))
print(chr(0x30a4))
## 引数の有効な範囲は 0 から 1,114,111 (16 進数で 0x10FFFF)
```

```console
イ
イ
```

## 1 文字の Unicode 文字列からコードポイントを返す - ord()

特定の文字の Unicode コードポイントが知りたい場合、[ord](https://docs.python.org/ja/3/library/functions.html#ord) を用いることで整数値が得られます。

例えば「イ」を入れると `12452` が得られます。
なお、整数値は [hex](https://docs.python.org/ja/3/library/functions.html#hex) を用いることで 16 進数表記 (\0x 形式) の文字列に変換することができます。

```python
print(ord("イ"))
print(hex(ord("イ")))
```

```console
12452
0x30a4
```

## 参考リンク

本記事は以下のリンクを参考にしています。

* https://docs.python.org/ja/3/howto/unicode.html#unicode-howto
* https://realpython.com/python-encodings-guide/#covering-all-the-bases-other-number-systems
* https://qiita.com/ny7760/items/d9c247781a790210936d
