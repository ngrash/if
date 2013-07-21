require "spec_helper"

describe IF::REPL do
  context "when loading from file" do
    STORY_FILE = "story.if"
    
    before do
      File.open STORY_FILE, "w" do |file|
        file.write 'room :room, "Room"'
      end
    end
    
    after do
      File.delete STORY_FILE
    end
    
    it "loads story" do
      repl = IF::REPL.new file: STORY_FILE
      repl.story.get_room(:room).name.should eq "Room"
    end
  end
  
  it "uses block to create story" do
    repl = IF::REPL.new do
      room :room, "Room"
    end
    repl.story.get_room(:room).name.should eq "Room"
  end
  
  it "calls step when run until :quit thrown" do
      repl = IF::REPL.new
      repl.should_receive(:step).exactly(10).times
      repl.should_receive(:step) { throw :quit }
      repl.should_not_receive(:step)
      
      repl.run
    end
    
  context "when loading story from block" do
    it "sets output" do
      output = StringIO.new
      repl = IF::REPL.new output: output do
      end
      
      repl.story.write "hai 2 u"
      output.rewind
      output.gets.chomp.should eq "hai 2 u"
    end
  end
  
  describe "#read" do
    it "reads from input" do
      input = StringIO.new "fizzbuzz\n"
      repl = IF::REPL.new input: input
      repl.read.should eq "fizzbuzz"
    end
  end
  
  describe "#write_room" do
    it "does not write initial text of moved, visible object" do
      output = StringIO.new
      repl = IF::REPL.new output: output do
        room :room, "Room" do
          object :obj1, "Object 1" do
            initial "init obj 1"
          
            object :obj1_1, "Object 1.1" do
              initial "init obj 1.1"
            end
            
            object :obj1_2, "Object 1.2" do
              initial "init obj 1.2"
            end
            
            actions do
              def objects
                child_objects
              end
            end
          end
          
          object :obj2, "Object 2" do
            initial "init obj 2"
          
            object :obj2_1, "Object 2.1" do
              initial "init obj 2.1"
            end
            
            actions do
              def objects
                child_objects
              end
            end
          end
        end
      end
      
      obj1_1 = repl.story.get_object :obj1_1
      obj2 = repl.story.get_object :obj2
      obj1_1.move_to obj2
      
      repl.write_room repl.story.get_context :room
      
      ["init obj 1", "init obj 1.2", "init obj 2", "init obj 2.1"].each do |initial|
        output.rewind
        text = "#{initial}\n"
        output.readlines.should include text 
      end
      
      output.rewind
      output.readlines.should_not include "init obj 1.1\n"
    end
  
    it "writes initial text of all visible objects" do
      output = StringIO.new
      repl = IF::REPL.new output: output do
        room :room, "Room" do
          object :obj1, "Object 1" do
            initial "init obj 1"
          
            actions do
              def objects
                child_objects
              end
            end
            
            object :obj1_1, "Object 1.1" do
              initial "init obj 1.1"
            end
            
            object :obj1_2, "Object 1.2" do
              initial "init obj 1.2"
            end
          end
          
          object :obj2, "Object 2" do
            initial "init obj 2"
          end
        end
      end
      
      repl.write_room repl.story.get_context :room
      
      ["init obj 1", "init obj 1.1", "init obj 1.2", "init obj 2"].each do |initial|
        output.rewind
        output.readlines.should include "#{initial}\n"
      end
    end
    
    it "executes initial block of all visible objects" do
      output = StringIO.new
      repl = IF::REPL.new output: output do
        room :room, "Room" do
          object :obj1, "Object 1" do
            initial do
              write "init obj 1"
            end
          end
        end
      end
      
      repl.write_room repl.story.get_context :room
      
      output.rewind
      output.readlines.should include "init obj 1\n"
    end
    
    it "writes room description" do
      output = StringIO.new
      repl = IF::REPL.new output: output do
        room :room, "Room" do
          description "fizzbuzz"
        end
      end
      
      repl.write_room repl.story.get_context :room
      
      output.rewind
      output.readlines.should include "fizzbuzz\n"
    end
  end
  
  context "when parsing verbs" do
    before :each do
      @input = StringIO.new
      @output = StringIO.new
    end
  
    it "matches verb alone" do
      repl = IF::REPL.new input: @input, output: @output do
        verb "foo" do
          alone do
            write "foobar"
          end
        end
      end
      
      @input.puts "foo"
      @input.rewind
      
      repl.step
      
      @output.rewind
      @output.readlines.should include "foobar\n"
    end
    
    it "matches verb with parameter" do
      repl = IF::REPL.new input: @input, output: @output do
        verb "foo" do
          with :object do |object|
            write object.name
          end
        end
        room :room, "Room" do
          object :obj, "foobar"
        end
      end
      
      @input.puts "foo foobar"
      @input.rewind
      
      repl.step
      
      @output.rewind
      @output.readlines.should include "foobar\n"
    end
  end
end