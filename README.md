# atday

Heroku Schedulerのサンプル

## 概要

iPhoneの自分が出した自分宛のメールを、忘れた頃に再送するツール。（miwa719が欲しいと言ってたやつ）

iCloudのIMAPメールボックスのINBOXを調べて、n日前、自分から自分へ、Subjectが"atday"のメールを探し、連結して、自分宛に送ります。

## iCloudの準備

iCloudのApp用パスワードを発行してください。

- https://support.apple.com/ja-jp/HT204397

手に入るのは、たぶん12桁のパスワードです。-（ハイフン）は入れちゃダメ。


## ローカル環境

このリポジトリをgit clone。

```
% git clone git@github.com:seki/atday.git
```

環境変数の設定

```
export ICLOUD_USER=メールアドレス
export ICLOUD_APP_PASSWORD=App用パスワード
```


## Herokuの設定

まずはアカウントを作って、アプリも作って、以下を実行。
add-on使うのでクレジットカードの登録もしておいてください。

```
% heroku login
% heroku git:remote -a アプリ名
% git push herouk main
% heroku config:add ICLOUD_USER=メールアドレス
% heroku config:add ICLOUD_APP_PASSWORD=App用パスワード
```

### 実験

自分宛に"atday"というSubjectでメールします。
次に、以下の通り実行します。

```
% heroku run ruby src/atday.rb 0
```

引数の0は0日前（つまり今日）のメールを処理する指示です。
"from 0 days ago"というタイトルのメールが届いたら成功です。

### スケジューラーの設定

あとで

### HerokuのWebだけでやりたい

クレカ登録したくないとのコメントをいただいたので、HTTPSで起動するようにします。
スケジューラーは自分のHerokuアカウントのものを使います。

せっかくなのでTOTP使うことにした！

