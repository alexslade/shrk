require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Shrk" do
  
  before(:all) do
    Shrk.blog = "mock"
  end
 
  describe '.count' do
    
    before(:each) do
      FakeWeb.clean_registry
    end
    
    it "should succeed given a good response" do
      FakeWeb.register_uri(:get, %r|http://mock.tumblr.com/api/read|, :response => "/Stuff/Work/Dropbox/Code/shrk/spec/tumblr_posts.xml")
      Shrk.count.should == 3
    end
    
    it "should throw an error given 'unavailable' response" do
      FakeWeb.register_uri(:get, %r|http://mock.tumblr.com/api/read|, :response => "/Stuff/Work/Dropbox/Code/shrk/spec/tumblr_503")
      lambda{Shrk.count}.should raise_error(Shrk::ServiceUnavailable)
    end
    
    it "should throw an error given '404' response" do
      FakeWeb.register_uri(:get, %r|http://mock.tumblr.com/api/read|, :response => "/Stuff/Work/Dropbox/Code/shrk/spec/tumblr_404")
      lambda{Shrk.count}.should raise_error(Shrk::NotFound)
    end
    
  end
  
  
  
  

  describe '.pull' do
    
    before do
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, %r|http://mock.tumblr.com/api/read|, :response => "/Stuff/Work/Dropbox/Code/shrk/spec/tumblr_posts.xml")
      
      @post_count = 0
      Shrk.stubs(:create_or_update).runs{@post_count += 1}
    end

    it "should start with no posts" do
      @post_count.should == 0
    end

    it "should end up with posts" do  
      Shrk.pull  
      @post_count.should == 3 
    end
    
  end
  
  describe ".check" do
    
    before(:each) do
      @delete_calls = 0
      Shrk.stubs(:delete).runs{@delete_calls += 1}
    end
    
    it "should keep an existing post" do
      post = mock()
      post.expects(:tumblr_id).returns(123)
      FakeWeb.register_uri(:get, "http://mock.tumblr.com/api/read?id=123", :response => "/Stuff/Work/Dropbox/Code/shrk/spec/tumblr_post.xml")
      
      Shrk.check(post)
      @delete_calls.should == 0
    end
    
    it "should call to remove a missing post" do
      post = mock()
      post.expects(:tumblr_id).returns(404)
      FakeWeb.register_uri(:get, "http://mock.tumblr.com/api/read?id=404", :response => "/Stuff/Work/Dropbox/Code/shrk/spec/tumblr_404")
      
      Shrk.check(post)
      @delete_calls.should == 1
    end
    
    it "should raise an error when tumblr is down" do      
      FakeWeb.register_uri(:get, "http://mock.tumblr.com/api/read?id=503", :response => "/Stuff/Work/Dropbox/Code/shrk/spec/tumblr_503")
      post = mock()
      post.expects(:tumblr_id).returns(503)
      lambda {Shrk.check(post)}.should raise_error(Shrk::ServiceUnavailable)
    end
        
  end

end
