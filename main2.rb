# encoding: utf-8
require 'bigdecimal'
require './library/FFT.rb'
require './library/FileIO.rb'
require './library/MathFunc.rb'
require './library/DirFileClass.rb'
require 'fileutils'
@labelArray = []
@maxLoc = []
def main(fileName,path)
	windowWidth = ARGV[1].to_i
	windowName = ARGV[2].to_s
	slideWidth = ARGV[3].to_i
	axis = ARGV[4].to_s
#	mode = ARGV[5].to_s
	axisIndex = 1
	labelAFreq = 5
	labelBFreq = 10
	flio = FileIO.new(fileName)
	data = flio.getFileString(axisIndex,false)
	math = MathFunc.new()
	rd = math.thresholdFilter(data,1.5)
	fft = FFT.new(windowWidth,slideWidth,windowName)
	fs = fft.samplingFreqency
	freqArray = []
	fN = fileName.split("/")
	fN = fN[fN.size-1]
	freqArray[0] = ['#targetfile:$(projectRoot)/' + path +"#{fN}"]
	if(rd[0] != nil) then
		data = []
		for v in rd do
			if(data.size < v.size) then
				data = v
			end
		end
		result = fft.fourieTrans(data)
		bf = 0.0
		af = 0.0
		afc = 0.0
		bfc = 0.0
		for i in 1 .. result.size() do
			freq = []
			leng = result[i-1].size() / 2
			meanF = 0.0
			count = 0.0
			labelAF = 0
			labelBF = 0 
			for j in 2 .. leng do
				val = result[i-1][j-1][0]**2 + result[i-1][j-1][1]**2
				val = val**0.5
				f = (j-1.0)*fs/windowWidth
				freq[freq.size] = [BigDecimal(f.to_s).floor(1).to_f,val.to_i]
				if(f > 3 and f < 25) then
					meanF += val
					count += 1.0
				end
				if(f >= labelAFreq-1 and f <= labelAFreq+1) then
					af += val
					afc += 1
					if(val > labelAF) then
						labelAF = val
					end
				elsif(f >= labelBFreq-1 and f <= labelBFreq+1) then
					bf += val
					bfc += 1
					if(val > labelBF) then
						labelBF = val
					end
				end
			end
			meanF /= count
			#180
			test = 0
			if(labelAF > 85) then
				freqArray[freqArray.size] = data[slideWidth*(i-1)][0],data[slideWidth*(i-1) + windowWidth][0],"A",labelAF.to_i,meanF.to_i
				test += 1
			end
			#180
			if(labelBF > 35) then
				freqArray[freqArray.size] = data[slideWidth*(i-1)][0],data[slideWidth*(i-1) + windowWidth][0],"B",labelBF.to_i,meanF.to_i
				test += 1
			end
			if(test == 2) then
				flio.writeFile(freq,"#{path}\\#{fileName.split("/")[1]}-#{i}.csv","w")
			end
		end
	else
		puts fileName
	end
	return freqArray
end
#FFTを行う
fileName = ARGV[0].to_s
dirC = DirFile.new(nil)
fileNameList = dirC.getDirFileEx("#{fileName}",".csv")
for val in fileNameList do
	if(val.include?("lowpass") and !val.include?("label")) then
		tmp = val.split("/")
		name = ""
		path = ""
		for e in tmp do
			if(!e.include?('.')) then
				path += e + "/"
			else
				name = e
			end
		end
		result = main("#{val}",path)
		flio = FileIO.new("#{path}\\#{val}.label")
		flio.writeFile(result,"#{path}\\#{e}.label","w")
	end
end
=begin
flio = FileIO.new("#{path}\\#{fileName}.label")
flio.writeFile(result,"#{path}\\#{fileName}.label","w")
puts "#{path}\\#{fileName}.label"

	
	


if(ARGV[4].to_s!="rotate" and ARGV[5].to_s != "pca") then
	flio = FileIO.new("#{path}\\#{fileName}.label")
	flio.writeFile(@labelArray,"#{path}\\label-#{ARGV[4]}.csv","w")
	flio.writeFile(viewLableResult(),"#{path}\\view-#{ARGV[4]}.csv","w")
end
=end