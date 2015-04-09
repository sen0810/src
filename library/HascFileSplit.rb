# encoding: utf-8
require './DirFileClass.rb'
fileIO = DirFile.new('./')
filePath = ARGV[0].gsub("\\","/")
fileList = fileIO.getDirFileEx(filePath,"raw.log")
for i in 0 .. fileList.size()-1 do
	fileName = fileList[i]
	data = fileIO.getFileStringEx(filePath + "/" + fileName,"WIFI")
	for j in 0 .. data.size()-1 do
		str = data[j]
		str = str.split("WIFI\t")[1]
		data[j] = str +"\n"
	end
	fileName = fileName.gsub("raw.log","wifi.csv")
	fileIO.writeFile(fileName,data)
end
