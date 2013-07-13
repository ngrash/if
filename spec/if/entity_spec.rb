require "spec_helper"

ENTITY_ID = :my_entity
ENTITY_NAME = "My Entity"

def new_entity(config=nil, &block)
  IF::Entity.new(ENTITY_ID, ENTITY_NAME, config, &block)
end

def get_names(*names)
  [ENTITY_NAME, *names]
end

describe IF::Entity do
  context "when creating" do
    it "raises ArgumentError with less than 2 parameters" do
      expect {
        IF::Entity.new
      }.to raise_error ArgumentError, /0 for 2/
    end
  end

  context "when created" do
    before do
      @entity = new_entity
    end
  
    it "sets id" do
      @entity.id.should eq ENTITY_ID
    end
    
    it "sets name" do
      @entity.name.should eq ENTITY_NAME
    end
    
    its "#names contains only #name" do
      @entity.names.should eq get_names
    end
    
    its "#description is nil" do
      @entity.description.should be_nil
    end
    
    its "#objects is empty" do
      @entity.objects.should be_empty
    end
  end
  
  context "when created using block" do
    before do
      @entity = new_entity do
        names "foo", "bar", "baz"
        description "fizzbuzz"
      end
    end
  
    it "sets names" do
      @entity.names.should eq get_names("foo", "bar", "baz")
    end
    
    it "sets description" do
      @entity.description.should eq "fizzbuzz"
    end
    
    it "adds names" do
      entity = new_entity do
        names "foo", "bar"
        names "baz"
      end
      entity.names.should eq get_names("foo", "bar", "baz")
    end
    
    it "ignores duplicate names" do
      entity = new_entity do
        names "foo", "bar"
        names "foo"
      end
      entity.names.should eq get_names("foo", "bar")
    end
    
    it "adds descriptions with newline" do
      entity = new_entity do
        description "fizz"
        description "buzz"
      end
      entity.description.should eq "fizz\nbuzz"
    end
  end
  
  context "when created with config hash" do
    before do
      @entity = new_entity :names => ["foo", "bar", "baz"], :description => "fizzbuzz"
    end
  
    it "sets names" do
      @entity.names.should eq get_names("foo", "bar", "baz")
    end
    
    it "ignores duplicate names" do
      entity = new_entity :names => ["foo", "foo", "bar"]
      entity.names.should eq get_names("foo", "bar")
    end
    
    it "sets description" do
      @entity.description.should eq "fizzbuzz"
    end
    
    it "does not overwrite name" do
      entity = new_entity :name => "foo"
      entity.name.should eq ENTITY_NAME
    end
    
    it "does not overwrite id" do
      entity = new_entity :id => :foo
      entity.id.should eq ENTITY_ID
    end
  end
  
  it "handles closure" do
    description = "fizzbuzz"
    entity = new_entity do |e|
      e.description = description
    end
    entity.description.should eq description
  end
end