require "spec_helper"

describe IF::ObjectContext do
  it_behaves_like "context"
  
  include ContextHelper
  
  before :each do
    new_story
  end
  
  it "can query type" do
    carpet = object_context :safe
    carpet.is?(:locked).should be_true
  end
  
  describe "#room" do
    it "return nil if parent is nil" do
      carpet = object_context :carpet
      carpet._entity.move_to nil
      carpet._entity.parent.should be nil
      carpet.room.should be nil
    end
  end
  
  describe "#moved?" do
    it "works when object was moved before context was created" do
      money = @story.get_object :money
      hall = @story.get_room :hall
      money.move_to hall
      money_context = object_context :money
      money_context.moved?.should be_true
    end
    
    it "returns false when entity not moved" do
      money = object_context :money
      money.moved?.should be_false
    end
    
    it "returns true when entity moved" do
      money = object_context :money
      money.move_to :hall
      money.moved?.should be_true
    end
  end
  
  it "can get room context" do
    carpet = object_context :carpet
    hall = room_context :hall
    
    carpet.room.should be hall
  end
  
  it "can get parent context" do
    money = object_context :money
    safe = object_context :safe
    
    money.parent.should be safe
  end
  
  it "can get room context by id" do
    trash = object_context :trash
    hall = room_context :hall
    
    trash.room(:hall).should be hall
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
  
  it "can check for parent object by id (in?)" do
    money = object_context :money
    
    money.in?(:safe).should be_true
  end
  
  it "can check for parent object by context (in?)" do
    money = object_context :money
    safe = object_context :safe
    money.in?(safe).should be_true
  end
  
  it "can check for parent room by id (in?)" do
    carpet = object_context :carpet
    
    carpet.in?(:hall).should be_true
  end
  
  it "can check for parent room by context (in?)" do
    carpet = object_context :carpet
    hall = room_context :hall
    
    carpet.in?(hall).should be_true
  end
  
  it "can check for parent object by id recursively (within?)" do
    key = object_context :key
    
    key.within?(:trash_bin).should be_true
  end
  
  it "can check for parent object by context recursively (within?)" do
    key = object_context :key
    bin = object_context :trash_bin
    
    key.within?(bin).should be_true
  end
  
  it "can check for parent room by id recursively (within?)" do
    money = object_context :money
    money.within?(:hall).should be_true
  end
  
  it "can check for parent room by context recursively (within?)" do
    money = object_context :money
    hall = room_context :hall
    
    money.within?(hall).should be_true
  end
end