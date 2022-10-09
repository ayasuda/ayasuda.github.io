---
title: 'Go 言語で外部の別プロセスを立ち上げる'
date: '2100-12-31'
description: 'Go 言語で外部の別プロセス、例えばエディタを立ち上げ入力を受け取るなどする時の適切に処理する方法についてサンプルコードともにまとめました'
tags:
  - Go
keywords:
  - Go
  - Process
  - 別プロセス
  - プロセス管理
---

Go のプログラム中で別のプログラムを呼び出すには [exec](https://pkg.go.dev/os/exec) パッケージを用います。
仕組みの基礎については [TODO](/what_is_process) についてまとめてあります。
本文書では、exec パッケージを用いたプロセス制御についてまとめていきたいと思います。


## 外部コマンドを実行し、結果を取得する

Output 使うパターン

dCmd := exec.Command("date")
out, err := dCmd.Output()
fmt.Println(string(out))

## 外部コマンドを実行しする (コマンド実行終了を待つ)
Run 使うパターン

コマンドを実行し、終了を待ちます

## 外部コマンドを実行しする (コマンド実行終了を待)
Start 使うパターン, Wait

コマンドを実行し、終了を待たずに次に行きます

## 標準エラーの内容も取得する
CombinedOutput 使うパターン

## 標準出力と標準エラーを個別に取得する
cmd.StdErr

## 標準入力に入力する
cmd.Stdin

## 環境変数を引き継ぐ
cmd.Env

## パイプ経由での入出力
StdinPipe

## コンテキスト
CommandContext


errors


