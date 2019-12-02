---
title: 'Making クレジットカードフォーム (フロントエンドのコーディング課題６選)'
date: '2100-12-31'
description: ''
keywords:
  - Java
  - Maven
---

[フロントエンドのコーディング課題６選-このフロントエンドの課題、実装できますか？ - Qiita](https://qiita.com/baby-degu/items/d68e52a0727248ba2750)
( 原文: [Here Are 6 Front-End Challenges to Code - Better Programming - Medium](https://medium.com/better-programming/here-are-6-frontend-challenges-to-code-9952190c97cc)
がはてなブックマークで話題になっていました。

> 優れたフロントエンド開発者になるために効果的な方法の１つは、単純にできるだけ多くの課題に取り組み、解決することです。

とのことですので、１流に憧れる２流エンジニアの私としては早速やってみるしかありません。

と、いうわけで、早速作って行きましょう。

なお、原文では参考例として理想的なクレジットカードフォームの例が提示されています。

[https://github.com/muhammederdem/vue-interactive-paycard](https://github.com/muhammederdem/vue-interactive-paycard)

実際に使う際にはこちらの使用をお勧めします。

下準備、の下準備 (別記事にするかも)
====

1. 外部に公開するためのコンポーネントの骨組みを用意する
2. 使い方をわかりやすくみるためのカタログページを用意する。

これから再利用可能な vue コンポーネントを作って行きたいので、


下準備
====

$ git init
$ git commit --allow-empty -m 'Initialize repository'


見出し１
====

