# encoding: utf-8
require "./library/FileIO.rb"
require 'matrix'
class MathFunc
	def initialize()
		@threshold = 0.001
	end
	def calcNorm(x,y,z)
		val = x**2 + y**2 + z**2
		val = val**0.5
		return val
	end
  #デカルト座標から極座標へ
  def polarConversion(loc)
    x,y,z = loc
    r = Math.sqrt(x**2 + y**2 + z**2)
    if(z==0) then
      theta = Math::PI / 2.0
    else
      theta = Math.atan(Math.sqrt(x**2+y**2) / z)
    end
    if(x == 0) then
      phi = Math::PI / 2.0
    else
      phi = Math.atan(y/x)
    end
    result = [r,theta,phi]
    #puts r,ConvertRasianToTheta(theta),ConvertRasianToTheta(phi)
    return result
  end
  #デカルト座標系ベクトルから球座標系ベクトルへ
  def polarConversionVector(vector)
    r,theta,phi = polarConversion(vector)
    vx,vy,vz = vector
    vr = vx*Math.sin(theta)*Math.cos(phi) + vy*Math.sin(theta)*Math.sin(phi) + vz*Math.cos(theta)
    vt = vx*Math.cos(theta)*Math.cos(phi) + vy*Math.cos(theta)*Math.sin(phi) - vz*Math.sin(theta)
    vp = vy*Math.cos(phi) - vx*Math.sin(phi)
    return vr,vt,vp
  end

  def ConvertRasianToTheta(rasian)
    theta = rasian * 180.0 / Math::PI
    if(theta < 0) then
      theta += 180
    end
    return theta
  end

	#デカルト座標系のベクトルを単位ベクトルとのなす角などから角度を計算して返す
	def convertVector(vector)
		vx,vy,vz = vector
		r = Math.sqrt(vx**2 + vy**2 + vz**2)
		ex = [1,0,0]
		exy = [vx.abs,vy.abs,0]
		vxy = [vx,vy,0]
		theta = getVectorialAngle(ex,vxy)
		phi = getVectorialAngle(exy,vector)
		if(theta.to_s == "NaN") then
			theta = 0.0
		end
		if(phi.to_s == "NaN") then
			phi = 0.0
		end
		return r,theta,phi
	end
	#2つの3次元ベクトルのなす角を計算して返す
	def getVectorialAngle(vector1,vector2)
		a1,a2,a3 = vector1
		b1,b2,b3 = vector2
		cos = (a1*b1+a2*b2+a3*b3)/(Math.sqrt(a1**2 + a2**2 + a3**2)*Math.sqrt(b1**2 + b2**2 + b3**2))
		if(cos>1) then
			cos = 1
		elsif(cos < -1) then
			cos = -1
		end
		rad = Math.acos(cos)
		theta = ConvertRasianToTheta(rad)
		if(theta < @threshold) then
			theta = 0
		end
		return theta
	end
	#ベクトルの各値が閾値以下の場合は0にする
	def arrangeVectorZero(x,y,z)
		if(x < 10**-6 and x > -10**-6) then
			x = 0
		end
		if(y < 10**-6 and y > -10**-6) then
			y = 0
		end
		if(z < 10**-6 and z > -10**-6) then
			z =  0
		end
		return x,y,z
	end
	#アフィン変換(x軸中心)
	def affineTransformationX(x,y,z,theta)
		nx,ny,nz = x,y*Math.cos(theta)-z*Math.sin(theta),y*Math.sin(theta)+z*Math.cos(theta)
		nx,ny,nz = arrangeVectorZero(nx,ny,nz)
		return [nx,ny,nz]
	end
	#アフィン変換(y軸中心)
	def affineTransformationY(x,y,z,theta)
		nx,ny,nz = x*Math.cos(theta)+z*Math.sin(theta),y,z*Math.cos(theta)-x*Math.sin(theta)
		nx,ny,nz = arrangeVectorZero(nx,ny,nz)
		return [nx,ny,nz]
	end
	#アフィン変換(z軸中心)
	def affineTransformationZ(x,y,z,theta)
		nx,ny,nz = x*Math.cos(theta)-y*Math.sin(theta),x*Math.sin(theta)+y*Math.cos(theta),z
		nx,ny,nz = arrangeVectorZero(nx,ny,nz)
		return [nx,ny,nz]
	end

	#arrayクラスに有効なメソッド　合計、平均、分散、標準偏差を計算できる
	def sum_with_number(array)
    s = 0.0
    n = 0
    array.each do |v|
      next if v.nil?
      s += v.to_f
      n += 1
    end
    [s, n]
  end
  def sum(array)
    s, n = sum_with_number(array)
    s
  end
  def mean(array)
    s, n = sum_with_number(array)
    s / n
  end
  def var(array)
    c = 0
    while array[c].nil?
      c += 1
    end
    mean = array[c].to_f
    sum = 0.0
    n = 1
    (c+1).upto(array.size-1) do |i|
      next if array[i].nil?
      sweep = n.to_f / (n + 1.0)
      delta = array[i].to_f - mean
      sum += delta * delta * sweep
      mean += delta / (n + 1.0)
      n += 1
    end
    sum / n.to_f
  end

	def stddev(array)
    Math.sqrt(var(array))
  end

	#主成分分析 2変数版 配列の最初の列は時間,2番目はノルムであると想定している
	#使うのは俯角と仰角なので3,4番目だけ
	def PCA2(array)
		x = []
		y = []
		for i in 0 .. array.size-1 do
			#array[i][0]は時間なので無視
			x[x.size] = array[i][2].to_f
			y[y.size] = array[i][3].to_f
		end
		xmean = mean(x)
		ymean = mean(y)
		xstdev = stddev(x)
		ystdev = stddev(y)
		for val in 0 .. x.size-1 do
			x[val] = (x[val] - xmean)/xstdev
		end
		for val in 0 .. y.size-1 do
			y[val] = (y[val] - ymean)/ystdev
		end
		xsMean = mean(x)
		ysMean = mean(y)
		sum_xx = 0
		sum_xy = 0
		sum_yy = 0
		for i in 0 .. x.size-1 do
			sum_xx += (x[i]-xsMean)*(x[i]-xsMean)
			sum_xy += (y[i]-ysMean)*(x[i]-xsMean)
			sum_yy += (y[i]-xsMean)*(y[i]-xsMean)
		end
		sxx = sum_xx/x.size
		sxy = sum_xy/x.size
		syy = sum_yy/y.size
		m = Matrix[[sxx,sxy],[sxy,syy]]
		v,d,v_inv = m.eigensystem
		z1,z2 = [v[0,0],v[0,1]],[v[1,0],v[1,1]]
		calcPCA(array,z1,z2,nil)
		return array
	end

	#主成分分析 3変数版 配列の最初の列は時間であると想定している[time,x,y,z] → [time,z1,z2,z3]
	def PCA3(array)
		x = []
		y = []
		z = []
		for i in 0 .. array.size-1 do
			#array[i][0]は時間なので無視
			x[x.size] = array[i][1].to_f
			y[y.size] = array[i][2].to_f
			z[z.size] = array[i][3].to_f
		end
		xmean = mean(x)
		ymean = mean(y)
		zmean = mean(z)
		xstdev = stddev(x)
		ystdev = stddev(y)
		zstdev = stddev(z)
		for val in 0 .. x.size-1 do
			if(xstdev == 0.0) then
				x[val] = 0.0
			else
				x[val] = (x[val] - xmean)/xstdev
			end
			if(ystdev == 0.0) then
				y[val] = 0.0
			else
				y[val] = (y[val] - ymean)/ystdev
			end
			if(zstdev == 0.0) then
				z[val] = 0.0
			else
				z[val] = (z[val] - zmean)/zstdev
			end
		end
		xsMean = mean(x)
		ysMean = mean(y)
		zsMean = mean(z)
		sum_xx = 0
		sum_xy = 0
		sum_yy = 0
		sum_xz = 0
		sum_yz = 0
		sum_zz = 0
		for i in 0 .. x.size-1 do
			sum_xx += (x[i]-xsMean)*(x[i]-xsMean)
			sum_xy += (y[i]-ysMean)*(x[i]-xsMean)
			sum_yy += (y[i]-xsMean)*(y[i]-xsMean)
			sum_xz += (x[i]-xsMean)*(z[i]-zsMean)
			sum_yz += (y[i]-xsMean)*(z[i]-zsMean)
			sum_zz += (z[i]-zsMean)*(z[i]-zsMean)
		end
		sxx = sum_xx/x.size
		sxy = sum_xy/x.size
		syy = sum_yy/y.size
		sxz = sum_xz/x.size
		syz = sum_yz/y.size
		szz = sum_zz/z.size
		m = Matrix[[sxx,sxy,sxz],[sxy,syy,syz],[sxz,syz,szz]]
		v,d,v_inv = m.eigensystem
		z1 = [v[0,2],v[1,2],v[2,2]]
		z2 = [v[0,1],v[1,1],v[2,1]]
		z3 = [v[0,0],v[1,0],v[2,0]]
		calcPCA(array,z1,z2,z3)
		return array
	end

	def calcPCA(array,z1,z2,z3)
		if(z3 != nil) then
			for i in 0 .. array.size-1 do
					a1 = array[i][1]*z1[0] + array[i][2]*z1[1] + array[i][3]*z1[2]
					a2 = array[i][1]*z2[0] + array[i][2]*z2[1] + array[i][3]*z2[2]
					a3 = array[i][1]*z3[0] + array[i][2]*z3[1] + array[i][3]*z3[2]
					array[i][1],array[i][2],array[i][3] = a1,a2,a3
			end
		else
			for i in 0 .. array.size-1 do
					a1 = array[i][2]*z1[0] + array[i][3]*z1[1]
					a2 = array[i][2]*z2[0] + array[i][3]*z2[1]
					array[i][2],array[i][3] = a1,a2
			end
		end
	end

	def thresholdFilter(data,threshold)
		result = []
		for v in data do
			result[result.size] = v.abs
		end
		mean = mean(result)
		result = []
		for v in data do
			result[result.size] = v
		end
		if(mean <= threshold) then
			for i in 0 .. result.size-1 do
				result[i] = 0
			end
		end
		return result
=begin
		flg = false
		flgTime = 0
		for i in 0 .. data.size-1 do
			val = data[i][1].abs
			t = data[i][0]
			if(val > threshold) then
				flg = true
				flgTime = t.to_f
			end
			if(flg) then
				if(temp.size != 0) then
					if(t.to_f - flgTime <= 0.4) then
						temp[temp.size] = data[i]
					else
						flg = false
						#puts "#{flgTime},#{temp[temp.size-1][0]}"
						if(temp.size >= 100) then
							result[result.size] = temp
						end
						temp = []
					end
				else
					temp[temp.size] = data[i]
				end
			end
		end
=end
		#return result
	end
end
=begin

math = MathFunc.new()
x = [22,24,33,35,38,40,41,41,46,46,50,51,56,56,58,58,59,61,65,68]
y = [38,51,45,45,46,48,52,46,52,49,50,48,51,47,57,42,39,51,61,68]
z = [61,62,56,64,66,60,46,43,70,49,54,52,62,68,68,39,49,79,69,58]
result = []
for i in 0 .. x.size-1 do
	result[result.size] = [i,x[i],y[i]]#,z[i]]
end
flio = FileIO.new("file.csv")
flio.writeFile(result,"test0.csv","w")
array = math.PCA2(result)

flio.writeFile(array,"test1.csv","w")



=end

#puts math.affineTransformationY(1,0,0,Math::PI/0.5)
#vr,vt,vp = math.polarConversionVector([1.0,1.0,0.0])
#puts math.convertVector([0,0,1])
