require "spec_helper"

def validate_match(match, options={})
  match.should be
  match.verb.should eq options[:verb] if options[:verb]
  match.proc.should be if options[:arity]
  match.proc.arity.should eq options[:arity]
  match.args.should eq options[:args] || []
end

describe IF::Verb do
  it "handles closure" do
    v1 = nil
    v2 = IF::Verb.new do |v|
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
  
  it "finds complete match" do
    verb = IF::Verb.new "open" do
      alone do
      end
    
      with :object do |obj|
      end
    end
    
    object = IF::Object.new(:thing, "box")
    matcher = verb.get_matcher objects: [object]
    match = matcher.match "open box"
    validate_match match, verb: "open", arity: 1, args: [object]
  end
  
  it "can match object" do
    verb = IF::Verb.new "take" do
      with :object do |obj|
      end
    end
    
    object = IF::Object.new(:thing, "thing")
 
    matcher = verb.get_matcher objects: [object]
 
    match = matcher.match "take thing"
    validate_match match, verb: "take", arity: 1, args: [object]
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
    validate_match match, verb: "connect", arity: 2, args: [object1, object2]
  end
  
  it "can match rooms" do
    verb = IF::Verb.new "go" do
      with "to", :room do |room|
      end
    end
    
    room = IF::Room.new :place, "place"
    
    matcher = verb.get_matcher rooms: [room]
    match = matcher.match "go to place"
    validate_match match, verb: "go", arity: 1, args: [room]
  end
  
  it "can match any type" do
    verb = IF::Verb.new "open" do
      with :container do |container|
      end
    end
    
    box = IF::Object.new :box, "box" do
      is :container
    end
    
    matcher = verb.get_matcher objects: [box]
    match = matcher.match "open box"
    validate_match match, verb: "open", arity: 1, args: [box]
  end
  
  it "only matches objects of specified type" do
    verb = IF::Verb.new "open" do
      with :container do |container|
      end
    end
    
    box = IF::Object.new :box, "box" do
      is :container
    end
    
    chest = IF::Object.new :chest, "chest" do
      is :container
    end
    
    spoon = IF::Object.new :spoon, "spoon"
    
    matcher = verb.get_matcher objects: [box, chest, spoon]
    
    match1 = matcher.match "open box"
    validate_match match1, verb: "open", arity: 1, args: [box]
    
    match2 = matcher.match "open chest"
    validate_match match2, verb: "open", arity: 1, args: [chest]
    
    match3 = matcher.match "open spoon"
    match3.should be_nil
  end

  it "requires a block for #with" do
    verb = IF::Verb.new "foo"
    expect { verb.with :object }.to raise_error
  end
  
  it "requires one argument for #with" do
    verb = IF::Verb.new "foo"
    expect { verb.with {} }.to raise_error
  end
  
  it "matches alone" do
    proc = lambda {}
    verb = IF::Verb.new "foo"
    verb.alone &proc
    
    matcher = verb.get_matcher
    match = matcher.match "foo"
    validate_match match, verb: "foo", arity: 0
  end
  
  it "matches all entity names" do
    verb = IF::Verb.new "foo" do
      with :object do |obj|
      end
    end
    
    object = IF::Object.new :obj, "bar", names: ["baz"]
    
    matcher = verb.get_matcher objects: [object]
    
    match1 = matcher.match "foo bar"
    validate_match match1, verb: "foo", arity: 1, args: [object]
    
    match2 = matcher.match "foo baz"
    validate_match match2, verb: "foo", arity: 1, args: [object]
  end

  it "matches all verb names" do
    verb = IF::Verb.new "foo", "bar" do
      with :object do |obj|
      end
    end
    
    object = IF::Object.new :obj, "baz"
    
    matcher = verb.get_matcher objects: [object]
    
    match1 = matcher.match "foo baz"
    validate_match match1, verb: "foo", arity: 1, args: [object]
    
    match2 = matcher.match "bar baz"
    validate_match match2, verb: "bar", arity: 1, args: [object]
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