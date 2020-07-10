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
          url_fukuoka  = "https://www.drk7.jp/weather/xml/40.xml"
          url_tokyo = "https://www.drk7.jp/weather/xml/13.xml"
          url_nagoya = "https://www.drk7.jp/weather/xml/23.xml"
          url_osaka = "https://www.drk7.jp/weather/xml/27.xml"
          
          # require 'kconv'　でStringクラスに変換用のメソッドが定義される。
          # .toutf8 で　url をutf-8に変換した文字列を返す。
          xml_f  = open( url_fukuoka ).read.toutf8
          xml_t  = open( url_tokyo ).read.toutf8
          xml_n  = open( url_nagoya ).read.toutf8
          xml_o  = open( url_osaka ).read.toutf8
          doc_f = REXML::Document.new(xml_f)
          doc_t = REXML::Document.new(xml_t)
          doc_n = REXML::Document.new(xml_n)
          doc_o = REXML::Document.new(xml_o)
          xpath_f = 'weatherforecast/pref/area[2]/'
          xpath_t = 'weatherforecast/pref/area[4]/'
          xpath_n = 'weatherforecast/pref/area[2]/'
          xpath_o = 'weatherforecast/pref/area[1]/'

          min_per = 30
          case input
          
          when /.*(明日|あした|あす|翌日|よくじつ).*/
            per06to12 = doc_f.elements[xpath_f + 'info[2]/rainfallchance/period[2]'].text
            per12to18 = doc_f.elements[xpath_f + 'info[2]/rainfallchance/period[3]'].text
            per18to24 = doc_f.elements[xpath_f + 'info[2]/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明日の天気やろ？\n明日は雨が降りそうよ(>_<)\n今んところ降水確率はこんな感じ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうやったら教えるね！"
            else
              push =
                "明日の天気？\n明日は雨が降らんみたいよ(^^)\nまた明日の朝の最新の天気予報で雨が降りそうやったら教えるね！"
            end
          when /.*(明後日|あさって|翌々日|よくよくじつ).*/
            per06to12 = doc_f.elements[xpath_f + 'info[3]/rainfallchance/period[2]'].text
            per12to18 = doc_f.elements[xpath_f + 'info[3]/rainfallchance/period[3]'].text
            per18to24 = doc_f.elements[xpath_f + 'info[3]/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明後日の天気やろ？\n何かあると？\n明後日は雨が降りそう…\n今んところ降水確率はこんな感じ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n当日の朝に雨が降りそうやったら教えるけんね！"
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
          when /.*(東京|とうきょう|トウキョウ|tokyo).*/
            tokyo_weather = doc_t.elements[xpath_t + 'info/weather/'].text
            tokyo_centigrade_max = doc_t.elements[xpath_t + 'info/temperature/range[1]'].text
            tokyo_centigrade_min = doc_t.elements[xpath_t + 'info/temperature/range[2]'].text
            push = "東京の天気？\n今日の東京は#{tokyo_weather}よ〜！\n最高気温は#{tokyo_centigrade_max}℃\n最低気温は#{tokyo_centigrade_min}℃\n気を付けて行ってこんね！"
          when /.*(名古屋|なごや|ナゴヤ|nagoya).*/
            nagoya_weather = doc_n.elements[xpath_n + 'info/weather/'].text
            nagoya_centigrade_max = doc_n.elements[xpath_n + 'info/temperature/range[1]'].text
            nagoya_centigrade_min = doc_n.elements[xpath_n + 'info/temperature/range[2]'].text
            push = "名古屋の天気？\n今日の名古屋は#{nagoya_weather}よ〜！\n最高気温は#{nagoya_centigrade_max}℃\n最低気温は#{nagoya_centigrade_min}℃\n気を付けて行ってこんね！"
          when /.*(大阪|おおさか|オオサカ|osaka).*/
            osaka_weather = doc_o.elements[xpath_o + 'info/weather/'].text
            osaka_centigrade_max = doc_o.elements[xpath_o + 'info/temperature/range[1]'].text
            osaka_centigrade_min = doc_o.elements[xpath_o + 'info/temperature/range[2]'].text
            push = "大阪の天気？\n今日の大阪は#{osaka_weather}よ〜！\n最高気温は#{osaka_centigrade_max}℃\n最低気温は#{osaka_centigrade_min}℃\n気を付けて行ってこんね！"
          when /.*使い方.*/
            push = "このbotは毎朝７時にその日の福岡市に雨が降るかどうかを博多弁で教えてくれます。\n\nまた、当日から翌々日までの期間の予報であればチャットで聞くことができます。それぞれ、「あした」、「翌々日」などのキーワードが含まれると該当する日の予報を教えます。\n\nさらに東京、名古屋、大阪など全国の主要都市の当日の天気をチャットで聞けるようになりました。聞きたい都市があれば聞いてみて下さい。対応する都市は順次対応していきます。"
          else
            per06to12 = doc_f.elements[xpath_f + 'info/rainfallchance/period[2]'].text
            per12to18 = doc_f.elements[xpath_f + 'info/rainfallchance/period[3]'].text
            per18to24 = doc_f.elements[xpath_f + 'info/rainfallchance/period[4]'].text
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
          push = ["テキスト以外はわからんば〜い(；；)",
                  "天気のことを聞いてよ？",
                  "何それ、美味しいの？w"].sample
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
