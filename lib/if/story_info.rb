module IF
  class StoryInfo    
    def initialize(config={}, &block)
      @name = config[:name]
      @author = config[:author]
      @start = config[:start]
      
      if block
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end
    
    def name(name=nil)
      return @name if name.nil?
      @name = name
    end
    
    def author(author=nil)
      return @author if author.nil?
      @author = author
    end
    
    def start(start=nil)
      return @start if start.nil?
      @start = start
    end
  end
end