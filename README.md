## line-bot-weather-fukuoka

![Rails](https://img.shields.io/badge/5.2.1-Rails-CC0000.svg?logo=rails&style=plastic)
![Ruby](https://img.shields.io/badge/2.5.1-Ruby-CC342D.svg?logo=ruby&style=plastic)
![Postgresql](https://img.shields.io/badge/-Postgresql-336791.svg?logo=postgresql&style=plastic)
![Heroku](https://img.shields.io/badge/-Heroku-430098.svg?logo=heroku&style=plastic)

## チャンネル名

<strong>雨予報@福岡</strong>

## 概要

この bot は当日から明後日までの期間で福岡市内に雨が降ることを博多弁で教えてくれます。また、毎朝７時になると当日雨が降るかどうかをメッセージで教えてくれます。

![gif](https://user-images.githubusercontent.com/61185362/84508826-db0d3280-acfd-11ea-88d4-1c203044bf6c.gif)

## 作成期間

- 2020/06/01 LINE BOT/Messaging API の学習開始
- 2020/06/08 本リポジトリ作成
- 2020/06/09 各種機能実装完了後、デプロイ
- バージョンアップを継続

## 仕様

- mac OS Catalina 10.15.5
- ruby 2.5.1
- rails 5.2.1
- Messaging API
- postgresql
- Heroku

## 使用の手順

こちらの QR コードをスキャンして友達に追加をして下さい。

<img src= "https://user-images.githubusercontent.com/61185362/84488495-3c6fda00-acdb-11ea-8a6e-fd8c0ac4f246.png" width= 300px >

もしくは、Line で[ホーム] > [友だち追加] > [検索]から <strong>ID : @731rxlze</strong> を友だちに追加して下さい。

## 主な機能

### チャット機能

福岡市の雨の予報を当日から明後日までの期間で雨が降りそうかどうかを博多弁で教えてくれます。

キーワードは

- 今日
- 明日、翌日
- 明後日、翌々日

です。

キーワードがメッセージに含まれていれば、該当日の天気を教えてくれます。

また、東京、名古屋、大阪の当日の天気を教えてくれる機能を追加実装しました。

チャットで「使い方」とキーワードを入れれば、詳しく聞くことができます。

### 雨予報通知機能

毎朝７時になると福岡市内の当日の降水確率を教えてくれ、傘を持って行くべきかどうかアドバイスしてくれます。
　また、東京、名古屋、大阪の当日の天気を教えてくれます。

### ※注意点

「雨予報通知機能」は Heroku のアドオン、Heroku Scheduler を使用している都合上、通知が届かなかったり、2 度同じメッセージが届いてしまう場合があります。その場合は、一度チャンネルをブロックして頂き、再度解除して友達に追加してください。

## 今後実装したい事

- 現在実装している地域以外（全国の主要都市）の予報通知機能を実装。(7月下旬頃まで)
- 現在実装している地域以外（全国の主要都市）の予報チャット機能を実装。(８月下旬頃まで)
- 英語に対応する（夏頃予定）

現在は、地域も情報も限られたものしか送れないので、今後は伝えられる情報を少しずつ増やし実装していきます。

## 変更履歴

- チャットで使い方を聞けるよう追加実装。(20/07/07)
- チャットで東京、大阪、名古屋の当日の天気通知機能を追加実装。(20/07/02)
- 毎朝の通知で東京、名古屋、大阪の予報機能を追加実装。(20/06/25)
- 一通りの機能を実装完了し、デプロイが完了
