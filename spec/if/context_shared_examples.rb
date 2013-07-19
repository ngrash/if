module ContextHelper
  def object_context(id)
    object = @story.get_object(id)
    fail "No such object: '#{id}'" unless object
    @story.get_context(object)
  end

  def room_context(id)
    room = @story.get_room(id)
    fail "No such room: '#{id}'" unless room
    @story.get_context(room)
  end
  
  def new_story
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
            is :locked
            object :money, "Money"
          end
        end
      end
    end
  end
end

shared_examples "context" do
  include ContextHelper

  before :each do
    @story = new_story
  end
  
  it "sets story" do
    story = IF::Story.new
    context = IF::Context.new(story, IF::Object.new(:foo, "Foo"))
    context._story.should be story
  end
  
  it "writes through story" do
    @story.should_receive(:write).once do |text|
      text.should eq "foo"
    end
    
    safe = object_context :safe
    safe.write "foo"
  end
  
  it "returns nil when room not found" do
    key = object_context :key
    key.room(:foobar).should be_nil
  end
  
  it "returns nil when object not fount" do
    key = object_context :key
    key.object(:foobar).should be_nil
  end
  
  it "can get object context by id" do
    picture = object_context :picture
    key = object_context :key
    
    picture.object(:key).should be key
  end
  
  it "can get player context" do
    key = object_context :key
    player = @story.get_context(@story.player)
    
    key.player.should be player
  end
end