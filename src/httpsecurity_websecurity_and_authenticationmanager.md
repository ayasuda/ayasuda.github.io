---
title: '１ファイルくらいのスクリプト向け bundler'
---
Spring Security の HttpSecurity と WebSecurity って何が違うんだってばよ？（そして AuthenticationManagerBuilder とは一体）
=====

Spring フレームワークで認証・認可といえば、真っ先に思い浮かぶのが
[Spring Security](https://projects.spring.io/spring-security/)
だと思う。
使い方は非常に簡単で、ライブラリを Maven なり Gradle なりで依存関係に突っ込んだら
次は設定ファイルまたは設定クラスを適切に作り、
最後にサーブレットフィルタに Spring Security が提供しているフィルタ、 `FilterChainProxy` を登録しておしまい。
Spring Boot を使っているなら最後のサーブレットフィルタの部分が入らないので、２ステップで認証・認可をかけられるわけだ。

設定クラスもシンプルで、例えば Spring Boot で Spring Security を使うガイドである
[Hello Spring Security with Boot](https://docs.spring.io/spring-security/site/docs/4.2.3.RELEASE/guides/html5/helloworld-boot.html)
なんかにはこんな感じの設定クラスが書かれている。

```java
package org.springframework.security.samples.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

  @Override
    protected void configure(HttpSecurity http) throws Exception {
      http
        .authorizeRequests()
        .antMatchers("/css/**", "/index").permitAll()
        .antMatchers("/user/**").hasRole("USER")
        .and()
        .formLogin()
        .loginPage("/login").failureUrl("/login-error");
    }

  @Autowired
    public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
      auth
        .inMemoryAuthentication()
        .withUser("user").password("password").roles("USER");
    }
}
```

で、資料によっては他のオーバライドもあるわけだけど・・・正直、違いがよく分からない。
具体的には、 [WebSecurityConfigurerAdapter](https://docs.spring.io/spring-security/site/docs/4.1.2.RELEASE/apidocs/org/springframework/security/config/annotation/web/configuration/WebSecurityConfigurerAdapter.html)
には

1. `protected void configure(AuthenticationManagerBuilder auth)`
2. `protected void configure(HttpSecurity http)`
3. `void configure(WebSecurity web)`

の3つが用意されている。で、それぞれの違いは何かって話だ。

WebSecurity と HttpSecurity
----

まずは名前が似ている
[WebSecurity](https://docs.spring.io/spring-security/site/docs/4.1.2.RELEASE/apidocs/org/springframework/security/config/annotation/web/builders/WebSecurity.html)
と
[HttpSecurity](https://docs.spring.io/spring-security/site/docs/4.1.2.RELEASE/apidocs/org/springframework/security/config/annotation/web/builders/HttpSecurity.html)
から。

WebSecurity は主に SecurityFilterChain 向けの設定をかく

AuthenticationManagerBuilder
-----

名前からしてわかりやすいかもしれないけれど、
[AuthenticationManagerBuilder](https://docs.spring.io/spring-security/site/docs/4.1.2.RELEASE/apidocs/org/springframework/security/config/annotation/authentication/builders/AuthenticationManagerBuilder.html)
は認証メカニズムを簡単に追加するためのやつで、どうやって認証をかけるかを設定できる。
よく見るのはこんな書き方。

```java
public void configure(AuthenticationManagerBuilder auth) {
  auth.inMemoryAuthentication().withUser("bob").password("bob_pass").roles("USER");
}
```

これは、`auth.inMemoryAuthentication()` を呼び出してインメモリなユーザで認証する
[InMemoryUserDetailsManagerConfigurer<B extends ProviderManagerBuilder<B>>](https://docs.spring.io/spring-security/site/docs/4.1.2.RELEASE/apidocs/index.html?org/springframework/security/config/annotation/web/configuration/WebSecurityConfigurerAdapter.html)
を作成し、適宜設定を与えている。

これで納得できたらいいのだけど、きっと普通の人は、「インメモリなユーザ？　他にどういう方法で認証設定できるの？　もしくは独自の認証方法どうやって作るの？」みたいな疑問にかられることだろう。



