# encoding: utf-8
require './library/DirFileClass.rb'
require './library/FileIO.rb'
def main3()
	fileIO = DirFile.new(nil)
	filePath = ARGV[0].gsub("\\","/")
	fileList = fileIO.getDirFileEx(filePath,".label")
	for i in 0 .. fileList.size()-1 do
		fileName = fileList[i]
		fData,data = fileIO.getFileStringEx(fileName,"target")
		time = []
		if(fData.size >0) then
			time[0] = [fData[0]]
		end
		for j in 0 .. data.size()-1 do
			wFlag = true
			str = data[j]
			time1,time2,label,val = str.split(",")
			for n in 0 .. time.size-1 do
				if(label == time[n][2] and time1.to_f - time[n][1].to_f < 0) then
					time[n][1] = time2
					wFlag = false
				end
			end
			if(wFlag) then
				time[time.size] = [time1,time2,label]
			end
		end
		if(data.size  > 1) then
			puts time
			flio = FileIO.new("#{fileName}")
			flio.writeFile(time,"#{fileName}","w")
		end
	end
end
main3()
