# encoding: utf-8
require 'mail'
require './library/WebAPIController.rb'
require './library/DirFileClass.rb'
values = []
dirC = DirFile.new(nil)
data = dirC.getFileString("novelData.csv")
for v in data do
  #title,nCode,epSum =
  values[values.size] = v.split(",")
end
ncodes = ""
for v in values do
  ncodes += v[1] + "-"
end
ncodes.slice!(ncodes.length-1, 1)
api = WebAPIController.new('http://api.syosetu.com/novelapi/api/?of=t-ua-ga&ncode=' + ncodes)
api.connect()
str = api.getBody()
tmp = str.split("\n")
count = 0
body = ""
isNext = false
title = ""
isChange = false
for v in tmp do
  if(isNext) then
    title = v[4,v.length-4]
    isNext = false
  end
  if(v.include?("title")) then
    if(v.include?("title:\s>")) then
      isNext = true
    else
      title = v.split("title:\s")[1]
    end
  elsif(v.include?("general_all_no")) then
    ep = v.split("general_all_no\:\s")[1]
    title = title.force_encoding("utf-8")
    for t in values do
      if(t[0] == title) then
        if(ep != t[2]) then
          body += "#{title}:\s#{ep.to_i - t[2].to_i}話更新\n"
          t[2] = ep
          isChange = true
        end
      end
    end
    count += 1
  end
end
if(isChange) then
  body= body.force_encoding("utf-8")
  dirC.writeCSVFile("novelData.csv",values,'w')
  mail = Mail.new do
    from 'novelupdateinfo@gmail.com'
    to "takeshima1092@gmail.com"
    subject "novel update news!!"
    body "#{body}"
  end
  options = { :address              => "smtp.gmail.com",
              :port                 => 587,
              :domain               => "smtp.gmail.com",
              :user_name            => 'novelupdateinfo@gmail.com',
              :password             => "narouapi",
              :authentication       => :plain,
              :enable_starttls_auto => true  }
  mail.delivery_method(:smtp,options)
  mail.deliver!
end
