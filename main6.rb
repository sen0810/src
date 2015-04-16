require './library/DirFileClass.rb'
require './library/FileIO.rb'

def main(fileName)
	dirC = DirFile.new(nil)
  content = dirC.getFileString(fileName)
	pattern = []
	pattern[pattern.size] =[]
	temp = []
	str = ""
	for v in content do
		if(v.include?("target")) then
			tmp = v.split('/')
			distance = tmp[3]
			pos = tmp[4]
			pattern[pattern.size-1][pattern[pattern.size-1].size] = str
			if(temp.index("#{distance},#{pos}") == nil) then
				pattern[pattern.size] =[]
				pattern[pattern.size-1][0] = "\n\n#{distance},#{pos}"
				temp[temp.size] = "#{distance},#{pos}"
			end
			str = tmp[5] + "\n"
		#elsif(v.include?("通過")) then

		else
			str += v.split(",")[2]
		end
	end
	output = []
	for v in pattern do
		output[output.size] = v.join("\n")
	end
	dirC.writeFile("lableList-2.txt",output,'w')
end


fileName = ARGV[0].to_s
main(fileName)
=begin
dirC = DirFile.new(nil)
fileNameList = dirC.getDirFileEx("#{fileName}",".label")
for val in fileNameList do
	if(val.include?("label") and not val.include?('.label.label')) then
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
	end
end
=end
