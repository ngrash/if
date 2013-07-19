require "spec_helper"

TYPE_ID = :foo

def new_type(id=TYPE_ID, &block)
  IF::Type.new(id, &block)
end

describe IF::Type do
  context "when creating" do
    it "requires one argument" do
      expect { IF::Type.new }.to raise_error ArgumentError, /0 for 1/
    end
  end
  
  context "when created" do
    its "actions" do
      new_type.actions.should be_nil
    end
    
    it "sets id" do
      new_type.id.should eq TYPE_ID
    end
  end
  
  context "when created with block" do
    it "sets actions" do
      type = new_type do
        actions do
          def foo; end
        end
      end
      
      type.actions.should be
      object = ::Object.new
      object.instance_eval &type.actions
      object.should respond_to :foo
    end
  end
end