## line-bot-weather-fukuoka

![Rails](https://img.shields.io/badge/5.2.1-Rails-CC0000.svg?logo=rails&style=plastic)
![Ruby](https://img.shields.io/badge/2.5.1-Ruby-CC342D.svg?logo=ruby&style=plastic)
![Postgresql](https://img.shields.io/badge/-Postgresql-336791.svg?logo=postgresql&style=plastic)
![Heroku](https://img.shields.io/badge/-Heroku-430098.svg?logo=heroku&style=plastic)

## チャンネル名

<strong>雨予報@福岡</strong>

## 概要

この bot は当日から明後日までの期間で福岡市内に雨が降ることを博多弁で教えてくれます。また、毎朝７時になると当日雨が降るかどうかをメッセージで教えてくれます。

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

## 主な機能

### チャット機能

福岡市の雨の予報を当日から明後日までの期間で雨が降りそうかどうかを博多弁で教えてくれます。

キーワードは

- 今日
- 明日、翌日
- 明後日、翌々日

です。

キーワードがメッセージに含まれていれば、該当日の天気を教えてくれます。

### 雨予報通知機能

また、毎朝７時になると当日の降水確率を教えてくれ、傘を持って行くべきかどうかアドバイスしてくれます。

## 今後実装したい事

- 他の地域の予報を伝える
- 降水確率でだけではなく他の情報も伝える
- 英語に対応する

## 変更履歴

- 一通りの機能を実装完了し、デプロイが完了
