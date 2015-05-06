# encoding: utf-8

class FFT
	def initialize(windowWidth,slideWidth,windowName)
		@windowWidth = windowWidth
    @slideWidth = slideWidth
    @samplingFreqency = 100
    @windowName = windowName
	end
  attr_accessor :windowName
  attr_accessor :slideWidth
  attr_accessor :windowWidth
  attr_reader :samplingFreqency
  #dataの形式:[time,value]

  def fourieTrans(data)
    result = []
    if(@slideWidth == 0) then
      result = fourietrans(data)
    else
      result = fourieTransVerSlide(data)
    end
    return result
  end

  def main()
    result = fourieTransVerSlide(data)
  end

  private
  def getMean(array)
  	temp = []
  	for i in 0..array.size()-1 do
  		temp[temp.size()] = array[i]
  	end
  	return temp.inject(0.0){|r,n| r+=n }/temp.size
  end

  def fft(data)
    n = data.size()
    output = []
    if(n == 1) then
      output = data
    elsif (n%2 != 0) then
      return nil
    else
      even = []
      for k in 1 .. n/2 do
        even[k-1] = data[2*(k-1)]
      end
      q = fft(even)
      odd = []
      for k in 1 .. n/2 do
        odd[k-1] = data[2*(k-1) + 1]
      end
      r = fft(odd)
      for k in 1 .. n/2 do
        kth = -2*(k-1)*Math::PI/n
        wk = [Math.cos(kth),Math.sin(kth)]
        rm = wk[0]*r[k-1][0] - wk[1]*r[k-1][1]
        im = wk[0]*r[k-1][1] + wk[1]*r[k-1][0]
        output[k-1] = [q[k-1][0]+rm,q[k-1][1]+im]
        output[k-1 + n/2] = [q[k-1][0]-rm,q[k-1][1]-im]
      end
    end
    return output
  end

  def fourietrans(data)
    n = 0
    result = []
    values = []
    leng = data.size()-1
    fMean = []
    while n < leng do
      values[values.size()] = data[n][1]
      if(n > 0) then
        fMean[fMean.size()] = data[n][0] - data[n-1][0]
      end
      if(values.size() == @windowWidth) then
        result[result.size()] = fft(hammingWindow(values,n%leng))
        values = []
      end
      n+=1
    end
    @samplingFreqency = 1/getMean(fMean)
    return result
  end

  def fourieTransVerSlide(data)
  	n = 0
  	result = []
  	values = []
  	leng = data.size()-1
  	fMean = []
  	while n < leng do
  		values[values.size()] = data[n][1]
  		if(n > 0) then
  			fMean[fMean.size()] = data[n][0] - data[n-1][0]
  		end
  		if(values.size() == @windowWidth) then
        math = MathFunc.new()
        array = math.thresholdFilter(values,1.6)
  			if(@windowName == "hm") then
  				result[result.size()] = fft(hammingWindow(array,n%leng))
  			elsif (@windowName == "bl") then
  				result[result.size()] = fft(BlackmanWindow(array,n%leng))
  			elsif(@windowName == "bh") then
  				result[result.size()] = fft(BartlettHannWindow(array,n%leng))
  			else
  				result[result.size()] = fft(rectangularWindow(array,n%leng))
  			end
  			temp = []
  			for i in @slideWidth .. (@windowWidth-1) do
  				temp[temp.size()] = values[i]
  			end
  			values = temp
  		end
  		n+=1
  	end
    @samplingFreqency = 1/getMean(fMean)
  	#puts  "sampling frequency:#{@samplingFreqency}Hz"
  	return result
  end
  #窓関数
  def hammingWindow(input,index)
  	mean = getMean(input)
  	n = input.size()
  	output = []
  	newValue = []
  	for m in 0 .. n-1 do
  		#l = (m+index)%n
  		theta = 2.0*Math::PI*m/(n - 1)
  		val = 0.54 - 0.46*Math.cos(theta)
  		newValue[m] = [(input[m]-mean)*val,0]
  	end
  	return newValue
  end

  def rectangularWindow(input,index)
  	mean = getMean(input)
  	n = input.size()
  	newValue = []
  	for m in 0 .. n-1 do
  		l = (m+index)%n
  		newValue[m] = [input[l]-mean,0]
  	end
  	return newValue
  end

  def BartlettHannWindow(input,index)
  	mean = getMean(input)
  	n = input.size()
  	output = []
  	newValue = []
  	for m in 0 .. n-1 do
  		l = (m+index)%n
  		x = m.to_f/(n - 1)
  		val = 0.62 - 0.48*(x - 0.5).abs - 0.38*Math.cos(2.0*Math::PI*x)
  		newValue[m] = [(input[l]-mean)*val,0]
  	end
  	return newValue
  end

  def BlackmanWindow(input,index)
  	mean = getMean(input)
  	n = input.size()
  	output = []
  	newValue = []
  	for m in 0 .. n-1 do
  		l = (m+index)%n
  		theta = 2.0*Math::PI*m/(n - 1)
  		val = 0.42 - 0.5*Math.cos(theta) + 0.08*Math.cos(theta*2)
  		newValue[m] = [(input[l]-mean)*val,0]
  	end
  	return newValue
  end
end
