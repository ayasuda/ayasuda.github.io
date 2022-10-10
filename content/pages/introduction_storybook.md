---
title: 'ぼくのための Storybook 入門'
description: 'UIコンポーネントのライブラリわかりやすくするために Storybook を使ってみようって記事'
keywords:
  - Javascript
  - FrontEnd
  - Storybook
---

Vue.js とかで再利用可能なコンポーネントを作っていると、そのコンポーネント自身の使い方を、可能であればデモ付きで読みたくなることが多々あります。

もちろん、 [Vuetify](https://vuetifyjs.com/ja/) や [Bootstrap](https://getbootstrap.com/) みたいな有名なコンポーネント集にはデモやプロパティについての説明とかがついています。

ああいうコンポーネントライブラリを、社内 or 個人製のコンポーネントにも欲しい！　そんな願いを叶えるのが [Storybook](https://storybook.js.org/) です。

# とりあえずインストールしてみよう


その前に、vue で単一または複数のコンポーネントを担当するプロジェクトのディレクトリ構成に知らねば。

Storybook を動かす前に、 vue.js のプロジェクトが必要です。

まずは、適当なディレクトリを作って、そこにインストールして見ましょう。

```
$ mkdir /path/to/tryStorybook
$ cd /path/to/tryStorybook
$ npx -p @storybook/cli sb init
```
