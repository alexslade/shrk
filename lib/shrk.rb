require 'rubygems'
require "bundler/setup"
require 'httparty'

module Shrk
    
  class << self
    attr_accessor :blog
    def blog=(_blog)
      @blog = (_blog =~ /\./) ? _blog : "#{_blog}.tumblr.com"
    end
  end
  
  # tumblr errors
  class TumblrError < StandardError; end
  # tumblr 403 errors
  class Forbidden   < TumblrError; end
  # tumblr 400 errors
  class BadRequest  < TumblrError; end  
  # tumblr 404 errors
  class NotFound    < TumblrError; end
  # tumblr 503 errors
  class ServiceUnavailable < TumblrError; end
  
  
  def self.pull
    raise "No blog specified" unless blog
        
    posts = self.find_every({})
    posts.each do |post|
      create_or_update(post)
    end
    return posts
  end
  
  def self.count
    response = read("http://#{Shrk::blog}/api/read", {:num => 1})
    response["tumblr"]["posts"]["total"].to_i
  end
    
  def self.exists?(tumblr_id)
    raise ArgumentError.new("Only integers allowed") unless tumblr_id.class == Fixnum
    response = self.read("http://#{Shrk::blog}/api/read?id=#{tumblr_id}",{})
    response['tumblr']['posts']['post']
  
  rescue Shrk::NotFound => e
    return false
  end
  
  def self.check(post)
    delete(post) unless exists?(post.tumblr_id.to_i)
  end
  
  def self.create_or_update(post)
    raise "Tried to un #Shrk::create_or_update - Please define this method so it works with your DB"
  end
  
  def self.delete(post)
    raise "Tried to run #Shrk::delete - Please define this method so it works with your DB"
  end
  
  
  
  def self.read(adress, options)
    response = HTTParty.get(adress, options)
    return response unless raise_errors(response)
  end
  
  def self.raise_errors(response)
    if(response.is_a?(Hash))
      message = "#{response[:code]}\n\n#{response[:body]}"
      code = response[:code].to_i
    else
      message = "#{response.code}\n\n#{response.body}"
      code = response.code.to_i
    end
        
    case code
      when 403
        raise(Forbidden.new, message)
      when 400
        raise(BadRequest.new, message)
      when 404
        raise(NotFound.new, message)
      when 503
        raise(ServiceUnavailable.new, message)
      when 200
        return false
      when 201 
        return false
    end        
  end
  
  def self.find_every(options)
    amount = (self.count.to_f / 50).ceil
    options = {:num => 50}.merge(options)
    responses = []
    amount.times do |n|
      responses << HTTParty.get("http://#{Shrk::blog}/api/read", {:start => (n.to_i * 50)} )
      #puts options.merge({:start => (count.to_i * 50)}).to_yaml
    end
        
    response = {'tumblr' => {'posts' => {'post' => []}}}
    responses.each do |r|
      r['tumblr']['posts']['post'].each { | p | response['tumblr']['posts']['post'] << p }
    end
    
    #puts response['tumblr']['posts']['post'].length.to_yaml
    
    return [response['tumblr']['posts']['post']] unless(response['tumblr']['posts']['post'].is_a?(Array))  
    response['tumblr']['posts']['post']
  end
  
end