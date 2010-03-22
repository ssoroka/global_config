require File.join(File.dirname(__FILE__), 'spec_helper')

describe GlobalConfig do
  before(:each) do
    ActiveRecord::Base.send(:class_variable_set, "@@records", [])
  end

  describe 'with caching' do
    before(:each) do
      # hijack cache for this test. 
      # ActionController::Base.perform_caching = true
      Rails.reset_cache
    end
    
    it "should hit the database if the cache misses" do
      GlobalConfig.should_receive(:record_for_key)#.and_return(mock(:global_config, :try => 'from db'))
      GlobalConfig.something#.should == 'from db'
    end
    
    it "should not hit the database if the cache hits" do
      GlobalConfig.admin_email = 'me@thisdomain.com'
      GlobalConfig.admin_email # hit cache
      
      GlobalConfig.should_not_receive(:record_for_key)
      GlobalConfig.admin_email.should == 'me@thisdomain.com'
    end
    
    it "should cache values on assignment" do
      GlobalConfig.cache_me = 'adf'

      GlobalConfig.should_not_receive(:record_for_key)
      GlobalConfig.cache_me.should == 'adf'
    end
    
    it "should not disable double assignment" do
      GlobalConfig.double = 'blah blah'
      GlobalConfig.double = 'something else'
      GlobalConfig.double.should == 'something else'
    end
    
    after(:each) do
      # test env typically doesn't like caching.
      # ActionController::Base.perform_caching = false
    end
  end
  
  describe 'without caching' do
    it "should store and retrieve values" do
      GlobalConfig.email_address = 'test@example.com'
      GlobalConfig.email_address.should == 'test@example.com'
    end

    it "get should find record value" do
      GlobalConfig.create!(:key => 'test', :value => 'value')
      GlobalConfig.test.should == 'value'
    end

    it "set should change the value of an existing record" do
      GlobalConfig.create!(:key => 'test', :value => 'value'.to_yaml)
      GlobalConfig.set('test', 'new value')
      GlobalConfig.first(:conditions => ['key = ?', 'test']).value.should == 'new value'.to_yaml
    end

    it "set should create a new record with value when none exists" do
      GlobalConfig.set('test', 'new value')
      GlobalConfig.first(:conditions => ['key = ?', 'test']).value.should == 'new value'.to_yaml
    end

    it "should save and retrieve fixnums" do
      GlobalConfig.a_fixnum = 235
      GlobalConfig.a_fixnum.should == 235
    end

    it "should save and retrieve strings" do
      GlobalConfig.some_string = 'golf'
      GlobalConfig.some_string.should == 'golf'
    end

    it "should save and retrieve floats" do
      GlobalConfig.buffalo_avg = 213.234
      GlobalConfig.buffalo_avg.should == 213.234
    end

    it "should save and retrieve booleans" do
      GlobalConfig.run_imaginary_task_in_production = true
      GlobalConfig.run_imaginary_task_in_production.should be_true
    end

    it "requests for missing keys should return nil" do
      GlobalConfig.some_unused_key.should be_nil
    end

    it "assigning twice should return the second value" do
      GlobalConfig.double = 'blah blah'
      GlobalConfig.double = 'something else'
      GlobalConfig.double.should == 'something else'
    end
    
  end
end