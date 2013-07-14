module IF
  class Entity
    attr_reader :id, :name, :objects
    attr_writer :description
  
    def initialize(id, name, config=nil, &block)
      config ||= {}
    
      @id = id
      @name = name
      @names = [name]
      @objects = []
      
      config[:names].each do |name|
        @names << name unless @names.include? name
      end if config[:names]
      @description = config[:description]
      
      if block_given?
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end
    
    def description(description=nil)
      return @description unless description
      @description ||= ""
      @description << "\n" unless @description.empty?
      @description << description
    end
    
    def names(*names)
      return @names if names.empty?
      names.each do |name|
        @names << name unless @names.include? name
      end
    end
  end
end