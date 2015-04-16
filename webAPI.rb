#WebAPIを使う
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
#paramas = URI.encode_www_form({})
api = WebAPIController.new('http://api.syosetu.com/novelapi/api/?of=t-ua&ncode=' + ncodes)
api.connect()
str = api.getBody()
tmp = str.split("\n")
count = 0
for v in tmp do
  if(v.include?("updated_at")) then
    day = v.split("updated_at\:\s")[1]
    puts values[count][0] + " : " + day
    count += 1
  end
end
#uri = URI.parse()
=begin
begin
  response = Net::HTTP.start(uri.host,uri.port) do |http|
    http.open_timeout = 5
    http.read_timeout = 10
    http.get(uri.request_uri)
end

case response
when Net::HTTPSuccess
    str = response.body#JSON.parse(response.body)
    tmp = str.split("\n")
    for v in tmp do
      if(v.include?("updated_at")) then
        day = v.split("updated_at\:\s")[1]
        puts values[count][0] + " : " + day
        count += 1
      end
    end
when Net::HTTPRedirection
  puts("Redirection: code=#{response.code} message=#{response.message}")
else
  puts("HTTP ERROR: code=#{response.code} message=#{response.message}")
end

rescue IOError => e
  puts(e.message)
rescue TimeoutError => e
  puts(e.message)
rescue JSON::ParserError => e
  puts(e.message)
rescue => e
  puts(e.message)
end
=end
