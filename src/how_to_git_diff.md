---
title: 'Blog template'
date: '2100-12-31'
description: ''
keywords:
- Java
- Maven
---

Git 2.31.0 をベースに解説

ここでは `git help diff` したときに出てくる Man ページのうち、概要部分で紹介される git-diff の基本的な形式についてまとめていきます。

そのまま訳すと著作権的に NG (GPL2 だからこのブログ自体が GPL2 になりそう) になるので、引用・意訳しつつ、実例や解説等をそれぞれ付与していきたいと思います。

## 凡例

https://zenn.dev/yoichi/articles/git-dotted-notations


--
git diff

git diff [<options>] [--] [<path>...]
This form is to view the changes you made relative to the index (staging area for the next commit). In other words, the differences are what you could tell Git to further add to the index but you still haven't. You can stage these changes by using git-add(1).

このフォームは、インデックス（次のコミットのステージング領域）に関連して行った変更を表示するためのものです。言い換えれば、違いは、Gitにさらにインデックスに追加するように指示できるものですが、まだ追加していません。 git-add（1）を使用して、これらの変更をステージングできます。

## git diff インデックスとの差分を表示する

```
git diff [<options>] [--] [<path>...]
```

最も基礎的な `git diff` はワーキングツリーとステージング領域との差分を表示します。

--

git diff [<options>] --no-index [--] <path> <path>
This form is to compare the given two paths on the filesystem. You can omit the --no-index option when running the command in a working tree controlled by Git and at least one of the paths points outside the working tree, or when running the command outside a working tree controlled by Git. This form implies --exit-code.
この形式は、ファイルシステム上の指定された2つのパスを比較するためのものです。 Gitによって制御されている作業ツリーでコマンドを実行し、パスの少なくとも1つが作業ツリーの外側を指している場合、またはGitによって制御されている作業ツリーの外側でコマンドを実行している場合は、-no-indexオプションを省略できます。この形式は--exit-codeを意味します。



--
git diff [<options>] --cached [--merge-base] [<commit>] [--] [<path>...]
This form is to view the changes you staged for the next commit relative to the named <commit>. Typically you would want comparison with the latest commit, so if you do not give <commit>, it defaults to HEAD. If HEAD does not exist (e.g.  unborn branches) and <commit> is not given, it shows all staged changes. --staged is a synonym of --cached.

If --merge-base is given, instead of using <commit>, use the merge base of <commit> and HEAD.  git diff --merge-base A is equivalent to git diff $(git merge-base A HEAD).

このフォームは、指定された<commit>に関連する次のコミットのためにステージングした変更を表示するためのものです。通常、最新のコミットとの比較が必要になるため、<commit>を指定しない場合、デフォルトでHEADになります。 HEADが存在せず（たとえば、生まれていないブランチ）、<commit>が指定されていない場合は、すべての段階的な変更が表示されます。 --stagedは--cachedの同義語です。

--merge-baseが指定されている場合は、<commit>を使用する代わりに、<commit>とHEADのマージベースを使用します。 git diff --merge-base Aは、git diff $（git merge-base A HEAD）と同等です。

--
git diff [<options>] <commit> [--] [<path>...]
This form is to view the changes you have in your working tree relative to the named <commit>. You can use HEAD to compare it with the latest commit, or a branch name to compare with the tip of a different branch.

このフォームは、指定された<commit>に関連する作業ツリーでの変更を表示するためのものです。 HEADを使用して最新のコミットと比較したり、ブランチ名を使用して別のブランチの先端と比較したりできます。


--
git diff [<options>] [--merge-base] <commit> <commit> [--] [<path>...]
This is to view the changes between two arbitrary <commit>.

If --merge-base is given, use the merge base of the two commits for the "before" side.  git diff --merge-base A B is equivalent to git diff $(git merge-base A B) B.

これは、2つの任意の<commit>間の変更を表示するためのものです。

--merge-baseが指定されている場合は、「前」側に2つのコミットのマージベースを使用します。 git diff --merge-baseABはgitdiff$（git merge-base A B）Bと同等です。

--
git diff [<options>] <commit> <commit>... <commit> [--] [<path>...]
This form is to view the results of a merge commit. The first listed <commit> must be the merge itself; the remaining two or more commits should be its parents. A convenient way to produce the desired set of revisions is to use the ^@ suffix.  For instance, if master names a merge commit, git diff master master^@ gives the same combined diff as git show master.

このフォームは、マージコミットの結果を表示するためのものです。最初にリストされている<commit>は、マージ自体である必要があります。残りの2つ以上のコミットはその親である必要があります。必要なリビジョンのセットを作成する便利な方法は、^@サフィックスを使用することです。たとえば、マスターがマージコミットに名前を付ける場合、git diff master master^@はgitshowmasterと同じ結合されたdiffを提供します。

--
git diff [<options>] <commit>..<commit> [--] [<path>...]
This is synonymous to the earlier form (without the ..) for viewing the changes between two arbitrary <commit>. If <commit> on one side is omitted, it will have the same effect as using HEAD instead.

これは、2つの任意の<commit>間の変更を表示するための以前の形式（..なし）と同義です。片側の<commit>を省略すると、代わりにHEADを使用した場合と同じ効果があります。

--
git diff [<options>] <commit>...<commit> [--] [<path>...]
This form is to view the changes on the branch containing and up to the second <commit>, starting at a common ancestor of both <commit>.  git diff A...B is equivalent to git diff $(git merge-base A B) B. You can omit any one of <commit>, which has the same effect as using HEAD instead.

Just in case you are doing something exotic, it should be noted that all of the <commit> in the above description, except in the --merge-base case and in the last two forms that use .. notations, can be any <tree>.

For a more complete list of ways to spell <commit>, see "SPECIFYING REVISIONS" section in gitrevisions(7). However, "diff" is about comparing two endpoints, not ranges, and the range notations (<commit>..<commit> and <commit>...<commit>) do not mean a range as defined in the "SPECIFYING RANGES" section in gitrevisions(7).


このフォームは、両方の<commit>の共通の祖先から開始して、2番目の<commit>を含むブランチの変更を表示するためのものです。 git diff A...Bはgitdiff$（git merge-base A B）Bと同等です。<commit>のいずれかを省略できます。これは、代わりにHEADを使用する場合と同じ効果があります。

エキゾチックなことをしている場合に備えて、上記の説明のすべての<commit>は、-merge-baseの場合と、..表記を使用する最後の2つの形式を除いて、任意の<である可能性があることに注意してください。ツリー>。

<commit>のスペルのより完全なリストについては、gitrevisions（7）の「SPECIFYINGREVISIONS」セクションを参照してください。ただし、「diff」は範囲ではなく2つのエンドポイントを比較することであり、範囲表記（<commit>..<commit>および<commit>...<commit>）は、「SPECIFYING」で定義されている範囲を意味するものではありません。 gitrevisions（7）の「RANGES」セクション。

--
git diff [<options>] <blob> <blob>
This form is to view the differences between the raw contents of two blob objects.

