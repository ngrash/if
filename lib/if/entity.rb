module IF
  class Entity
    attr_accessor :parent
    attr_reader :id, :context
    attr_writer :description
  
    def initialize(id, name, config=nil, &block)
      config ||= {}
    
      @id = id
      @names = [name]
      @objects = []
      @context = IF::Context.new(self)
      
      move_to config[:parent]
      
      @description = config[:description]
      
      names *config[:names] if config[:names]
      
      config[:objects].each do |object|
        object.move_to self
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
    
    def name
      @names.first
    end
    
    def names(*names)
      return @names if names.empty?
      names.each do |name|
        @names << name unless @names.include? name
      end
    end
    
    def objects(recursive=false)
      return @objects unless recursive
      
      objects = []
      @objects.each do |child|
        objects << child
        objects += child.objects(true)
      end
      objects
    end
    
    def object(id, name, &block)
      Object.new(id, name, parent: self, &block)
    end
    
    def move_to(target_entity)
      @parent.objects.delete self if @parent
      @parent = target_entity
      @parent.objects << self if @parent
    end
  end
end