---
title: 'Go 言語でのシグナル処理'
date: '2021-10-28'
description: ''
keywords:
  - Signal
  - Daemon
---

## Go

```golang
package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	ticker := time.NewTicker(1 * time.Second)

	done := make(chan bool, 1)
	sigs := make(chan os.Signal, 1)

	signal.Notify(sigs, syscall.SIGINT)

	cnt := 0

	go func() {
		for {
			_ = <-ticker.C
			cnt += 1
			fmt.Println(cnt)
		}
	}()

	go func() {
		<-sigs
		fmt.Println("bye")
		ticker.Stop()
		done <- true
	}()

	<-done
}
```
