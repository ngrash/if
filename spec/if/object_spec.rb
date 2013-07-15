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
  
  context "when created" do
    its "#actions" do
      new_object.actions.should be
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
      object.actions.should respond_to :action
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
      object.actions.should respond_to :action
    end
  end
end