require "if"

module IF
  class REPL
    def initialize(story_file=nil, input=STDIN, output=STDOUT, &block)
      @input, @output = input, output
      @story = IF::Story.load story_file, output: output
    end
    
    def run
      
    end
  end
end