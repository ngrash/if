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

  it "validates id uniqueness" do
    expect do
      story = new_story do
        room :room, "Room 1"
        room :room, "Room 2"
      end
    end.to raise_error
  end
  
  it "injects self in all contexts" do
    story = new_story do
      room :room1, "Room 1" do
        object :obj1, "Object 1" do
          object :obj1_1, "Object 1.1"
        end
      end
      room :room2, "Room 2"
    end
    
    story.room(:room1).context._story.should be story
    story.object(:obj1).context._story.should be story
    story.object(:obj1_1).context._story.should be story
    story.room(:room2).context._story.should be story
  end
  
  it "can get object by id" do
    story = new_story do
      room :room, "Room" do
        object :obj1, "Obj1"
      end
    end
    
    obj = story.get_object(:obj1) 
    obj.id.should eq :obj1
    obj.name.should eq "Obj1"
  end
  
  it "can get room by id" do
    story = new_story do
      room :room, "Room"
    end
    
    room = story.get_room(:room)
    room.id.should eq :room
    room.name.should eq "Room"
  end
  
  it "can get all objects" do
    story = new_story do
      room :foo, "foo" do
        object :obj1, "obj1"
        object :obj2, "obj2" do
          object :obj2_1, "obj2_1"
        end
      end
      room :bar, "bar" do
        object :obj3, "obj3"
      end
    end

    objects = story.objects
    objects.should be
    objects.map { |o| o.id }.should eq [:obj1, :obj2, :obj2_1, :obj3]
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
    its "#player" do
      new_story.player.should be
    end
  end
  
  context "when created with config hash" do
    it "sets rooms" do
      rooms = [IF::Room.new(:foo, "foo")]
      story = new_story rooms: rooms
      story.rooms.should eq rooms
    end
    
    it "sets verbs" do
      verbs = [IF::Verb.new("foo")]
      story = new_story verbs: verbs
      story.verbs.should eq verbs
    end
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
    
    it "adds verb" do
      story = new_story do
        verb "foo"
        verb "bar"
      end
      
      story.verbs.count.should eq 2
      story.verbs[0].names.should eq ["foo"]
      story.verbs[1].names.should eq ["bar"]
    end
  end
end