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

  url = "https://www.drk7.jp/weather/xml/40.xml"
  url_tokyo = "https://www.drk7.jp/weather/xml/13.xml"

  # require 'kconv'　でStringクラスに変換用のメソッドが定義される。
  # .toutf8 で　url をutf-8に変換した文字列を返す。
  xml  = open( url ).read.toutf8
  xml_t  = open( url_tokyo ).read.toutf8

  # https://docs.ruby-lang.org/ja/latest/method/REXML=3a=3aDocument/s/new.html
  # ただの文字列だった変数xmlをパースしている。
  doc = REXML::Document.new(xml)
  doc_t = REXML::Document.new(xml_t)

  xpath = 'weatherforecast/pref/area[2]/info/rainfallchance/'
  xpath_t = 'weatherforecast/pref/area[4]/info/weather/'

  # elements -> REXML::Elements　
  # 要素が保持している子要素の集合を返す。
  per06to12 = doc.elements[xpath + 'period[2]'].text
  per12to18 = doc.elements[xpath + 'period[3]'].text
  per18to24 = doc.elements[xpath + 'period[4]'].text

  tokyo_weather = doc.elements[xpath_t].text


  min_per = 20
  if per06to12.to_i < min_per || per12to18.to_i < min_per || per18to24.to_i < min_per

    word1 =
      ["おはよう！！",
       "目、開いてないよ？w",
       "おは〜〜"].sample
    word2 =
      ["朝ごはん食べた？",
       "調子どう？",
       "支度は済んだと？"].sample
    push ="#{word1}\n#{word2}\n今日は雨降らんそうやし、一日頑張れそうやね！\n全国の天気：\n東京：#{tokyo_weather}"
    user_ids = User.all.pluck(:line_id)
    message = {
      type: 'text',
      text: push
    }
    response = client.multicast(user_ids, message)
  end

  if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
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
      "#{word1}\n#{word3}\n降水確率はこんな感じよ！\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n#{word2}\n全国の天気：\n東京：#{tokyo_weather}"

    user_ids = User.all.pluck(:line_id)
    message = {
      type: 'text',
      text: push
    }
    response = client.multicast(user_ids, message)
  end
  "OK"
end
