require "spec_helper"

def new_object(config=nil, &block)
  IF::Object.new(ENTITY_ID, ENTITY_NAME, config, &block)
end

alias new_entity new_object

describe IF::Object do

  it_behaves_like "entity"

  it "can query types" do
    object = new_object types: [:foo, :bar]
    object.is?(:foo).should be_true
    object.is?(:bar).should be_true
  end
  
  describe "#moved?" do
    it "returns true when object was moved" do
      first_parent = new_object
      second_parent = new_object
      child = new_object parent: first_parent
      child.move_to second_parent
      child.should be_moved
    end
    
    it "returns false when object was not moved" do
      parent = new_object
      child = new_object parent: parent
      child.should_not be_moved
    end
  end
  
  context "when creating" do
    it "requires two arguments" do
      expect { IF::Object.new }.to raise_error ArgumentError, /0 for 2/
    end
  end
  
  context "when created" do
    its "#initial" do
      new_object.initial.should be_nil
    end
  end
  
  context "when created with config hash" do
    it "sets initial text" do
      object = new_object initial: "fizzbuzz"
      object.initial.should eq "fizzbuzz"
    end
    
    it "sets initial block" do
      object = new_object initial: lambda {}
      object.initial.class.should be Proc
    end
  
    it "sets types" do
      types = [:foo, :bar]
      object = new_object types: types
      object.is?(:foo).should be_true
      object.is?(:bar).should be_true
    end
    
    it "defines actions" do
      object = new_object actions: lambda { |_| def action; end }
      object.actions.should be
      context = ::Object.new
      context.instance_eval &object.actions
      context.should respond_to :action
    end
  end
  
  context "when created with block" do
    it "sets initial text" do
      object = new_object do
        initial "fizzbuzz"
      end
      object.initial.should eq "fizzbuzz"
    end
    
    it "sets initial block" do
      object = new_object do
        initial do
        end
      end
      object.initial.class.should be Proc
    end
  
    it "can set types" do
      object = new_object do
        is :foo, :bar
      end
      object.is?(:foo).should be_true
      object.is?(:bar).should be_true
    end
  
    it "adds types" do
      object = new_object do
        is :foo, :bar
        is :baz
      end
      object.is?(:foo).should be_true
      object.is?(:bar).should be_true
      object.is?(:baz).should be_true
    end
    
    it "defines actions" do
      object = new_object do
        actions do
          def action; end
        end
      end
      
      object.actions.should be
      context = ::Object.new
      context.instance_eval &object.actions
      context.should respond_to :action
    end
  end
  
  context "when moving" do
    before :each do
      @e1 = new_object
      @e2 = new_object
      @e3 = new_object
      
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