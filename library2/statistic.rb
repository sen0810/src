=begin
= Statistic
==Index
* ((<module Statistic>))
  * ((<rcov_population>))
  * ((<rcov>))
  * ((<rcor>))
  * ((<student_test>))
  * ((<significance_level>))

=module Statistic
    statistic functions made by eriko.
    in /home/eriko/lib/ruby/1.8

==Module Functions
---rcov_population(fx, fy) => cov
    母共分散を返す

    ARGUMENTS
    * fx : Array or NArray
    * fy : Array or NArray
    * cov: Real, 共分散

---rcov(fx, fy) => cov
    標本共分散を返す

    ARGUMENTS
    * fx : Array or NArray
    * fy : Array or NArray
    * cov: Real, 共分散

---rcor(fx, fy) => a,b,r
    相関解析を行なう. 

    ARGUMENTS
    * fx : Array or NArray
    * fy : Array or NArray
    * a  : Real
    * b  : Real
      * y = a*x + b
    * r  : Real, 相関係数

---student_test(rcor,n,p=0.05) => t0,st,state
    t検定を行なう. 

    ARGUMENTS
    * rcor : 相関係数
    * n : データ数
    * p : 有意水準(default 0.05)
    * t0 : 相関係数rcor, データ数nでのt値
    * st : 自由度n-2, 危険率pでのt値
    * state : |t0|>=st で有意だった場合true, |t0|<st で有意ではなかった場合false

---significance_level(n,p=0.05) => rcor
    ある標本数において有意水準を満す相関係数を求める

    ARGUMENTS
    * n : データ数
    * p : 有意水準(default 0.05)
    * rcor : 相関係数
=end

require 'narray'
require 'gsl'
module Statistic

  module_function

  #<<< population covariance >>>
  def rcov_population(x,y)
    if !x.is_a?(NArray)
      if !x.is_a?(Array)
        raise 'array must be NArray or Array'
      end
    end
    if !y.is_a?(NArray)
      if !y.is_a?(Array)
        raise 'array must be NArray or Array'
      end
    end
    if x.length != y.length
      raise 'Must be same length'
    end

    cov = (x*y).mean - (x.mean)*(y.mean)
    return cov
  end

  #<<< sample covariance >>>
  def rcov(x,y)
    if !x.is_a?(NArray)
      if !x.is_a?(Array)
        raise 'array must be NArray or Array'
      end
    end
    if !y.is_a?(NArray)
      if !y.is_a?(Array)
        raise 'array must be NArray or Array'
      end
    end
    if x.length != y.length
      raise 'Must be same length'
    end

    cov = NMath::covariance(x,y)
    return cov
  end

  #<<< linear regression analysis >>>
  def rcor(x,y)
    if !x.is_a?(NArray)
      if !x.is_a?(Array)
        raise 'array must be NArray or Array'
      end
    end
    if !y.is_a?(NArray)
      if !y.is_a?(Array)
        raise 'array must be NArray or Array'
      end
    end

    sxy = NMath::covariance(x,y)
    sx2 = NMath::covariance(x,x)
    sy2 = NMath::covariance(y,y)

    #-- y = a*x + b
    a = sxy/sx2
    b = y.mean - a * x.mean
    r = sxy/(sqrt(sx2) * sqrt(sy2))
    
    return a,b,r
  end

  #<<< student t test >>>
  # t検定を行なう
  def student_test(rcor,n,p=0.05)
    nu=n-2
    t0 = (rcor*Math::sqrt(nu/(1.0-rcor*rcor))).abs
    st = GSL::Cdf.tdist_Qinv(p/2.0,nu)

    if t0>=st
      state = true
    else
      state = false
    end

    return t0,st,state
  end

  #<<< significance level >>>
  # 標本数nに対して有意水準pを満す相関係数を求める
  def significance_level(n,p=0.05)
    nu=n-2
    st = GSL::Cdf.tdist_Qinv(p/2.0,nu)
    r = st/Math::sqrt(nu+st**2)

    return r
  end

end
