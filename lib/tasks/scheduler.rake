desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  require 'line/bot'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  #チャンネル定義
  client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }

  url_fukuoka = "https://www.drk7.jp/weather/xml/40.xml"
  url_tokyo = "https://www.drk7.jp/weather/xml/13.xml"
  url_nagoya = "https://www.drk7.jp/weather/xml/23.xml"
  url_osaka = "https://www.drk7.jp/weather/xml/27.xml"


  # require 'kconv'　でStringクラスに変換用のメソッドが定義される。
  # .toutf8 で　url をutf-8に変換した文字列を返す。
  xml_f  = open( url_fukuoka ).read.toutf8
  xml_t  = open( url_tokyo ).read.toutf8
  xml_n  = open( url_nagoya ).read.toutf8
  xml_o  = open( url_osaka ).read.toutf8


  # https://docs.ruby-lang.org/ja/latest/method/REXML=3a=3aDocument/s/new.html
  # ただの文字列だった変数xmlをパースしている。
  doc_f = REXML::Document.new(xml_f)
  doc_t = REXML::Document.new(xml_t)
  doc_n = REXML::Document.new(xml_n)
  doc_o = REXML::Document.new(xml_o)

  xpath_f = 'weatherforecast/pref/area[2]/info/'
  xpath_t = 'weatherforecast/pref/area[4]/info/weather/'
  xpath_n = 'weatherforecast/pref/area[2]/info/weather/'
  xpath_o = 'weatherforecast/pref/area[1]/info/weather/'


  # elements -> REXML::Elements　
  # 要素が保持している子要素の集合を返す。
  per06to12 = doc_f.elements[xpath_f + 'rainfallchance/period[2]'].text
  per12to18 = doc_f.elements[xpath_f + 'rainfallchance/period[3]'].text
  per18to24 = doc_f.elements[xpath_f + 'rainfallchance/period[4]'].text

  tokyo_weather = doc_t.elements[xpath_t].text
  nagoya_weather = doc_n.elements[xpath_n].text
  osaka_weather = doc_o.elements[xpath_o].text
  fukuoka_weather = doc_f.elements[xpath_f + 'weather/'].text

  min_per = 20
  if per06to12.to_i <= min_per && per12to18.to_i <= min_per && per18to24.to_i <= min_per

    word1 =
      ["おはよう！！",
       "目、開いてないよ？w",
       "おは〜〜"].sample
    word2 =
      ["朝ごはん食べた？",
       "調子どう？",
       "支度は済んだと？"].sample
    push ="#{word1}\n#{word2}\n今日の天気は#{fukuoka_weather}よ〜！\n今日は雨降らんそうやし、一日頑張れそうやね！\n全国の天気：\n東京：#{tokyo_weather}\n名古屋：#{nagoya_weather}\n大阪：#{osaka_weather}\n\n※このbotの「使い方」が聞きたい時はチャットで「使い方」と尋ねてみてね。"
    user_ids = User.all.pluck(:line_id)
    message = {
      type: 'text',
      text: push
    }
    response = client.multicast(user_ids, message)
  end

  if per06to12.to_i > min_per || per12to18.to_i > min_per || per18to24.to_i > min_per
    word1 =
      ["いい朝やね！",
       "今日もよく眠れた？",
       "二日酔い大丈夫？",
       "早起きしてえらかね！",
       "いつもより起きるのちょっと遅いっちゃない？"].sample
    word2 =
      ["気をつけて行ってきいね(^^)",
       "よか一日ば過ごしいよ(^^)",
       "雨に負けんで今日も頑張りいね(^^)",
       "今日も一日楽しんでいこうね(^^)",
       "楽しいことがありますように(^^)"].sample

    mid_per = 50
    if per06to12.to_i >= mid_per || per12to18.to_i >= mid_per || per18to24.to_i >= mid_per
      word3 = "今日は雨が降りそうやけん傘ば忘れんでね！"
    else
      word3 = "今日は雨が降るかもしれんけん折りたたみ傘があると安心よ〜！"
    end

    push =
      "#{word1}\n今日の天気は#{fukuoka_weather}よ〜！\n#{word3}\n降水確率はこんな感じよ！\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n#{word2}\n全国の天気：\n東京：#{tokyo_weather}\n名古屋：#{nagoya_weather}\n大阪：#{osaka_weather}\n\n※このbotの「使い方」が聞きたい時はチャットで「使い方」と尋ねてみてね。"

    user_ids = User.all.pluck(:line_id)
    message = {
      type: 'text',
      text: push
    }
    response = client.multicast(user_ids, message)
  end
  "OK"
end
