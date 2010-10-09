require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Shrk" do
  
  
  
  
  describe '.count' do
    before do
      Tumblr::Post.expects(:count).returns(7)
    end
    specify { Shrk.count.should == 7 }
  end
  
  describe '.pull' do
    before(:each) do
      

      @post = mock()  
      @post_count = 0
      
      proc = Proc.new do
        @post_count += 1
      end
      
      @post.expects(:save).with(&proc)
      @post.expects(:title=)
      @post.expects(:body=)
      @post.expects(:url=)
      @post.expects(:created_at=)

      Post = mock('Post_class')
      Post.expects(:find_or_initialize_by).returns(@post)
      Shrk::Post = Post

      
      @posts = [{ "regular_title"=>"Test5", 
                  "regular_body"=>"<p>Test body</p>", 
                  "id"=>"1052035647", 
                  "url"=>"http://leanminded.tumblr.com/post/1052035647", 
                  "url_with_slug"=>"http://leanminded.tumblr.com/post/1052035647/another-test", 
                  "type"=>"regular", 
                  "date_gmt"=>"2010-09-02 06:29:37 GMT", 
                  "date"=>"Thu, 02 Sep 2010 02:29:37", 
                  "unix_timestamp"=>"1283408977", 
                  "format"=>"html", 
                  "reblog_key"=>"qAc9AhyN", 
                  "slug"=>"another-test"}]
      
      Tumblr::Post.expects(:all).returns(@posts)
      
    end
    
    
    it 'should have no posts before a pull' do
      @post_count.should == 0 #TODO: Fix this, it should be checking via Post.count, but the mocking doesn't work
    end
    
    it "should have 1 post after a pull" do
      Shrk.blog = "LeanMinded"
      Shrk.pull
      @post_count.should == 1 #TODO: Fix this, it should be checking via Post.count, but the mocking doesn't work
    end
    
  end
  
end
