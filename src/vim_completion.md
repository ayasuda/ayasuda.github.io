---
title: 'vim の補完'
date: '2100-03-14'
description: 'vim の各種補完についてまとめた'
keywords:
  - vim
  - completion
  - auto-complete
---

プログラミング用のエディタとして名高い "Vim"。
Vim には便利なコードの補完機能があります。
ユーザマニュアルの[テキストの挿入と置換 - 5. 置換モード](https://vim-jp.org/vimdoc-ja/insert.html#ins-completion) にその詳しい記述がありますが、あまり読まずに使っている方も多いのでは？
技術系まとめ記事といえば Qiita !
せっかくなので調べてみました!

Vim が用意している補完 13 選!
====

[ins-completion](https://vim-jp.org/vimdoc-ja/insert.html#ins-completion) によれば、Vim の補完は13種類があるそうです。

> 1. 行全体                                               `i_CTRL-X_CTRL-L`
> 2. 現在のファイルのキーワード                           `i_CTRL-X_CTRL-N`
> 3. 'dictionary' のキーワード                            `i_CTRL-X_CTRL-K`
> 4. 'thesaurus' のキーワード, thesaurus-style            `i_CTRL-X_CTRL-T`
> 5. 編集中と外部参照しているファイルのキーワード         `i_CTRL-X_CTRL-I`
> 6. タグ                                                 `i_CTRL-X_CTRL-]`
> 7. ファイル名                                           `i_CTRL-X_CTRL-F`
> 8. 定義もしくはマクロ                                   `i_CTRL-X_CTRL-D`
> 9. Vimのコマンドライン                                  `i_CTRL-X_CTRL-V`
> 10. ユーザー定義補完                                    `i_CTRL-X_CTRL-U`
> 11. オムニ補完                                          `i_CTRL-X_CTRL-O`
> 12. スペリング補完                                      `i_CTRL-X_s`
> 13. 'complete' のキーワード                             `i_CTRL-N i_CTRL-P`
(ins-completion より抜粋)

どの補完も挿入モード中に実行可能なようです。 (コマンドが `i_` から始まるからお分かりですね!)
また、 13 番の `CTRL-N`, `CTRL-P` 補完以外は全て `CTRL-X `から始まります。
Vim では挿入モード中に `CTRL-X` を押すと `CTRL-X` モードになるそうです。
　
(ここにgif)

それぞれの補完では、補完候補がポップアップで表示されます。
ポップアップから候補を選んで、 `CTRL-Y` を押すと候補が挿入されて挿入モードに戻ります。
また、 `Enter` キーを押すと、候補が挿入された上で改行も挿入されます。

ポップアップ表示中に補完をやめたい場合は `CTRL-E` で中止できます。

それぞれの補完を解説 - 1. 行全体を補完する
----

詳細は [compl-whole-line](https://vim-jp.org/vimdoc-ja/insert.html#compl-whole-line) にまとまっています。

挿入モード中に `CTRL-X` を入力して `CTRL-X` モードに入り、そのあと `CTRL-L` を入力すると行全体の補完ができるそうです。
現在行の途中までと一致する行が補完候補になり、ポップアップが表示されます。ポップアップ内の移動は `CTRL-L` か `CTRL-P` で上に、`CTRL-N` で下にカーソルを移動できます。

(ここにgif)


それぞれの補完を解説 - 2. 現在のファイルのキーワードで補完する
----

詳細は [compl-current](https://vim-jp.org/vimdoc-ja/insert.html#compl-current) にまとまっています。

(ここにgif)


それぞれの補完を解説 - 3. 'dictionary'のキーワードで補完する
----

詳細は [compl-dictionary](https://vim-jp.org/vimdoc-ja/insert.html#compl-dictionary) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 4. 'thesaurus' のキーワードで補完する
----

詳細は [i_CTRL-X_CTRL-T](https://vim-jp.org/vimdoc-ja/insert.html#i_CTRL-X_CTRL-T) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 5. 編集中と外部参照しているファイルのキーワードで補完する
----

詳細は [compl-keyword](https://vim-jp.org/vimdoc-ja/insert.html#compl-keyword) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 6. タグで補完する
----

詳細は [compl-tag](https://vim-jp.org/vimdoc-ja/insert.html#compl-tag) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 7. ファイル名で補完する
----

詳細は [compl-filename](https://vim-jp.org/vimdoc-ja/insert.html#compl-filename) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 8. 定義もしくはマクロで補完する
----

詳細は [compl-define](https://vim-jp.org/vimdoc-ja/insert.html#compl-define) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 9. Vimコマンドの補完
----

詳細は [compl-vim](https://vim-jp.org/vimdoc-ja/insert.html#compl-vim) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 10. ユーザー定義補完
----

詳細は [compl-function](https://vim-jp.org/vimdoc-ja/insert.html#compl-function) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 11. オムニ補完
----

詳細は [compl-omni](https://vim-jp.org/vimdoc-ja/insert.html#compl-omni) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 12. スペリング補完
----

詳細は [compl-spelling](https://vim-jp.org/vimdoc-ja/insert.html#compl-spelling) にまとまっています。

(ここにgif)

それぞれの補完を解説 - 13. キーワードを別のソースから補完する
----

詳細は [compl-generic](https://vim-jp.org/vimdoc-ja/insert.html#compl-generic) にまとまっています。

(ここにgif)
