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
  
  context "when creating context" do
    it "sets type actions" do
      story = new_story do
        type :type do
          actions do
            def foo; end
          end
        end
        room :room, "Room" do
          object :obj, "Object" do
            is :type
          end
        end
      end
      
      context = story.get_context(:obj)
      context.should respond_to :foo
    end
    
    it "sets object actions" do
      story = new_story do
        room :room, "Room" do
          object :obj, "Object" do
            actions do
              def foo; end
            end
          end
        end
      end
      
      context = story.get_context(:obj)
      context.should respond_to :foo    
    end
    
    it "lets object actions overwrite type actions" do
      story = new_story do
        type :type do
          actions do
            def foo
              :foo_from_type
            end
          end
        end
        room :room, "Room" do
          object :obj, "Object" do
            actions do
              def foo
                :foo_from_obj
              end
            end
          end
        end
      end
      
      context = story.get_context(:obj)
      context.should respond_to :foo
      context.foo.should eq :foo_from_obj
    end
  end
  
  it "validates type uniqueness" do
    expect do
      new_story do
        type :foo
        type :foo
      end
    end.to raise_error
  end
  
  it "validates type and object uniqueness" do
    expect do
      new_story do
        type :foo
        room :bar, "Bar" do
          object :foo, "Foo"
        end
      end
    end.to raise_error
  end
  
  it "validates type and room unqueness" do
    expect do
      new_story do
        type :foo
        room :foo, "Foo"
      end
    end.to raise_error
  end
  
  it "validates room id uniqueness" do
    expect do
      new_story do
        room :room, "Room 1"
        room :room, "Room 2"
      end
    end.to raise_error
  end
  
  it "validates object id uniqueness" do
    expect do
      new_story do
        room :room, "Room" do
          object :obj, "Object 1"
          object :obj, "Object 2"
        end
      end
    end.to raise_error
  end
  
  it "validates object id uniqueness accross rooms" do
    expect do
      new_story do
        room :room1, "Room 1" do
          object :obj, "Object 1"
        end
        room :room2, "Room 2" do
          object :obj, "Object 2"
        end
      end
    end.to raise_error
  end
  
  it "validates object and room id uniqueness" do
    expect do
      new_story do
        room :entity, "Room 1" do
          object :entity, "Object 1"
        end
      end
    end.to raise_error
  end
  
  it "places player in start room" do
    story = new_story do
      story do
        start :foo
      end
      
      room :foo, "Foo"
    end
    
    room = story.get_room(:foo)
    player = story.player
    player.parent.should be room
    
    player_context = story.get_context(player)
    room_context = story.get_context(room)
    player_context.room.should be room_context
  end
  
  it "returns nil when object not found" do
    story = new_story
    story.get_object(:foo).should be_nil
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
  
  it "returns nil when room not found" do
    story = new_story
    story.get_room(:foo).should be_nil
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
  
  it "can get context by entity" do
    story = new_story do
      room :foo, "Foo"
    end
    room = story.get_room(:foo)
    context = story.get_context(room)
    context.should be
    context._entity.should be room
  end
  
  it "can get context by id" do
    story = new_story do
      room :foo, "Foo"
    end
    room = story.get_room(:foo)
    context = story.get_context(:foo)
    context.should be
    context._entity.should be room
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
    its "#info" do
      new_story.info.should be
    end
  end
  
  context "when created with config hash" do
    it "sets info" do
      info = IF::StoryInfo.new name: "foo"
      story = new_story info: info
      story.info.name.should eq "foo"
    end
  
    it "sets types" do
      types = [IF::Type.new(:foo)]
      story = new_story types: types
      story.types.should eq types
    end
  
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
    
    it "sets output" do
      output = StringIO.new
      story = new_story(output: output)
      story.write "fizzbuzz"
      output.rewind
      output.read.should eq "fizzbuzz\n"
    end
  end
  
  context "when loaded from file" do
    STORY_FILE = "example_story.if"
    
    before do
      fail if File.exist? STORY_FILE
      File.open STORY_FILE, "w" do |file|
        file.write 'room :room, "Room"'
      end
    end
    
    after do
      File.delete STORY_FILE
    end
  
    it "can load from file" do
      story = IF::Story.load STORY_FILE
      story.rooms.count.should eq 1
      story.rooms.first.name.should eq "Room"
    end
  
    it "can set output" do
      output = StringIO.new
      story = IF::Story.load STORY_FILE, output: output
      story.write "fizzbuzz"
      output.rewind
      output.read.should eq "fizzbuzz\n"
    end
  end
  
  context "when created with block" do
    it "sets info" do
      story = new_story do
        story do
          name "foo"
        end
      end
      story.info.name.should eq "foo"
    end
    
    it "adds types" do
      story = new_story do
        type :foo
        type :bar
      end
      
      story.types.count.should eq 2
      story.types[0].id.should eq :foo
      story.types[1].id.should eq :bar
    end
  
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