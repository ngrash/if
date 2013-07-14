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
      
      @description = config[:description]
      
      config[:names].each do |name|
        @names << name unless @names.include? name
      end if config[:names]
      
      config[:objects].each do |object|
        @objects << object unless @objects.include? object
      end if config[:objects]
      
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
    
    def object(id, name, &block)
      @objects << Object.new(id, name, &block)
    end
  end
end