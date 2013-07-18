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
  
  context "when creating" do
    it "requires two arguments" do
      expect { IF::Object.new }.to raise_error ArgumentError, /0 for 2/
    end
  end
  
  context "when created with config hash" do
    it "sets types" do
      types = [:foo, :bar]
      object = new_object types: types
      object.is?(:foo).should be_true
      object.is?(:bar).should be_true
    end
    
    it "defines actions" do
      object = new_object actions: lambda { |_| def action; end }
      object.context.should respond_to :action
    end
  end
  
  context "when created with block" do
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
      object.context.should respond_to :action
    end
    
    it "defines actions by string" do
      object = new_object do
        action "take" do |obj|; end
      end
      object.context.should respond_to "take"
      object.context.method("take").arity.should eq 1
    end
    
    it "defines actions by symbol" do
      object = new_object do
        action :take do |obj|; end
      end
      object.context.should respond_to :take
      object.context.method(:take).arity.should eq 1
    end
    
    it "replaces spaces by underscore when defining actions by string" do
      object = new_object do
        action "remove from" do; end
      end
      object.context.should respond_to :remove_from
      object.context.method(:remove_from).arity.should eq 0
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