# encoding: utf-8
require './library/DirFileClass.rb'
fileIO = DirFile.new('.')
filePath = ARGV[0].gsub("\\","/")
fileList = fileIO.getDirFileEx(filePath,"raw.log")
for i in 0 .. fileList.size()-1 do
	fileName = fileList[i]
	data = fileIO.getFileStringEx(fileName,"WIFI",true)
	for j in 0 .. data.size()-1 do
		str = data[j]
		str = str.split("\tWIFI\t")
		if(str[1].index(":") < 5) then
			list = str[1].split(",")
			for x in 0 .. list.size-1 do
				if(list[x].rindex('|') == list[x].size-4) then
					list[x] += '|'
				end
			end
			str[1] = list.join(",")
			str = str[0] + "," + str[1]
		else
			list = str[1].split(",")
			for x in 1 .. list.size-1 do
				temp = list[x].split('|')
				p = temp[1]
				temp[1] = temp[2]
				temp[2] = p
				list[x] = temp.join('|')
				list[x] += '|'
			end
			str = list.join(",")
		end
		data[j] = str +"\n"
	end
	fileName = fileName.gsub("raw.log","wifi.csv")
	fileIO.writeFile(fileName,data,false)
end