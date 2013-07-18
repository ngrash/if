require "spec_helper"

describe IF::Entity do
  def new_entity(config=nil, &block)
    IF::Entity.new(ENTITY_ID, ENTITY_NAME, config, &block)
  end

  it_behaves_like "entity"
  
  context "when creating" do
    it "requires two arguments" do
      expect { IF::Entity.new }.to raise_error ArgumentError, /0 for 2/
    end
  end
  
  context "when created with config hash" do
    it "sets context" do
      context = IF::Context.new(self)
      entity = new_entity context: context
      entity.context.should be context
    end
  end
end