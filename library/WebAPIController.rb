# encoding: utf-8
require 'net/http'
require 'uri'
require 'json'

class WebAPIController
	def initialize(url)
		@url = url
    @uri = nil
		@response = nil
	end
  attr_accessor :url
  attr_accessor :uri
  def connect()
    #paramas = URI.encode_www_form({})
    @uri = URI.parse(@url)
    begin
      @response = Net::HTTP.start(@uri.host,@uri.port) do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get(@uri.request_uri)
			end
    end
		case @response
		when Net::HTTPSuccess
			puts "success"
		when Net::HTTPRedirection
		  puts("Redirection: code=#{response.code} message=#{response.message}")
		else
		  puts("HTTP ERROR: code=#{response.code} message=#{response.message}")
		end
  end

  def getBody()
    	return @response.body
  end

  def convertBodyToJson(body)
    return JSON.parse(body)
  end
end
