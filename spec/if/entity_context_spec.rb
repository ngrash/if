require "spec_helper"

describe IF::EntityContext do
  it_behaves_like "context"
  
  include ContextHelper
  
  before :each do
    new_story
  end
  
  describe "#children" do
    it "returns all objects" do
      picture = object_context :picture
      picture.children.count.should eq 1
      picture.children.should eq [object_context(:safe)]
    end
  end
  
  describe "#objects" do
    it "returns empty array" do
      picture = object_context :picture
      picture.objects.should be_empty
    end
  end
  
  it "can get id" do
    key = object_context :key
    key.id.should eq :key
  end
  
  it "can get name" do
    envelope = object_context :envelope
    envelope.name.should eq "Envelope"
  end
  
  it "can get description" do
    key = object_context :key
    key.description.should eq "A safe key"
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
end