---
title: 'zsh history'
draft: true
description: ''
keywords:
  - Java
  - Maven
---

MacOS のデフォルトシェルである zsh では、コマンドの実行履歴が保存され、参照・再実行が可能です。

本文書では zsh の履歴について全般的に記していきます。

履歴全般
====

履歴を読むには `history` コマンドを使います。

例えば、以下のようにコマンドを打った後 `history` と打つことで、履歴が確認できます。

```
$ ls
$ date
$ whoami
$ pwd
$ history
    1  ls
    2  date
    3  whoami
    4  pwd
```

履歴の保存と複数シェルでの挙動
----

コマンドの実行履歴はメモリおよび、*シェル終了時* に、環境変数 `HISTFILE` で指定されたファイルに保存されます。
また、シェル起動時に `HISTFILE` から履歴を読み込みます。

環境変数 `HISTSIZE` でメモリ上に保存される履歴の件数、環境変数 `SAVEHIST` でファイルに保存される履歴の件数を設定可能です。

このあたりの動きを細かく見ていきましょう。

まず、シェルAとシェルBを開いた (例えば、iTerm で複数タブを開いた) とします。

シェルAで以下のコマンドを実行し、履歴を確認します。

```
$ echo "This is shell A"
$ history
    1  echo "This is shell A"
```

この状態で、シェルBで `history` を実行しても、シェルAでの履歴は反映されていません。

```
$ echo "This is shell B"
$ history
    1  echo "This is shell B"
```

それぞれの履歴はメモリ上にのみ記録されているためです。

ここで、おもむろにシェルAを閉じ、新しくシェルC を開いて履歴を確認します。

```
$ echo "This is shell C"
$ history
    1  echo "This is shell A"
    2  echo "This is shell C"
```

*シェルAを閉じたタイミングで履歴がファイルに保存され、シェルCを開いたタイミングで履歴がファイルから読み込まれた*
のがわかるかと思います。

シェル同士で履歴を共有したい場合もあると思います。
環境変数 `SHARE_HISTORY` を有効にすると、シェル同士でメモリ上の履歴が共有されます。
(例えば `.zshrc` に `setopt SHARE_HISTORY` と記述し、有効にします)

一度、全てのシェルを閉じ、その上でもう一度、シェルAとシェルBを開いたとします。

シェルAで以下のコマンドを実行し、履歴を確認します。

```
$ echo "This is shell A"
$ history
    1  echo "This is shell A"
```

この状態で、シェルBで `history` を実行すると、シェルAでの履歴が反映されます。

```
$ echo "This is shell B"
$ history
    1* echo "This is shell A"
    2  echo "This is shell B"
```

自分のシェル以外の履歴にはイベント番号に `*` がつきます。

その他の設定については本文書の後半に記します。

履歴の検索
----

bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward


zsh buitins - fc
====

`man history` するとすぐにわかりますが、 `history` は zsh の組み込みコマンドであり、 `fc -l` の別名です。

本文書では `zsh` での `fc` コマンドについて述べますが、 `fc` 自体は `bash` などにも組み込まれております。

fc コマンド - 概要
----

そんなわけで、まずは `fc` コマンドについて見ていきましょう。
詳細な情報は `man zshbuiltins` で読むことができます。

`fc` コマンドは (おそらく) *F*ix *C*ommand の名前が表す通り、コマンドの実行履歴を編集して実行したり、
一覧で表示したりするコマンドです。

[](https://en.wikipedia.org/wiki/Fc_(Unix))
[](https://unix.stackexchange.com/questions/371390/what-do-the-letters-in-fc-command-stand-for)

最もわかりやすい実行例を見て見ましょう。

まずは事前にコマンドラインで `ls` を実行します。

```
$ mkdir work
$ cd work
$ touch test.txt
$ ls
test.txt
```

次に、`fc` コマンドを実行すると、テキストエディタが立ち上がり、
`ls` が入力された状態になっているはずです。
これを `ls -la` に変更して、エディタを閉じます。
すると、`ls -la` が実行されるのがわかると思います。

```
$ fc
[テキストエディタ上で `ls -la` に変更する]
drwxr-xr-x   4 you  reader    128 12 24 17:22 .
drwxr-xr-x+ 63 you  reader   2016 12 24 04:13 ..
-rw-r--r--   1 you  reader      0 12 24 17:22 test.txt
```

`-l` オプションを付与すると標準出力に履歴を表示します。

例えば、以下のようにコマンドを打った後

```
$ ls
$ date
$ whoami
$ pwd
```

`fc -l` とすることで、以下の出力が得られます。左側の数字はイベント番号です。

```
$ fc -l
   1 ls
   2 date
   3 whoami
   4 pwd
```

それでは、`fc` コマンドの引数およびオプションを見ていきましょう。
それぞれの引数・オプションは `history` にも付与可能です。

操作範囲を指定する引数 `first`, `last`
----

```
fc [ first [ last ] ]
```

`fc` コマンドは数値または文字列の引数を 2 つとります。
この 2 つの数値は `fc` コマンドで取り扱いたい履歴の範囲で、それぞれイベント番号を指定します。

例えば、次のように `1` `3` を指定すると、以下のような結果が得られます。

```
$ fc -l 1001 1003
   1 ls
   2 date
   3 whoami
```

`-l` オプションを指定しない場合は、テキストエディタが立ち上がり、コマンドを編集した後にエディタを閉じることで
全てのコマンドが実行されます。

```
$ fc 1 3
[テキストエディタ上で `ls -la` に変更する]
[ls -la が実行される]
[date が実行される]
[whoami が実行される]
```

数値にマイナスを指定した場合、現在のイベント番号からの差分として認識されます。
ですので、例えば以下のように `-4` を指定した場合は *最新の履歴から4つまで* 表示されることになります。

```
$ fc -l -4
   1 ls
   2 date
   3 whoami
   4 pwd
```

文字列を指定した場合、その文字列から始まるイベントが指定されます。
ですので、例えば、 `fc -l date whoami` とすると、*最後に date を実行した履歴から最後に whoami を実行した履歴* が表示されます。

```
$ fc -l date whoami
   2 date
   3 whoami
```

引数 `first` と `last` はそれぞれ省略可能で、 `-l` オプションの有無でデフォルト値が異なります。
`first` を省略した場合、通常は `-1`、すなわち直前に実行したイベントを表す数値がセットされます。
`first` を指定した上で `last` を省略すると、 `last` のデフォルト値は `first` と同じになります。

`-l` オプションがセットされている場合は `first` のデフォルト値は `-16` が、 `last` には `-1` がセットされます。
よって `history` コマンドおよび `fc -l` を実行した場合は直近の 16 個のイベントが表示されることになります。
また、`first` だけをセットした場合は、*そのイベント番号から直近までの* イベントが表示されます。

パターンの書き換えを行う引数 `old=new`
----

fc コマンドの主な使い道は、履歴から再度実行したいコマンドを選んで編集し、再実行することです。

`old=new` オプションを指定することでいきなりコマンドの書き換えが可能です。

例えば、事前に以下のコマンドを実行していたとしましょう。

```
$ ping example.com
```

例えば `example.com` ではなくて `example.org` への ping を行いたいと思った場合、
`old=new` オプションを指定することで、エディタの起動前に修正ができます。

```
$ fc com=org
[エディタには `ping example.org` が表示されているので、修正せずにそのまま実行できる]
```

履歴の絞り込みオプション `-I`, `-L`, `-m`
----

`fc` または `history` で履歴を表示・操作する際、様々なオプションを付与することで履歴を絞り込むことができます。

それぞれ見ていきましょう。

`-I` オプションを付与すると、そのシェルでのイベントのみを表示します。
FHISTFILE から読み込まれた過去の履歴は *含まれません* 。
また、 SHARE_HISTORY が指定されている時でも、ほかのシェルの履歴は含まれません。


`-L` オプションを付与すると、そのシェルでのローカルイベントのみを表示します。
FHISTFILE から読み込まれた過去の履歴は *含まれます* 。
また、 SHARE_HISTORY が指定されている時でも、ほかのシェルの履歴は含まれません。

`-m match` オプションを付与すると、履歴をパターンで絞り込めます。

事前に以下の履歴が存在するものとします。

```
$ ls
$ date
$ whoami
$ date -R
$ pwd
$ date -u
$ ls -l
$ fc -l
   1 ls
   2 date
   3 whoami
   4 date -R
   5 pwd
   6 date -u
   7 ls -l
$ fc -l 1 7
   1 ls
   2 date
   3 whoami
   4 date -R
   5 pwd
   6 date -u
   7 ls -l
```

例えば、 `date` コマンドのみを絞り込みたい場合は、 `match` に `'date *'` というパターンを指定することで、
絞り込みが可能です。

```
$ fc -l -m 'date *' 1 7
   4 date -R
   6 date -u
```

パターンはシングルクォートで囲む必要があります。


履歴の表示オプション `-r`, `-n`, `-d`, `-f`, `-E`, `-i`, `-t fmt`, `-D`
----

`fc -l` または `hisotry` で履歴を表示する際、様々なオプションを付与することで表示内容を内容を変えることが出来ます。

それぞれ見ていきましょう。

事前に以下の履歴が存在するものとします。

```
$ ls
$ date
$ whoami
$ pwd
$ fc -l
   1 ls
   2 date
   3 whoami
   4 pwd
$ fc -l 1 4
   1 ls
   2 date
   3 whoami
   4 pwd
```

`-r` オプションを付与すると、履歴が逆順に表示されます。

```
$ fc -l -r 1 4
   4 pwd
   3 whoami
   2 date
   1 ls
```

`-n` オプションを付与すると、イベント番号が表示されなくなります。

```
$ fc -l -n 1 4
ls
date
whoami
pwd
```

`-d` オプションを付与すると、イベントごとにタイムスタンプが一緒に表示されます。

```
$ fc -l -d 1 4
   1  01:23  ls
   2  01:23  date
   3  01:23  whoami
   4  01:23  pwd
```

`-f` オプションを付与すると、イベントごとにタイムスタンプがアメリカの 'MM/DD/YY hh:mm' フォーマットで一緒に表示されます。

```
$ fc -l -f 1 4
   1  1/4/2021 01:23  ls
   2  1/4/2021 01:23  date
   3  1/4/2021 01:23  whoami
   4  1/4/2021 01:23  pwd
```

`-E` オプションを付与すると、イベントごとにタイムスタンプが欧州の 'dd.mm.yyyy hh:mm' フォーマットで一緒に表示されます。

```
$ fc -l -E 1 4
   1  4.1.2021 01:23  ls
   2  4.1.2021 01:23  date
   3  4.1.2021 01:23  whoami
   4  4.1.2021 01:23  pwd
```

`-i` オプションを付与すると、イベントごとにタイムスタンプが ISO8601 の 'yyyy-mm-dd hh:mm' フォーマットで一緒に表示されます。

```
$ fc -l -i 1 4
   1  2021-01-04 01:23  ls
   2  2021-01-04 01:23  date
   3  2021-01-04 01:23  whoami
   4  2021-01-04 01:23  pwd
```

`-t fmt` オプションを付与すると、イベントごとにタイムスタンプがフォーマットを指定した上で一緒に表示されます。
指定できるフォーマットは zsh の拡張機能を付与した `strftime` 関数 (概ね [C のやつ](https://linuxjm.osdn.jp/html/LDP_man-pages/man3/strftime.3.html)と同じ)
のものです。詳しい情報は `man zshmisc` で見られるマニュアルの "EXPANSION OF PROMPT SEQUENCES" を見てください。

```
$ fc -l -t "%Y年%m月%d日" 1 4
   1  2020年01月04日  ls
   2  2020年01月04日  date
   3  2020年01月04日  whoami
   4  2020年01月04日  pwd
```

エディタの指定オプション `-e`, および `FCEDIT`, `EDITOR`
----

`-e ename`
FCEDIT
EDITOR
`-e -`


プッシュとポップ `-p`, `-P`
----

履歴ファイルの読み書き `-R`, `-W`, -A`
----

履歴関連の設定
====

zsh の組み込み変数のいくつかは履歴に関する設定です。

詳細な情報は `man zshparam` で読むことができます。

HISTCMD
    The current history event number in an interactive shell, in other words the event number  for
    the  command  that caused $HISTCMD to be read.  If the current history event modifies the his-
    tory, HISTCMD changes to the new maximum history event number.

FCEDIT The default editor for the fc builtin.  If FCEDIT is not set, the parameter EDITOR is used; if
    that is not set either, a builtin default, usually vi, is used.

HISTCHRS

HISTFILE

HISTORY_IGNORE

HISTSIZE

SAVEHIST



履歴関連の設定
====

zsh の組み込み変数のいくつかは履歴に関する設定です。

詳細な情報は `man zshoptions` で読むことができます。

APPEND_HISTORY <D>
    If  this  is set, zsh sessions will append their history list to the history file, rather than
    replace it. Thus, multiple parallel zsh sessions will all have the new entries from their his-
    tory  lists  added  to  the history file, in the order that they exit.  The file will still be
    periodically re-written to trim it when the number of lines grows 20% beyond the value  speci-
    fied by $SAVEHIST (see also the HIST_SAVE_BY_COPY option).

BANG_HIST (+K) <C> <Z>
    Perform textual history expansion, csh-style, treating the character `!' specially.

EXTENDED_HISTORY <C>
    Save each command's beginning timestamp (in seconds since the epoch) and the duration (in sec-
    onds) to the history file.  The format of this prefixed data is:

    `: <beginning time>:<elapsed seconds>;<command>'.

HIST_ALLOW_CLOBBER
    Add `|' to output redirections in the history.  This  allows  history  references  to  clobber
    files even when CLOBBER is unset.

HIST_BEEP <D>
    Beep in ZLE when a widget attempts to access a history entry which isn't there.

HIST_EXPIRE_DUPS_FIRST
    If  the  internal  history  needs  to be trimmed to add the current command line, setting this
    option will cause the oldest history event that has a duplicate to be  lost  before  losing  a
    unique  event from the list.  You should be sure to set the value of HISTSIZE to a larger num-
    ber than SAVEHIST in order to give you some room for the  duplicated  events,  otherwise  this
    option  will  behave  just  like  HIST_IGNORE_ALL_DUPS  once  the history fills up with unique
    events.

HIST_FCNTL_LOCK
    When writing out the history file, by default zsh uses ad-hoc  file  locking  to  avoid  known
    problems with locking on some operating systems.  With this option locking is done by means of
    the system's fcntl call, where this method is available.  On recent operating systems this may
    provide better performance, in particular avoiding history corruption when files are stored on
    NFS.

HIST_FIND_NO_DUPS
    When searching for history entries in the line editor, do not display  duplicates  of  a  line
    previously found, even if the duplicates are not contiguous.

HIST_IGNORE_ALL_DUPS
    If  a new command line being added to the history list duplicates an older one, the older com-
    mand is removed from the list (even if it is not the previous event).

HIST_IGNORE_DUPS (-h)
    Do not enter command lines into the history list if they are duplicates of the previous event.

HIST_IGNORE_SPACE (-g)
    Remove command lines from the history list when the first character on the line is a space, or
    when one of the expanded aliases contains a leading space.  Only normal aliases (not global or
    suffix  aliases)  have  this behaviour.  Note that the command lingers in the internal history
    until the next command is entered before it vanishes, allowing you to briefly  reuse  or  edit
    the  line.   If you want to make it vanish right away without entering another command, type a
    space and press return.

HIST_LEX_WORDS
    By default, shell history that is read in from files is split into words on all  white  space.
    This  means  that  arguments with quoted whitespace are not correctly handled, with the conse-
    quence that references to words in history lines that have been read from a file may be  inac-
    curate.   When this option is set, words read in from a history file are divided up in a simi-
    lar fashion to normal shell command line handling.  Although  this  produces  more  accurately
    delimited  words,  if the size of the history file is large this can be slow.  Trial and error
    is necessary to decide.

HIST_NO_FUNCTIONS
    Remove function definitions from the history list.  Note that  the  function  lingers  in  the
    internal history until the next command is entered before it vanishes, allowing you to briefly
    reuse or edit the definition.

HIST_NO_STORE
    Remove the history (fc -l) command from the history list when invoked.  Note that the  command
    lingers in the internal history until the next command is entered before it vanishes, allowing
    you to briefly reuse or edit the line.

HIST_REDUCE_BLANKS
    Remove superfluous blanks from each command line being added to the history list.

HIST_SAVE_BY_COPY <D>
    When the history file is re-written, we normally write out a copy of  the  file  named  $HIST-
    FILE.new  and  then  rename it over the old one.  However, if this option is unset, we instead
    truncate the old history file and write out the new version in-place.   If  one  of  the  his-
    tory-appending  options  is  enabled, this option only has an effect when the enlarged history
    file needs to be re-written to trim it down to size.  Disable this only if  you  have  special
    needs,  as  doing  so makes it possible to lose history entries if zsh gets interrupted during
    the save.

    When writing out a copy of the history file, zsh preserves  the  old  file's  permissions  and
    group  information,  but  will  refuse  to write out a new file if it would change the history
    file's owner.

HIST_SAVE_NO_DUPS
    When writing out the history file, older commands that duplicate newer ones are omitted.

HIST_VERIFY
    Whenever the user enters a line with history  expansion,  don't  execute  the  line  directly;
    instead, perform history expansion and reload the line into the editing buffer.

INC_APPEND_HISTORY
    This option works like APPEND_HISTORY except that new history lines are added to the $HISTFILE
    incrementally (as soon as they are entered), rather than waiting until the shell  exits.   The
    file  will  still  be  periodically  re-written  to trim it when the number of lines grows 20%
    beyond the value specified by $SAVEHIST (see also the HIST_SAVE_BY_COPY option).

INC_APPEND_HISTORY_TIME
    This option is a variant of INC_APPEND_HISTORY in which, where possible, the history entry  is
    written  out  to the file after the command is finished, so that the time taken by the command
    is recorded correctly in the history file in EXTENDED_HISTORY format.   This  means  that  the
    history  entry  will  not  be available immediately from other instances of the shell that are
    using the same history file.

    This option is only useful if INC_APPEND_HISTORY and SHARE_HISTORY are turned off.  The  three
    options should be considered mutually exclusive.

SHARE_HISTORY <K>

    This  option  both imports new commands from the history file, and also causes your typed com-
    mands to be appended to the history file (the latter is  like  specifying  INC_APPEND_HISTORY,
    which  should  be  turned off if this option is in effect).  The history lines are also output
    with timestamps ala EXTENDED_HISTORY (which makes it easier to find the spot where we left off
    reading the file after it gets re-written).

    By default, history movement commands visit the imported lines as well as the local lines, but
    you can toggle this on and off with the set-local-history zle binding.  It is also possible to
    create  a  zle  widget that will make some commands ignore imported commands, and some include
    them.

    If you find that you want more control over when commands get imported, you may wish  to  turn
    SHARE_HISTORY off, INC_APPEND_HISTORY or INC_APPEND_HISTORY_TIME (see above) on, and then man-
    ually import commands whenever you need them using `fc -RI'.

履歴関連のウィジェット
====

zsh の組み込み変数のいくつかは履歴に関する設定です。

詳細な情報は `man zshzle` で読むことができます。

http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#History-Control

bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward
