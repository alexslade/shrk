require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Shrk" do
  
  before(:all) do
    Shrk.blog = "mock"
    FakeWeb.register_uri(:get, %r|http://mock.tumblr.com/api/read|, :response => "/Stuff/Work/Dropbox/Code/shrk/spec/tumblr_posts.xml")
  end
  
  describe '.count' do
    specify { Shrk.count.should == 3 }
  end
  
  describe '.pull' do
    
    before(:all) do
      @post_count = 0
      Shrk.stubs(:create_or_update).runs{@post_count += 1}      
      Shrk.stubs(:count).returns{@post_count}
    end
    
    before(:each) do
      @post_count = 0
    end

    it 'should start with no posts' do
      Shrk.count.should == 0
    end
      
    it 'should end up with posts' do  
      Shrk.pull  
      Shrk.count.should == 3 
    end
    
  end
  
  describe ".check" do
    
    before(:each) do
      @delete_calls = 0
      Shrk.stubs(:delete).runs{@delete_calls += 1}
    end
    
    it "should check and keep a post" do
      post = mock()
      post.expects(:tumblr_id).returns(123)
      FakeWeb.register_uri(:get, "http://mock.tumblr.com/api/read?id=123", :response => "/Stuff/Work/Dropbox/Code/shrk/spec/tumblr_post.xml")
      
      Shrk.check(post)
      @delete_calls.should == 0
    end
    
    it "should check and call to remove a post" do
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
      lambda {Shrk.check(post)}.should raise_error(Tumblr::ServiceUnavailable)
    end
        
  end
  
end
