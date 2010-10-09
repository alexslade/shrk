require 'rubygems'
require 'tumblr'

module Shrk
  
  class << self
    attr_accessor :blog
  end
  
  def self.pull
    raise "No blog specified" unless blog
    Tumblr.blog = blog
    Tumblr::Post.all.each do |post|
      create_or_update(post) if post["type"] == 'regular'     
    end
  end
  
  def self.count
    Tumblr.blog = blog
    Tumblr::Post.count
  end
  
  def self.create_or_update(post)
    id = post["id"]
    p = Post.find_or_initialize_by(:tumblr_id => id)
    p.title = post["regular_title"]
    p.body = post["regular_body"].split("<!-- more -->")[0]
    p.url = post["url_with_slug"]
    p.created_at = Time.at(post["unix_timestamp"].to_i)
    puts p.save
  end 
  
  
end