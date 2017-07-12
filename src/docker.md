Docker ことはじめ
====

コンテナだよ！

[Docker](https://www.docker.com/)

コンテナとは何か？
----

コンテナとは、軽量のアプリケーション実行環境です。
もっとも簡単な例で説明しましょう。
Docker をインストール済みの環境で下記のコマンドを実行します。

```
$ docker run hello-world
```

このコマンドを実行すると、

* (hello-world イメージがないなら) イメージをダウンロード
* コンテナにイメージを読み込んで実行

が行われます。
このイメージは標準出力にメッセージを表示しておしまいですので、イメージの実行が終わったらコンテナは破棄されます。

これのどこが嬉しいのかと言うと・・・・
「実行環境がイメージに閉じている点」です。
例えばとある rails アプリケーションを実行する `foo/bar` というイメージがあるとして、
必要なバージョンの ruby や、mysql などはイメージの中に一通りインストール済みのまま
持ち運びが可能です！

どれくらい強力なのかを試すために、例えば Redmine を動かしてみましょう。

```
$ docker run -p 3001:3000 redmine
```

このコマンドを実行すると公式の Redmine イメージがダウンロードされて、コンテナに載せて実行されます。
`-p 3001:3000` を指定することで、コンテナ内の 3000 番ポートとホストの 3001 番ポートとをマッピングしています。
コンテナが実行されたら、`http://localhost:3001` にアクセスしてみましょう。
コンテナに載っているイメージ内に Redmine を実行可能なすべての環境が整っているため、Redmine のトップページが開いたはずです！

このように、`redmine` というアプリケーションを実行する環境を実行する軽量な環境がコンテナです。

コンテナは他のコンテナやホストと環境が隔離されています。
試しにホストの ruby と redmine イメージの ruby のバージョンを比べてみましょう。

```
$ ruby --version
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin15]
$ docker run redmine ruby --version
ruby 2.2.7p470 (2017-03-28 revision 58194) [x86_64-linux]
```

このように、環境がイメージが載っている環境ごとに違うのがわかるかと思います。

最後に、 docker run コマンドの凡例だけ記しておきましょう。

```
$ docker run [OPTIONS] IMAGE [COMMAND] [ARGS...]
```

OPTIONS は `docker run` に渡すオプションです。
先ほど、 redmine イメージを載せたコンテナを起動した際に `-p, --publish` オプションを
使い、ホストマシンとコンテナとのポートをマッピングしました。
他にも、ホストマシンの指定ディレクトリとコンテナ内の指定ディレクトリとを紐付ける `-v, --volume` オプションや
コンテナの起動をバックグラウンドで行う `-d, --detach` オプションなどがあります。

IMAGE はコンテナに載せて起動する docker イメージです。イメージについては次の項でもう少し詳しく説明します。

COMMAND [ARGS...] はイメージを載せたコンテナ上で実行したいコマンドです。
先ほどは `ruby --version` を指定したので、コンテナ上で `ruby --version` が実行されました。
docker イメージにはコンテナ実行時にデフォルトで実行するコマンドが用意されているものも多くあり、
`redmine` イメージもその一つなので、特にコマンドを指定しない場合はコンテナ内部で `rails server` が実行されていました。
デフォルトのコマンドが用意されているイメージでは、 COMMAND [ARGS...] を指定することで
コンテナ上ではデフォルトのコマンドではなく、指定したコマンドが実行されます。
デフォルトのコマンドが用意されていないイメージでは、 COMMAND [ARGS...] を指定しないとすぐにコンテナが終了します。

イメージとは何か？
----

イメージとはコンテナの元です。

イメージについて理解を深めるために、
世界中の人々が作成したイメージが集まる [Docker Hub](https://hub.docker.com/) へアクセスし、
[docker/whalesay](https://hub.docker.com/r/docker/whalesay/) へ移動します。

How to use にも書かれている通り、このイメージの使い方を早速試してみましょう。

```
$ docker run docker/whalesay cowsay boo
```

このコマンドを実行することで、イメージがダウンロードされ、このイメージを載せたコンテナが起動し、
コンテナ上で `cowsay boo` が実行され、コンテナが終了しました。

ダウンロードをしたので、手元にあるイメージが増えたはずです。確認してみましょう。

```
$ docker images
REPOSITORY      TAG    IMAGE ID     CREATED     SIZE
hello-world     latest 1815c82652c0 3 weeks ago 1.84kB
docker/whalesay latest 6b362a9f73eb 2 years ago 247MB
```

なお、いちいちコンテナを起動しなくても、 `docker pull` コマンドを使えばイメージのダウンロードのみを行うことも可能です。

```
$ docker pull docker/whalesay
```

さて、手元にあるイメージには、自分で変更を加えることができます。
例えば、`docker/whalesay` で ruby が使えるようにしましょう。
下記の通り、このイメージには ruby がインストールされていません。

```
$ docker run docker/whalesay ruby --version
```

イメージを変更するために変更したいイメージを載せた、シェルを実行するコンテナを立ち上げましょう。
`docker run` コマンドのオプションとして、
標準入力をコンテナに割り当てる `-i` オプションと tty を割り当てる `-t` オプションを付与して
コンテナ上でシェルを実行します。

```
$ docker run -t -i docker/whalesay /bin/bash
root@5c4b292514e8:/cowsay#
```

シェルが動き始めたら、 ruby をインストールしてみます。インストールが完了したら exit でシェル、コンテナを終了します。

```
$ docker run -t -i docker/whalesay /bin/bash
root@5c4b292514e8:/cowsay# apt install ruby
root@5c4b292514e8:/cowsay# ruby --version
ruby 1.9.3p484 (2013-11-22 revision 43786) [x86_64-linux]
root@5c4b292514e8:/cowsay# exit
```

これで、元のイメージとは環境の変更されたコンテナができました。このコンテナを元に新しくイメージを名前をつけて記録します。
使うコマンドは `docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]` です。

```
$ docker commit -m 'add ruby' -a 'Atsushi Yasuda' 5c4b292514e8 ayasuda/whalesay:v2
sha256:d37dbfc2a79a35696b2ac870ca7ff3e3f67b92c6b7efd2d4701cfe948fc98a20
```

上記のコマンドのように、環境の変更されたコンテナの id を指定して、 ayasuda/whalesay:v2 という名前でコミットしています。
コミットすることで、次のコンテナを立ち上げる時に使用出来るイメージの一覧に ayasuda/whalesay:v2 が増えています。
確認してみましょう。イメージの一覧を見るコマンドは `docker images` です。

```
$ docker images
REPOSITORY        TAG    IMAGE ID     CREATED     SIZE
hello-world       latest 1815c82652c0 3 weeks ago    1.84kB
docker/whalesay   latest 6b362a9f73eb 2 years ago    247MB
ayasuda/whalesay  v2     d37dbfc2a79a 26 seconds ago 260MB
```

もちろん、今作ったイメージを載せた新しいコンテナを立ち上げることもできます。

```
$ docker run ayasuda/whalesay:v2 ruby --version
ruby 1.9.3p484 (2013-11-22 revision 43786) [x86_64-linux]
```

新しいイメージは docker hub などにあげることで、他のホストでも利用することができるようになります。
こうすることで **他のホストでも同じ環境でアプリケーションを実行する** ことができるようになります。

Dockerfile
-----

`docker commit` コマンドを使うこと新しいイメージを作ることができるのはお分かりいただけたかと思います。
しかし、この方法には幾つかのデメリットがあります。

1. 操作が煩わしい。ミスをした時などに気軽に修正しづらい。
2. 公開されているイメージが、具体的にどのように作られたのかの検証性に欠ける

これらを解決するために、 `Dockerfile` というテキストファイルを元にしてイメージを構築する方法が用意されています。

```:Dockerfile
FROM docker/whalesay:latest
CMD date | cowsay
```

Dockerfile はイメージを作るための命令を記述していきます。
詳細は割愛しますが、上記で使われている `FROM` と `CMD` について書いておきましょう。

`FROM` はイメージを新しく作るための基となるイメージを指定する命令です。
また、 `CMD` はイメージを載せたコンテナを動かす時のデフォルトのコマンドを指定する命令です。
つまり、上記の Dockerfile では `docker/whalesay:latest` をベースとして、
デフォルトで `date | cowsay` を実行するイメージが作成できます。

さて、早速イメージを作ってみましょう。Dockerfile を基にしたイメージの作成には
`docker build [OPTIONS] PATH | URL | -` コマンドを使います。
今回は `-t` オプションを使ってイメージに名前をつけつつイメージを作成します。

```
$ docker -t ayasuda/date .
(略)
Successfully built 77e9e0e77fd4
Successfully tagged ayasuda/date:latest
```

作成されたイメージを確認するために、 `docker images` でイメージができたことを確認しつつ、
`docker run` でイメージを載せたコンテナを起動してみましょう。

```
$ docker images
REPOSITORY        TAG    IMAGE ID     CREATED     SIZE
hello-world       latest 1815c82652c0 3 weeks ago    1.84kB
docker/whalesay   latest 6b362a9f73eb 2 years ago    247MB
ayasuda/whalesay  v2     d37dbfc2a79a 26 seconds ago 260MB
ayasuda/date      latest 77e9e0e77fd4 26 seconds ago 247MB
$ docker run ayasuda/date
 ______________________________
 < Wed Jul 12 03:44:02 UTC 2017 >
  ------------------------------
  \
   \
    \
                   ##        .
             ## ## ##       ==
          ## ## ## ##      ===
     /""""""""""""""""___/ ===
~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
     \______ o          __/
      \    \        __/
        \____\______/
```

以上のように、Dockerfile を使うことで簡単に取り扱い可能なイメージを作成し、配布することが可能になります。

見知らぬOSSとDockerfile
----


