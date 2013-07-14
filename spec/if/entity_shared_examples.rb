ENTITY_ID = :my_entity
ENTITY_NAME = "My Entity"

shared_examples "entity" do

  def get_names(*names)
    [ENTITY_NAME, *names]
  end

  it "can set description" do
    entity = new_entity
    entity.description = "fizzbuzz"
    entity.description.should eq "fizzbuzz"
  end
  
  it "can set parent" do
    parent = new_entity
    child = new_entity
    child.parent = parent
    child.parent.should be parent
  end
  
  it "handles closure" do
    e1 = nil
    e2 = new_entity do |e|
      e1 = e
    end
    e1.should be e2
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
    
    its "#parent" do
      @entity.parent.should be_nil
    end
    
    its "#names" do
      @entity.names.should eq get_names
    end
    
    its "#description" do
      @entity.description.should be_nil
    end
    
    its "#objects" do
      @entity.objects.should be_empty
    end
  end
  
  context "when created with config hash" do
    before do
      @entity = new_entity :names => ["foo", "bar", "baz"], :description => "fizzbuzz"
    end
  
    it "sets parent" do
      parent = new_entity
      child = new_entity parent: parent
      child.parent.should be parent
    end
  
    it "moves itself to parent" do
      parent = new_entity
      child = new_entity parent: parent
      parent.objects.should include child
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
    
    it "sets objects" do
      child = new_entity
      parent = new_entity objects: [child]
      parent.objects.should include child
    end
    
    it "sets self as parent for objects" do
      child = new_entity
      parent = new_entity objects: [child]
      parent.objects.first.parent.should be parent
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
  
  context "when created with block" do
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
    
    it "adding object sets its parent" do
      entity = new_entity do
        object "foo", :foo do
        end
      end
      
      entity.objects.count.should eq 1
      entity.objects.first.parent.should be entity
    end
    
    it "can add objects" do
      entity = new_entity do
        object "foo", :foo do
        end
      end
      entity.objects.count.should eq 1
      entity.objects.should include { |obj| obj.id == :foo }
    end
  end
  
  context "when moving" do
    before :each do
      @e1 = new_entity
      @e2 = new_entity
      @e3 = new_entity
      
      @e1.parent = @e2
      @e2.objects << @e1
    end
  
    it "removes itself from its former parent" do
      @e2.objects.should include @e1
      @e1.move_to @e3
      @e2.objects.should_not include @e1
    end
    
    it "adds itself to the new parent" do
      @e1.move_to @e3
      @e3.objects.should include @e1
    end
    
    it "updates parent" do
      @e1.move_to @e3
      @e1.parent.should be @e3
    end
    
    it "can move to nil" do
      @e1.move_to nil
      @e1.parent.should be_nil
      @e2.objects.should be_empty
    end
  end
end