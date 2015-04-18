# encoding: utf-8
require 'bigdecimal'
require './library/FFT.rb'
require './library/FileIO.rb'
require './library/MathFunc.rb'
require './library/DirFileClass.rb'
require 'fileutils'
def getMean(array)
	return array.inject(0.0){|r,i| r+=i }/array.size
end
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
	data = flio.getFileString(axisIndex)
	math = MathFunc.new()
	#rd = math.thresholdFilter(data,1.5)
	fft = FFT.new(windowWidth,slideWidth,windowName)
	fs = fft.samplingFreqency
	freqArray = []
	fN = fileName.split("/")
	fN = fN[fN.size-1]
	freqArray[0] = ['#targetfile:$(projectRoot)/' + path +"#{fN}"]
	labelADiffMean = []
	labelBDiffMean = []
	labelAMean = [0]
	labelBMean =[0]
	tempA = []
	tempB = []
	if(true) then
		result = fft.fourieTrans(data)
		bf = 0.0
		af = 0.0
		afc = 0.0
		bfc = 0.0
		aflg = false
		bflg = false
		preA = 0.0
		preB = 0.0
		for i in 1 .. result.size() do
			freq = []
			leng = result[i-1].size() / 2
			meanF = 0.0
			count = 0.0
			labelAF = 0
			labelBF = 0
			mean = 0.0
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
			mean = getMean(labelAMean)
			if(labelAF-mean > 10) then
				aflg = true
			end
			if(tempA.size < 10) then
				tempA[tempA.size] = labelAF
			else
				tempA[tempA.size] = labelAF
				labelADiffMean[labelADiffMean.size] = getMean(tempA) - preA
				preA = getMean(tempA)
				labelAMean[labelAMean.size] = getMean(tempA)
				tempA.delete_at(0)
				#tempA = []
			end
			mean = getMean(labelBMean)
			if(labelBF-mean > 10) then
				bflg = true
			end
			if(tempB.size < 10) then
				tempB[tempB.size] = labelBF
			else
				tempB[tempB.size] = labelBF
				labelBDiffMean[labelBDiffMean.size] = getMean(tempB) - preB
				preB = getMean(tempB)
				labelBMean[labelBMean.size] = getMean(tempB)
				tempB.delete_at(0)
				#tempB = []
			end
			#180
			test = 0
			if(aflg)then#labelAF > 85) then
				freqArray[freqArray.size] = data[slideWidth*(i-1)][0],data[slideWidth*(i-1) + windowWidth][0],"A",labelAF.to_i,meanF.to_i
				test += 1
			end
			#180
			if(bflg) then#labelBF > 35) then
				freqArray[freqArray.size] = data[slideWidth*(i-1)][0],data[slideWidth*(i-1) + windowWidth][0],"B",labelBF.to_i,meanF.to_i
				test += 1
			end
		end
		adiff = getMean(labelADiffMean)
		bdiff = getMean(labelBDiffMean)
		puts "#{fileName} /\t#{adiff},#{bdiff}"
		dirC = DirFile.new(nil)
		dirC.writeFile("#{path}\\#{fileName.split("/")[4]}-spA.csv",labelAMean,"w")
		dirC.writeFile("#{path}\\#{fileName.split("/")[4]}-spB.csv",labelBMean,"w")

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
	if(val.include?("lowpass") and !val.include?("label") and !val.include?("sp")) then
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
