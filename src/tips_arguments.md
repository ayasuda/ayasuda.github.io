---
title: 'プログラムの引数に関する考え方 (コマンドライン引数・環境変数・設定ファイルの優先順位)'
date: '2100-12-31'
description: ''
keywords:
  - Java
  - Maven
---

https://stackoverflow.com/questions/7443366/argument-passing-strategy-environment-variables-vs-command-line
https://www.reddit.com/r/kubernetes/comments/cto92c/starting_fights_env_variables_vs_command_line_args/

優先順位としては、多分

実行時に制御可能なものが優先されるはずなので、
ENV よりも command line arg の方が優先されるはず。

書き出し

見出し１
====

