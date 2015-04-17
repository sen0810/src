# encoding: utf-8
require 'mail'
require './library/WebAPIController.rb'
values = [
  ["マヌケなFPSプレイヤーが異世界へ落ちた場合","N4076CM"],
  ["くま　クマ　熊　ベアー","N4185CI"],
  ["NO FATIGUE 24時間戦える男の転生譚","n6990ch"],
  ["ありふれた職業で世界最強","n8611bv"],
  ["武に身を捧げて百と余年。エルフでやり直す武者修行","n4748bs"],
  ["黒銀の決意　~混沌転生~","n9607bw"],
  ["ワールド・ティチャー -異世界式教育エージェント","n4237cd"]
]

ncodes = ""
for v in values do
  ncodes += v[1] + "-"
end
ncodes.slice!(ncodes.length-1, 1)
api = WebAPIController.new('http://api.syosetu.com/novelapi/api/?of=t-ua&ncode=' + ncodes)
api.connect()
str = api.getBody()
tmp = str.split("\n")
count = 0
body = ""
for v in tmp do
  if(v.include?("updated_at")) then
    day = v.split("updated_at\:\s")[1]
    body += values[count][0] + " : " + day +"\n"
    count += 1
  end
end



mail = Mail.new do
  from "takeshima1092@gmail.com"
  to "sen@ucl.nuee.nagoya-u.ac.jp"
  subject "novel update news!!"
  body "#{body}"
end

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => "smtp.gmail.com",
            :user_name            => 'takeshima1092@gmail.com',
            :password             => ARGV[0].to_s,
            :authentication       => :plain,
            :enable_starttls_auto => true  }
mail.delivery_method(:smtp,options)
mail.deliver!
