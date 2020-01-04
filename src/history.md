---
title: 'history コマンドの使い方'
date: '2119-05-06'
description: 'コマンド実行履歴を閲覧する history と再実行する fc の紹介・解説および bash と zsh での履歴関連設定方法など'
tag:
  - Tips
keywords:
  - Tips
  - Command line
  - history
  - fc
  - zshbuiltins
---

ターミナルで入力したコマンドの実行履歴を見るのには `history` コマンドを使います。
さて、この `history` は、実はシェルの組み込み関数だったりします。`history` というバイナリはありません。
本記事では、忘れっぽい将来の自分のために Bash と zsh 組み込みの `history` の使い方を記していきます。

# histroy の公式なマニュアルへのアクセス方法

やはり、何と言っても公式なドキュメントを読むのが一番でしょう。とは言え、 `man history` とやっても何も出てきません。
なぜなら `history` はシェルの組み込みコマンドだからです。

zsh なら zshbuilins に `history` の記載があります。

```
$ man zshbuiltins
ZSHBUILTINS(1)                                                                            ZSHBUILTINS(1)

(中略)

       history
                     Same as fc -l.

(後略)
```

Bash なら `man bash` の `SHELL BUILTIN COMMAND` に `history` の記載があります。

```
$ man bash
BASH(1)                                                                            BASH(1)

(中略)

SHELL BUILTIN COMMANDS

(中略)

history [n]
history -c
history -d offset
history -anrw [filename]
history -p arg [arg ...]
history -s arg [arg ...]
  With no options, display the command history list with line numbers.  Lines listed with a * have been modified.  An argument of n lists only the last n lines.  If the shell variable HISTTIMEFORMAT is set and not null, it  is  used
  as  a  format  string  for strftime(3) to display the time stamp associated with each displayed history entry.  No intervening blank is printed between the formatted time stamp and the history line.  If filename is supplied, it is
  used as the name of the history file; if not, the value of HISTFILE is used.  Options, if supplied, have the following meanings:
  -c     Clear the history list by deleting all the entries.
  -d offset
         STDelete the history entry at position offset.
  -a     Append the ``new'' history lines (history lines entered since the beginning of the current bash session) to the history file.
  -n     Read the history lines not already read from the history file into the current history list.  These are lines appended to the history file since the beginning of the current bash session.
  -r     Read the contents of the history file and use them as the current history.
  -w     Write the current history to the history file, overwriting the history file's contents.
  -p     Perform history substitution on the following args and display the result on the standard output.  Does not store the results in the history list.  Each arg must be quoted to disable normal history expansion.
  -s     Store the args in the history list as a single entry.  The last command in the history list is removed before the args are added.

  If the HISTTIMEFORMAT is set, the time stamp information associated with each history entry is written to the history file.  The return value is 0 unless an invalid option is encountered, an error occurs while reading  or  writing
  the history file, an invalid offset is supplied as an argument to -d, or the history expansion supplied as an argument to -p fails.

(後略)
```

Web で情読みたい場合は [https://linux.die.net/man/1/zshbuiltins](https://linux.die.net/man/1/zshbuiltins),  [https://linuxjm.osdn.jp/html/GNU_bash/man1/bash.1.html](https://linuxjm.osdn.jp/html/GNU_bash/man1/bash.1.html) あたりにあります。

# bash でのコマンドの実行履歴

bash ではコマンドの実行履歴が記録され、 `history` コマンドで閲覧が、 `fc` コマンドで (編集して) 再実行ができます。

```
$ date # date コマンドを実行した履歴が記録される
$ histroy # 履歴は history コマンドで見られる
  1 date
```

履歴は bash 起動時にファイルから読み込まれ、bash 終了時にファイルに書き出されます。
これにより、例えば複数のタブやウィンドウでログインしていた場合でも履歴が混同されません。

例えば macOS のターミナル.app を開き二つのタブを用意します。その上で、タブ１で以下を入力します。

```
$ echo "this is window 1"
$ history
  1 echo "this is window 1"
```

さらに、タブ２で以下を入力し、 `history` を打っても、タブ１の履歴は表示されません。

```
$ echo "this is window 2"
$ history
  1 echo "this is window 2"
```

この状態でタブ１を終了すると、実行履歴がファイルに書き込まれます。
タブ１を終了した後、新しくタブ３を作成すると、今度は実行履歴がファイルから読み込まれます。
ですので、タブ３で `history` を実行すると、以下のようになります。

```
$ history
  1 echo "this is window 1"
```

// TODO: ここに動画または gif

ここまでをまとめると以下の通りになります。

1. bash はコマンドの実行履歴をキャッシュに記録します
2. `history` コマンドでキャッシュされた実行履歴を見ることができます
3. bash は終了時にキャッシュされた実行履歴をファイルに書き出します
4. bash は起動時にファイルから実行履歴をキャッシュに読み込みます

# bash でのコマンド実行履歴展開

bash ではコマンドの実行
// TODO:

# bash での `history` の使い方

`history` コマンドはコマンドの実行履歴を行番号とともに出力します。

```
$ history
  1 whoami
  2 pwd
  3 date
```

オプションとして数値 (例えば `n`) を与えた場合、最後から `n` 行の履歴が表示されます。

```
$ history 10
  509  history -l
  510  ls
  511  date
  512  date
  513  date
  514  date -c
  515  date -j
  516  date -c
  517  history
  518  history 10
```

`-c` オプションで過去の履歴を削除することができます。

```
$ history
  487 tmux
  (中略)
  520 history
$ history -c
$ history
  22 history
```

`-d offset` オプションで指定した番号の履歴を削除することができます。

```
$ history
  1  whoami
  2  echo "Hello"
  3  date
  4  ls
  5  top
  6  pwd
  7  history
$ history -d 3
$ history
  1  whoami
  2  echo "Hello"
  3  ls
  4  top
  5  pwd
  6  history
  7  history -d 3
  8  history
```

`-anrw filename` は履歴をファイルに書き出したり、読み込んだりするオプションです。

`-w filename` で履歴をファイルに書き出すことができます。

```
$ history -w ~/tmp/histfile
$ cat ~/tmp/histfile
pwd
date
history -w ~/tmp/histfile
```

// TODO: -a, -r, -n

// TODO: -p -s

//fc コマンドなどで変更した場合、行番号に `*` が付きます。
// HISTTIMEFORMAT

`filename` が与えられた場合、そのファイルから履歴が取得されます。未指定の場合は HISTFILE で定義された値が使用されます。
`anrw`

# bash での `fc` の使い方

# bash のコマンドの実行履歴に関する設定用変数

bash ではコマンドの実行履歴を取り扱うためのいくつかの設定用変数が用意されています。
それぞれ `echo $NAME` で参照できます。

```
$ echo $HISTFILE
/path/to/histfile
```

HISTCONTROL
HISTFILE
HISTFILESIZE
HISTIGNORE
HISTSIZE
HISTTIMEFORMAT
histchars



# zsh での `history` の使い方

上記に抜粋した通り、 zsh では `history` は `fc -l` と等価です。

`fc` コマンド


