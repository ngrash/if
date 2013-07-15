module IF
  class Story
    attr_reader :rooms, :verbs
  
    def initialize(config=nil, &block)
      config ||= {}
    
      @rooms = []
      @verbs = []
      
      config[:rooms].each do |room|
        @rooms << room unless @rooms.include? room
      end if config[:rooms]
      
      config[:verbs].each do |verb|
        @verbs << verb unless @verbs.include? verb
      end if config[:verbs]
      
      if block
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end
    
    def room(id, name, &block)
      @rooms << Room.new(id, name, &block)
    end
    
    def verb(*names, &block)
      @verbs << Verb.new(*names, &block)
    end
  end
end