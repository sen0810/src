# encoding: utf-8
require 'fileutils'
require 'csv'
require './library/MathFunc.rb'
#FFT.rbのためにあるファイル管理クラス
class FileIO
	def initialize(fileName)
		@fileName = fileName
	end

  #ファイルを読み込む
  def getFileString(index)
  	array = []
  	File.open(@fileName,'r') {|f|
  		f.each_line {|line|
  			array[array.size()] = line.chomp
  		}
  	}
  	return setData(array,index)
  end

  #ファイル出力
  def writeFile(array,fileName,mode)
  	if(mode == nil) then
  		mode = "w"
  	end
  	CSV.open(fileName, mode) do | writer |
  	  array.each do | item |
  	    writer << item
  	  end
  	end
  end


  protected
  #ファイルから読みだしたcsvデータを受け取りindexと0の値を配列に入れて返す
  def setData(array,index)
  	result = []
		math = MathFunc.new()
  	for i in 0 .. array.size()-1 do
  		temp = array[i].split(",")
			if(index == 5) then
				r,theta,phi = math.convertVector([temp[1].to_f,temp[2].to_f,temp[3].to_f])
				val = [r,theta,phi]
			else
				val = [temp[index].to_f]
			end
  		result[result.size()] = [temp[0].to_f]
			result[result.size()-1].concat(val)
  	end
  	return result
  end

  attr_accessor :fileName
end
