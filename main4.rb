require './library/FileIO.rb'
require './library/MathFunc.rb'
require './library/DirFileClass.rb'
require 'fileutils'

file = DirFile.new("./")
data = file.getFileString(ARGV[0])
fx,fy,fz = 0,0,0
math = MathFunc.new()

for i in 0 .. data.size-1 do
	temp = data[i].split(",")
	if(i == 0) then
		fx,fy,fz = temp[1].to_f,temp[2].to_f,temp[3].to_f
	end
	vec = []
	vec[0] = temp[1].to_f - fx
	vec[1] = temp[2].to_f - fy
	vec[2] = temp[3].to_f - fz
	r,theta,phi = math.convertVector(vec)
	data[i] = [temp[0],r,theta,phi]
end
puts data.size
flio = FileIO.new(ARGV[0])
flio.writeFile(data,"angle.csv",'w')