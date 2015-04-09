# encoding: utf-8
require 'fileutils'
require 'csv'

class DirFile

	def initialize(path)
		@path = path
	end

	def setPath(path)
		@path = path
 	end

 	def getPath
 		return @path
 	end

 	#新しいフォルダを作成する関数
 	def makeDir(dirName)
 		Dir::mkdir("#{@path}/#{dirName}")
 	end

 	#フォルダを削除する関数(中にファイルが存在したら全部削除する)
 	def deleteDir(dirName)
 		# 削除するディレクトリ
		path = ""
		if(@path != nil) then
			path = "#{@path}/"
		end
		dir = "#{path}#{dirName}"
		input = "y"#Readline.readline("#{dirName}内にあるファイルを削除してもよろしいですか？")
		if(input == "y") then
			# サブディレクトリを階層が深い順にソートした配列を作成
			dirlist = Dir::glob(dir + "**/").sort {
			  |a,b| b.split('/').size <=> a.split('/').size
			}
			# サブディレクトリ配下の全ファイルを削除後、サブディレクトリを削除
			dirlist.each {|d|
			  Dir::foreach(d) {|f|
			    File::delete(d+f) if ! (/\.+$/ =~ f)
			  }
			  Dir::rmdir(d)
			}
			puts "削除しました"
		else
			puts "削除を取りやめました"
		end
 	end

 	#フォルダの名前を変更する
 	def renameDir(dirName,newName)
		path = ""
		if(@path != nil) then
			path = "#{@path}/"
		end
 		File::rename("#{path}#{dirName}", "#{path}#{newName}")
 	end

 	#フォルダ内にあるフォルダ、ファイル名一覧を取得する
 	def getAllDirFile(dirName)
		path = ""
		if(@path != nil) then
			path = "#{@path}/"
		end
 		return Dir::entries("#{path}#{dirName}")
 	end
 	#第2引数で指定された文字を含むファイル名一覧を取得
 	def getDirFileEx(dirName,fileName)
		path = ""
		if(@path != nil) then
			path = "#{@path}/"
		end
 		list = Dir.glob("#{path}#{dirName}/*")
 		result = []
 		for name in list do
 			if(Dir.exists?(name)) then
 				dir = Dir.glob("#{name}/*")
 				list.concat(dir)
 			else
 				if(name.include?(fileName)) then
 					result[result.size] = name
 				end
 			end
 		end
=begin
 		result = []
 		for i in 0 .. list.size()-1 do
 			if(list[i].include?(fileName))then
 				result[result.size()] = list[i]
 			end
 		end
=end
 		return result
 	end

 	#フォルダ内にあるフォルダの名前の一部を一括変換する
 	def changeAllDirName(dirName,reg,ch)
		path = ""
		if(@path != nil) then
			path = "#{@path}/"
		end
 		Dir::glob("#{path}#{dirName}/*").each {|f|
		  	f = f.to_s.split("/")
		  	name = f[f.length - 1]
		  	renameDir("#{dirName}/#{name}","#{dirName}/#{name.gsub(reg,ch)}")
		}
 	end

	#ファイルを読み込んで配列で返す
	def getFileString(fileName)
		array = []
		path = ""
		if(@path != nil) then
			path = "#{@path}/"
		end
		File.open("#{path}fileName",'r') {|f|
			f.each_line {|line|
				array[array.size()] = line.chomp
			}
		}
		return array
	end

	def writeFile(fileName,array)
		path = ""
		if(@path != nil) then
			path = "#{@path}/"
		end
		File.open("#{path}#{fileName}", "w") { |file|
			for i in 0 .. array.size()-1 do
				file.write array[i]
			end
		}
	end
	#ファイルを読み込んで第2引数の文字が含まれた文字列だけを配列で返す
	#サイズの大きいファイルを読み込む時用
	def getFileStringEx(fileName,str)
		array = []
		path = ""
		if(@path != nil) then
			path = "#{@path}/"
		end
		File.open("#{path}#{fileName}",'r') {|f|
			f.each_line {|line|
				if(line.include?(str)) then
					array[array.size()] = line.chomp
				end
			}
		}
		return array
	end

	#以降のメッソドはPlayerクラスのオブジェクトのみが呼び出し可能
	protected

end
