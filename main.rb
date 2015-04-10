# encoding: utf-8

require './library/FFT.rb'
require './library/FileIO.rb'
require './library/MathFunc.rb'
require './library/DirFileClass.rb'
require 'fileutils'
@labelArray = []
@maxLoc = []
def main(fileName)
	windowWidth = ARGV[1].to_i
	windowName = ARGV[2].to_s
	slideWidth = ARGV[3].to_i
	axis = ARGV[4].to_s
	mode = ARGV[5].to_s
	axisIndex = 0
	freqAThreshold = 500
	freqBThreshold = 600
		if(axis=="x") then
			axisIndex = 1
		elsif(axis=="y") then
			axisIndex = 2
		elsif(axis=="z") then
		  axisIndex = 3
		elsif(axis == "norm") then
		  axisIndex = 4
		elsif(axis == "rotate") then
			axisIndex = 5
  	end
  	flio = FileIO.new(fileName)
	pcaFlg = false
	if mode == "pca" then
		pcaFlg = true
	end
	data = flio.getFileString(axisIndex,pcaFlg)
	path = fileName.split("\\")
	fileName = path[path.size-1]
	math = MathFunc.new()
	path[path.size-1] = path[path.size-1].split(".")[0]
	path = path.join("\\")
	pcaName = ""
	path = path.split('/')[0]
	if(axisIndex==5) then
		pcaPath = ""
		if(mode =="pca" )then
			math.PCA2(data)
			pcaName = "-pca"
			pcaPath = "pca\\"
		end
		FileUtils.mkdir_p(path + "\\result\\rotate\\#{pcaPath}") unless FileTest.exist?(path + "\\result\\rotate\\pcaPath")
		flio.writeFile(data,path + "\\result\\rotate\\#{pcaPath}" + fileName.split("\.")[0].split('/')[1] + "-rotate#{pcaName}.csv","w")
	elsif(mode == "pca") then
=begin
		for i in 0 .. data.size-1 do
			t = data[i][0]
			x,y,z = data[i][1],data[i][2],data[i][3]
			nx,ny,nz = math.affineTransformationY(x,y,z,30)
			nx,ny,nz = math.affineTransformationZ(nx,ny,nz,30)
			data[i] = [t,nx,ny,nz]
		end
=end
		math.PCA3(data)
		pcaName = "-pca"
		FileUtils.mkdir_p(path + "\\result\\#{fileName.split("\.")[0].split('/')[1]}\\#{fileName.split("\.")[0].split('/')[2]}") unless FileTest.exist?(path + "\\result\\#{fileName.split("\.")[0].split('/')[1]}\\#{fileName.split("\.")[0].split('/')[2]}")
		flio.writeFile(data,path + "\\result\\#{fileName.split("\.")[0].split('/')[1]}\\#{fileName.split("\.")[0].split('/')[2]}\\" + fileName.split("\.")[0].split('/')[3] + "#{pcaName}.csv","w")
	else
		fft = FFT.new(windowWidth,slideWidth,windowName)
		fs = fft.samplingFreqency
		max = 0
		min = 10000
		for i in 0 .. data.size-1 do
			t = data[i][0]
			x = data[i][1]
			if(x > max) then
				max = x
			end
			if(x < min) then
				min = x
			end
		end
		if(max - min >= 0) then
			result = fft.fourieTrans(data)
			freqArray = []
			for i in 1 .. result.size() do
				maxVal = 0
			  	maxFreq = 0
			  	temp = []
			  	array = [0,0,0,0]
			  	leng = result[i-1].size() / 2

			  	for j in 2 .. leng do
			  		val = result[i-1][j-1][0]**2 + result[i-1][j-1][1]**2
			  		val = val**0.5
			  		f = (j-1.0)*fs/windowWidth
			  		temp[j-2] = [f.round,val]
			  	end
			  	if(temp[1][1] != nil) then
			  		freqArray = temp
			  	end
			  end

			  # ここからシミュレータ用処理
			  index1 = fileName.rindex("[")
			  index2 = fileName.rindex("]")
			  loc = fileName[index1+1,index2-index1-1]
				x,y,z = loc.split(",")
				if(x.to_i >= @maxLoc[0].to_i and y.to_i >= @maxLoc[1].to_i) then
					@maxLoc = [x.to_i,y.to_i]
				end
			  freqA = 0
			  freqB = 0
			  sum = 0
			  for i in 0 .. freqArray.size-1 do
			      f,val = freqArray[i][0],freqArray[i][1]
			      sum += val
			      if(f >= 9 and f <= 12) then
			        freqA += val
			      end

			      if(f >= 19 and f <= 22) then
			        freqB += val
			      end
			  end
			  mean = sum/freqArray.size.to_f
			  freqA /= 2.0
			  freqB /= 2.0
			  label = ""
				if(freqA > mean*ARGV[5].to_f) then
			    label += "A"
			  end
				if(freqB > mean*ARGV[6].to_f) then
			    label += "B"
			  end
			  if(label == "AB") then
			    label = "C"
			  end
			  @labelArray[@labelArray.size] = [loc,label]
			  #FileUtils.mkdir_p(path + "\\result\\") unless FileTest.exist?(path + "\\result\\")
			  #flio.writeFile(freqArray,path + "\\result\\" + fileName.split("\.")[0].split('/')[1] + "-#{axis}.csv","w")
		else
			index1 = fileName.rindex("[")
			index2 = fileName.rindex("]")
			loc = fileName[index1+1,index2-index1-1]
			x,y,z = loc.split(",")
			if(x.to_i >= @maxLoc[0].to_i and y.to_i >= @maxLoc[1].to_i) then
				@maxLoc = [x.to_i,y.to_i]
			end
			@labelArray[@labelArray.size] = [loc,"N"]
		end
	end
end
#FFTを行う
fileName = ARGV[0].to_s
path = fileName.split("\\")
fileName = path[path.size-1]
path.delete_at(path.size-1)
path = path.join("\\")
dirC = DirFile.new(nil)
fileNameList = dirC.getDirFileEx("#{fileName}",".csv")
#main("#{path}/#{fileName}")

for val in fileNameList do
	#if(val.include?("mag") and !val.include?("lowpass")) then
		main("#{val}")
	#end
end
=begin
@lengX,@sizeX = (@maxLoc[0].to_f/10.0).round*20,20
@lengY,@sizeY =	(@maxLoc[1].to_f/10.0).round*20,20
#for x in -@lengX .. @lengX do
#  for y in -@lengY .. @lengY do
#    fileName = "#{path}\\loc[#{x*@sizeX-2},#{y*@sizeY-2},110].csv"
#    main(fileName)
#  end
#end
def outputArray(array)
  str = ""
  for i in 0 .. array.size-1 do
    str += array[i].join(",") + "\n"
  end
end
def viewLableResult()
    result = []
	shiftY = (@lengY)/(@sizeY)
	shiftX = (@lengX)/(@sizeX)
	y = -@lengY/2
	begin
		result[y/shiftY + @sizeY/2] = []
		x = -@lengX/2
		begin
			result[y/shiftY + @sizeY/2][x/shiftX + @sizeX/2] = "N"
			x += shiftX
		end while x <= @lengX/2
		y += shiftY
	end while y <= @lengY/2

    for i in 0 .. @labelArray.size-1 do
      loc,label = @labelArray[i][0],@labelArray[i][1]
      if(label != "") then
        x,y,z = loc.split(",")
		x = (x.to_f/10.0).round*10
		y = (y.to_f/10.0).round*10
        x = (x)/shiftX + @sizeX/2
        y = (y)/shiftY + @sizeY/2
        #puts result[y][x]
        #puts x,y,label
        result[y][x] = label
      end
    end
    outputArray(result)
    return result
end
if(ARGV[4].to_s!="rotate" and ARGV[5].to_s != "pca") then
	flio = FileIO.new("#{path}\\label.csv")
	flio.writeFile(@labelArray,"#{path}\\label-#{ARGV[4]}.csv","w")
	flio.writeFile(viewLableResult(),"#{path}\\view-#{ARGV[4]}.csv","w")
end
=end
