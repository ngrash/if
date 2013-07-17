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
end