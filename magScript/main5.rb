#ラベルファイルを編集し、リストとして出力する
require './library/DirFileClass.rb'
require './library/FileIO.rb'
@resultData = [[0,0],[0,0],[0,0]]
def main(fileName)
  dirC = DirFile.new(nil)
  content = dirC.getFileString(fileName)
  direction = fileName.split('/')[4]
  position = fileName.split('/')[2]
  if(not direction.include?('direction')) then
    direction = nil
  end
  array = []
  labelA = []
  labelB = []
  labelC = []
  labels = []
  labelPath = ""
  t = []
  for v in content do
    if(v.include?(',')) then
      t1,t2,label = v.split(",")
      array[array.size] = [t1.to_f,t2.to_f,label]
      if(label == "A") then
        labelA[labelA.size] = [t1.to_f,t2.to_f,"A"]
      elsif(label == "B") then
        labelB[labelB.size] = [t1.to_f,t2.to_f,"B"]
      else
        t[t.size] = [t1.to_f,t2.to_f,label]
      end
    else
      labelPath = v.chomp
    end
  end
  if(labelA.size == 1) then
    labelC = labelA[0]
    labels = labelB
  elsif(labelB.size == 1) then
    labelC = labelB[0]
    labels = labelA
  end
  result = []
  for v in labels do
    if(labelC[0] <= v[0]) then
      if(labelC[1] > v[0]) then
        if(labelC[0] != v[0] and labelC[0] < v[0]) then
          result[result.size] = [labelC[0],v[0],labelC[2]]
        end
        result[result.size] = [v[0],labelC[1],"C"]
        if(labelC[1]!=v[1] and labelC[1] < v[1]) then
          result[result.size] = [labelC[1],v[1],v[2]]
        end
      else
        result[result.size] = [labelC[0],labelC[1],labelC[2]]
        result[result.size] = [v[0],v[1],v[2]]
      end
    elsif(labelC[0] > v[0]) then
      if(labelC[0] < v[1] and labelC[0] > v[0]) then
        if(v[0] != labelC[0]) then
          result[result.size] = [v[0],labelC[0],v[2]]
        end
        result[result.size] = [labelC[0],v[1],"C"]
        if(v[1] != labelC[1] and labelC[1] > v[1]) then
          result[result.size] = [v[1],labelC[1],labelC[2]]
        end
      else
        result[result.size] = [labelC[0],labelC[1],labelC[2]]
        result[result.size] = [v[0],v[1],v[2]]
      end
    end
  end
  output = []
  output[0] = labelPath + "\n"
  for v in result do
    output[output.size] = v.join(",") + "\n"
  end
  for v in t do
    output[output.size] = v.join(",") + "\n"
  end
  t = false
  str = ""
  for i in 1 .. output.size-1 do
    str += output[i][output[i].length-2]
  end
  if(direction == "direction1" and str == "ACBP") then
    t = true
  elsif(direction == "direction2" and str == "BCAP") then
    t = true
  end
  x = 0
  if(position == "50cm") then
    x = 0
  elsif(position == "75cm") then
    x = 1
  elsif(position == "100cm") then
    x = 2
  else
    x = nil
  end
  if(x != nil) then
    if(t==false) then
      puts "#{fileName}"
    end
    puts "#{str}/#{direction}/#{t}"
    @resultData[x][0] += t ? 1:0
    @resultData[x][1] += 1
  end
  dirC.writeFile(fileName + '.label',output,nil)
  dirC.writeFile("lableList.txt",output,'a')
end
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
fileName = ARGV[0].to_s
dirC = DirFile.new(nil)
fileNameList = dirC.getDirFileEx("#{fileName}",".label")
for val in fileNameList do
	if(val.include?("label") and not val.include?('.label.label') and not val.include?("sp")) then
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
		main(val)
    #result = main("#{val}",path)
		#flio = FileIO.new("#{path}\\#{val}.label")
		#flio.writeFile(result,"#{path}\\#{e}.label","w")
	end
end
puts @resultData
for v in @resultData do
  c,s = v[0],v[1]
  puts c.to_f/s.to_f
end