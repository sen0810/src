# encoding: utf-8

class MathFunc
	def initialize()
		@threshold = 0.001
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
		exy = [vx,vy,0]
		theta = getVectorialAngle(ex,exy)
		phi = getVectorialAngle(exy,vector)
		return r,theta,phi
	end
	#2つの3次元ベクトルのなす角を計算して返す
	def getVectorialAngle(vector1,vector2)
		a1,a2,a3 = vector1
		b1,b2,b3 = vector2
		cos = (a1*b1+a2*b2+a3*b3)/(Math.sqrt(a1**2 + a2**2 + a3**2)*Math.sqrt(b1**2 + b2**2 + b3**2))
		if(cos>1) then
				cos = 1
		end
		rad = Math.acos(cos)
		theta = ConvertRasianToTheta(rad)
		if(theta < @threshold) then
			theta = 0
		end
		return theta
	end
end

#math = MathFunc.new()
#vr,vt,vp = math.polarConversionVector([1.0,1.0,0.0])
#puts math.convertVector([0,0,1])
