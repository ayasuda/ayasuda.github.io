---
title: 'ぼくのかんがえたさいきょーのレールズプロジェクト(2018新春)'
description: ''
keywords:
  - rails
  - docker
---

> ぼく、こういう rails プロジェクトがいいと思うんだ。

この記事では、今、私がかんがえている最高の rails プロジェクトを始める手順について書いて行きます。
異論は認めます。

# やっぱり Docker で動かしたい。そしてセットアップは `./bin/setup` で終わらせたい

もう2018年ですから、やっぱり環境は Docker でやりたいものです。
何しろ、取り回しが楽ですし。

とはいえ、`docker-compose` や `bundle exec` を間違えずに打ち込むのは *面倒* です。

```
$ docker-compose run --rm rails bundle exec rails generate model user name:string
```

こんなコマンド、人類に覚えるのは不可能です。

よって、 [github/scripts-to-rule-them-all](https://github.com/github/scripts-to-rule-them-all) を念頭に入れて
基本的には次のコマンドだけで動くようにします。

* bin/rails で rails コマンドが動く
* 初めて clone した人は bin/setup でサーバが動く
* というか bin/ にある yarn とか node とか、なんでも全部動く

でも、Docker のインストール必須にするのは甘えだよね。

## 最初の一歩

まずは `rails new` したいところです。

と、いうわけでおもむろに次のファイルを書きはじめます

```Dockerfile
FROM ruby:2.4.2
FROM ruby:2.4.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install --jobs 20 --retry 5
COPY . /usr/src/app
EXPOSE 3000
CMD ["rails", "server", "-p", "3000", "-b", "0.0.0.0"]
```

```Gemfile
source 'https://rubygems.org'
gem 'rails', '5.1.4'
```

`touch Gemfile.lock`

この状態で `docker build -t my/rails:latest .` とかやると、 *とりあえず rails がインストールされたイメージとコンテナ* が出来上がります。

```
$ docker build -t my/rails:latest .
...
...
Removing intermediate container a6fd9d733a09
Successfully built 96ae633c683f
Successfully tagged my/rails:latest
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
my/rails            latest              96ae633c683f        28 seconds ago      987MB
```

このイメージを使って Rails プロジェクトを new することで、いい感じになります。

イメージを元にコンテナ上でコマンドを実行するのは `docker run [OPTIONS] IMAGE [COMMAND] [ARGS...]` でした。
今回は、コンテナを使い捨てたいので `--rm` オプションをつけます。
また、今作業中のディレクトリに `rails new` した結果が欲しいので `-v` オプションで現在のディレクトリとコンテナ上の `/usr/src/app` とをバインドします。

```
$ docker run --rm -v "$PWD":/usr/src/app my/rails rails new .
```
