require "spec_helper"

def new_story(config=nil, &block)
  IF::Story.new(config, &block)
end

describe IF::Story do
  it "handles closure" do
    s1 = nil
    s2 = new_story do |s|
      s1 = s
    end
    s1.should be s2
  end

  context "when creating" do
    it "requires no arguments" do
      expect { IF::Story.new }.not_to raise_error
    end
  end

  context "when created" do
    its "#rooms" do
      new_story.rooms.should be_empty
    end
    its "#verbs" do
      new_story.rooms.should be_empty
    end
  end
  
  context "when created with config hash" do
    it "sets rooms" do
      rooms = [IF::Room.new(:foo, "foo")]
      story = new_story rooms: rooms
      story.rooms.should eq rooms
    end
    
    it "sets verbs"
  end
  
  context "when created with block" do
    it "adds rooms" do
      story = new_story do
        room :foo, "foo"
        room :bar, "bar"
      end
      
      story.rooms.count.should eq 2
      story.rooms[0].id.should eq :foo
      story.rooms[1].id.should eq :bar
    end
    
    it "adds verb"
  end
end