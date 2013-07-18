require "spec_helper"

def new_info(config={}, &block)
  IF::StoryInfo.new(config, &block)
end

describe IF::StoryInfo do
  it "handles closure" do
    s1 = nil
    s2 = new_story do |s|
      s1 = s
    end
    s1.should be s2
  end

  context "when created" do
    its "#name" do
      new_info.name.should be_nil
    end
  
    its "#author" do
      new_info.author.should be_nil
    end
    
    its "#start" do
      new_info.start.should be_nil
    end
  end
  
  context "when created with block" do
    it "sets name" do
      info = new_info do
        name "foo"
      end
      info.name.should eq "foo"
    end
    
    it "sets author" do
      info = new_info do
        author "bar"
      end
      info.author.should eq "bar"
    end
    
    it "sets start" do
      info = new_info do
        start :baz
      end
      info.start.should eq :baz
    end
  end
  
  context "when created with config hash" do
    it "sets name" do
      info = new_info name: "foo"
      info.name.should eq "foo"
    end
    
    it "sets author" do
      info = new_info author: "bar"
      info.author.should eq "bar"
    end
    
    it "sets start" do
      info = new_info start: :baz
      info.start.should eq :baz
    end
  end
end