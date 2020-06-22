class LinebotController < ApplicationController
  require 'line/bot' 
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'


  protect_from_forgery :except => [:callback]

  def callback
    # postリクエスト で　callbackにアクセスすると
    # そのリクエストを読み込む。
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event

      when Line::Bot::Event::Message
        case event.type

        when Line::Bot::Event::MessageType::Text
          
          input = event.message['text']
          url  = "https://www.drk7.jp/weather/xml/40.xml"
          # require 'kconv'　でStringクラスに変換用のメソッドが定義される。
          # .toutf8 で　url をutf-8に変換した文字列を返す。
          xml  = open( url ).read.toutf8
          doc = REXML::Document.new(xml)
          xpath = 'weatherforecast/pref/area[2]/'
          
          min_per = 30
          case input
          
          when /.*(明日|あした|あす|翌日|よくじつ).*/
          
            per06to12 = doc.elements[xpath + 'info[2]/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info[2]/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info[2]/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明日の天気やろ？\n明日は雨が降りそうよ(>_<)\n今んところ降水確率はこんな感じ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうやったら教えるね！"
            else
              push =
                "明日の天気？\n明日は雨が降らんみたいよ(^^)\nまた明日の朝の最新の天気予報で雨が降りそうやったら教えるね！"
            end
          when /.*(明後日|あさって|翌々日|よくよくじつ).*/
            per06to12 = doc.elements[xpath + 'info[3]/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info[3]/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info[3]/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明後日の天気やろ？\n何かあると？\n明後日は雨が降りそう…\n当日の朝に雨が降りそうやったら教えるけんね！"
            else
              push =
                "明後日の天気？\n気が早かねー！何があると？\n明後日は雨は降らんみたいよ(^^)\nまた当日の朝の最新の天気予報で雨が降りそうやったら教えるけんね！"
            end
          when /.*(かわいい|可愛い|カワイイ|きれい|綺麗|キレイ|素敵|ステキ|すてき|面白い|おもしろい|ありがと|すごい|スゴイ|スゴい|好き|頑張|がんば|ガンバ).*/
            push =
              "ありがとう！！！\n優しい言葉をかけてくれるあなたは素敵やね(^^)"
          when /.*(こんにちは|こんばんは|初めまして|はじめまして|おはよう).*/
            push =
              "こんにちは。\n声ばかけてくれてありがとう\n今日があなたにとってよか日になりますように(^^)"
          else
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              word =
                ["雨やけど元気出していこうね！",
                 "雨に負けずファイト！！",
                 "雨やけどあなたの明るさでみんなば元気にしてあげて(^^)"].sample
              push =
                "今日の天気？\n今日は雨が降りそうやけん傘があった方がよかよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n#{word}"
            else
              word =
                ["天気もいいけん一駅歩いてみるのはどげん？(^^)",
                 "今日会う人のよかところを見つけてから、その人に教えてあげんね(^^)",
                 "よか一日になりますように(^^)",
                 "雨が降ったらごめんね(><)"].sample
              push =
                "今日の天気？\n今日は雨は降らんそうよ。\n#{word}"
            end
          end
          
        else
          push = "テキスト以外はわからんば〜い(；；)"
        end
        message = {
          type: 'text',
          text: push
        }
        client.reply_message(event['replyToken'], message)
        
      when Line::Bot::Event::Follow
        
        line_id = event['source']['userId']
        User.create(line_id: line_id)
        
      when Line::Bot::Event::Unfollow
        
        line_id = event['source']['userId']
        User.find_by(line_id: line_id).destroy
      end
    }
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
