require 'rubygems'
require 'tumblr'
require "bundler/setup"

class Tumblr
  
  class ServiceUnavailable    < TumblrError; end

  
  class Request
    def self.read(options = {})
      response = HTTParty.get("http://#{Tumblr::blog}/api/read", :query => options)
      return response unless self.raise_errors(response)
    end
  
  
  
    def self.raise_errors(response)
        if(response.is_a?(Hash))
          message = "#{response[:code]}: #{response[:body]}"
          code = response[:code].to_i
        else
          message = "#{response.code}: #{response.body}"
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
  end
end

module Shrk
  
  class << self
    attr_accessor :blog
  end
  
  def self.pull
    raise "No blog specified" unless blog
    Tumblr.blog = blog
    posts = Tumblr::Post.all
    posts.each do |post|
      create_or_update(post)
    end
    return posts
  end
  
  def self.count
    Tumblr.blog = blog
    Tumblr::Post.count
  end
    
  def self.exists?(tumblr_id)
    raise ArgumentError.new("Only integers allowed") unless tumblr_id.class == Fixnum
    Tumblr.blog = blog
    Tumblr::Post.find(tumblr_id)
    return true
  rescue Tumblr::NotFound => e
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
  
end