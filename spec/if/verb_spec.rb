require "spec_helper"

VERB_NAME = "do"

def new_verb(*names, &block)
  names << [VERB_NAME] if names.empty?
  IF::Verb.new(*names, &block)
end

describe IF::Verb do
  it "handles closure" do
    v1 = nil
    v2 = new_verb do |v|
      v1 = v
    end
    v1.should be v2
  end

  context "when creating" do
    it "accepts an array" do
      IF::Verb.new "foo", "bar", "baz"
    end
  end
  
  context "when created" do
    it "sets names" do
      verb = IF::Verb.new "foo", "bar"
      verb.names.should eq ["foo", "bar"]
    end
  end
  
  context "when created with block" do
    
  end
  
  it "can match object" do
    verb = IF::Verb.new "take" do
      with :object do |obj|
      end
    end
    
    object = IF::Object.new(:thing, "thing")
 
    matcher = verb.get_matcher objects: [object]
 
    match = matcher.match "take thing"
    match.should be
    match.verb.should eq "take"
    match.proc.should be
    match.proc.arity.should eq 1
    match.args.should eq [object]
  end
  
  it "can match two objects" do
    verb = IF::Verb.new "connect" do
      with :object, "and", :object do |obj1, obj2|
      end
    end
    
    object1 = IF::Object.new :obj1, "obj1"
    object2 = IF::Object.new :obj2, "obj2"
    
    matcher = verb.get_matcher objects: [object1, object2]
    match = matcher.match "connect obj1 and obj2"
    
    match.should be
    match.verb.should eq "connect"
    match.proc.should be
    match.proc.arity.should eq 2
    match.args.should eq [object1, object2]
  end
  
  it "matches all entity names" do
    verb = IF::Verb.new "foo" do
      with :object do |obj|
      end
    end
    
    object = IF::Object.new :obj, "bar", names: ["baz"]
    
    matcher = verb.get_matcher objects: [object]
    
    match1 = matcher.match "foo bar"
    match1.should be
    match1.verb.should eq "foo"
    match1.proc.should be
    match1.proc.arity.should eq 1
    match1.args.should eq [object]
    
    match2 = matcher.match "foo baz"
    match2.should be
    match2.verb.should eq "foo"
    match2.proc.should be
    match2.proc.arity.should eq 1
    match2.args.should eq [object]
  end

  it "matches all verb names" do
    verb = IF::Verb.new "foo", "bar" do
      with :object do |obj|
      end
    end
    
    object = IF::Object.new :obj, "baz"
    
    matcher = verb.get_matcher objects: [object]
    
    match1 = matcher.match "foo baz"
    match1.should be
    match1.verb.should eq "foo"
    match1.proc.should be
    match1.proc.arity.should eq 1
    match1.args.should eq [object]
    
    match2 = matcher.match "bar baz"
    match2.should be
    match2.verb.should eq "bar"
    match2.proc.should be
    match2.proc.arity.should eq 1
    match2.args.should eq [object]
  end
  
  it "match is nil when not matched" do
    verb = IF::Verb.new "foo" do
      with :object do |obj|
      end
    end
    
    object = IF::Object.new :obj, "baz"
    
    matcher = verb.get_matcher objects: [object]
    
    match = matcher.match "foo bar"
    match.should be_nil
  end
end