require "spec_helper"

describe IF::REPL do
  it "can load story from file"
  
  it "uses block to create story"
  
  it "can set input"
  it "can set output"
  
  context "when parsing verbs" do
    it "matches verb alone"
    it "matches verb with parameter"
  
    it "calls verb 'alone' block"
    it "calls verb 'with' block"
  end
end