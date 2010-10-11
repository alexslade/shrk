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
            
      @post.stubs(:save).runs{@post_count += 1}
      @post.stubs(:title=)
      @post.stubs(:body=)
      @post.stubs(:url=)
      @post.stubs(:created_at=)
      
      Post = mock('Post_class')
      Post.stubs(:find_or_initialize_by).returns(@post)
      Post.stubs(:count).returns{@post_count}
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
                  "slug"=>"another-test"},
                  { "regular_title"=>"Test5", 
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
                  "slug"=>"another-test"}
                  ]
      
      Tumblr::Post.expects(:all).returns(@posts)
      
    end
    
    
    it 'should have no posts before a pull' do
      Post.count.should == 0 #TODO: Fix this, it should be checking via Post.count, but the mocking doesn't work
    end
    
    it "should have 1 post after a pull" do
      Shrk.blog = "LeanMinded"
      Shrk.pull
      Post.count.should == 2 #TODO: Fix this, it should be checking via Post.count, but the mocking doesn't work
    end
    
  end
  
end
