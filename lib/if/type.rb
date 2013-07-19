module IF
  class Type
    attr_reader :id
    def initialize(id, &block)
      @id = id
      
      if block
        instance_eval &block
      end
    end
    
    def actions(&block)
      return @actions unless block_given?
      @actions = block
    end
  end
end