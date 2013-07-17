require "spec_helper"

describe IF::Context do
  before :each do
    @story = IF::Story.new do
      room :kitchen, "Kitchen" do
        object :trash_bin, "Trash Bin" do
          object :trash, "Trash"
          object :envelope, "Envelope" do
            object :letter, "Letter"
            object :key, "Key" do
              description "A safe key"
            end
          end
        end
      end
      room :hall, "Hall" do
        object :carpet, "Carpet"
        object :picture, "Picture" do
          object :safe, "Safe" do
            is :container
            object :money, "Money"
          end
        end
      end
    end
  end
  
  def object_context(id)
    @story.get_object(id).context
  end
  
  def room_context(id)
    @story.get_room(id).context
  end
  
  it "can query type" do
    carpet = object_context :safe
    carpet.is?(:container).should be_true
  end

  it "can get room context" do
    carpet = object_context :carpet
    hall = room_context :hall
    
    carpet.room.should be hall
  end
  
  it "returns nil when room not found" do
    key = object_context :key
    key.room(:foobar).should be_nil
  end
  
  it "returns nil when object not fount" do
    key = object_context :key
    key.object(:foobar).should be_nil
  end
  
  it "can get parent context" do
    money = object_context :money
    safe = object_context :safe
    
    money.parent.should be safe
  end
  
  it "can get player context" do
    key = object_context :key
    player = @story.player.context
    
    key.player.should be player
  end
  
  it "can get room context by id" do
    trash = object_context :trash
    hall = room_context :hall
    
    trash.room(:hall).should be hall
  end
  
  it "can get object context by id" do
    picture = object_context :picture
    key = object_context :key
    
    picture.object(:key).should be key
  end
  
  it "can get id" do
    key = object_context :key
    key.id.should eq :key
  end
  
  it "can get description" do
    key = object_context :key
    key.description.should eq "A safe key"
  end
  
  it "can get name" do
    envelope = object_context :envelope
    envelope.name.should eq "Envelope"
  end
  
  it "can move by id" do
    safe = object_context :safe
    safe.parent.should be object_context :picture
    safe.move_to :hall
    safe.parent.should be room_context :hall
  end
  
  it "can move by context" do
    money = object_context :money
    money.parent.should be object_context :safe
    money.move_to object_context :envelope
    money.parent.should be object_context :envelope
  end
  
  it "can check for contained object by id" do
    bin = object_context :trash_bin
    
    bin.contains?(:trash).should be_true
  end
  
  it "can check for contained object by context" do
    bin = object_context :trash_bin
    trash = object_context :trash
    
    bin.contains?(trash).should be_true
  end
  
  it "can check for parent object by id (in?)" do
    money = object_context :money
    
    money.in?(:safe).should be_true
  end
  
  it "can check for parent object by id recursively (within?)" do
    key = object_context :key
    
    key.within?(:trash_bin).should be_true
  end
  
  it "can check for parent object by context (in?)" do
    money = object_context :money
    safe = object_context :safe
    money.in?(safe).should be_true
  end
  
  it "can check for parent object by context recursively (within?)" do
    key = object_context :key
    bin = object_context :trash_bin
    
    key.within?(bin).should be_true
  end
  
  it "can check for parent room by id (in?)" do
    carpet = object_context :carpet
    
    carpet.in?(:hall).should be_true
  end
  
  it "can check for parent room by id recursively (within?)" do
    money = object_context :money
    
    money.within?(:hall).should be_true
  end
  
  it "can check for parent room by context (in?)" do
    carpet = object_context :carpet
    hall = room_context :hall
    
    carpet.in?(hall).should be_true
  end
  
  it "can check for parent room by context recursively (within?)" do
    money = object_context :money
    hall = room_context :hall
    
    money.within?(hall).should be_true
  end
  
  it "can write" do
    context = object_context :money
    context.should_receive(:puts).once do |text|
      text.should eq "fizzbuzz"
    end
    context.write "fizzbuzz"
  end
  
  it "can set #_story" do
    context = IF::Context.new(IF::Object.new(:foo, "Foo"))
    story = IF::Story.new
    context._story = story
    context._story.should be story
  end
end