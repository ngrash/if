require "spec_helper"

ROOM_ID = :my_room
ROOM_NAME = "My Room"

EXITS = Hash[IF::Room::Directions.map {|d| [d, "#{d}_room".to_sym]}]

def new_room(config=nil, &block)
  IF::Room.new(ROOM_ID, ROOM_NAME, config, &block)
end

def to_exit(direction)
  IF::Room::Directions.to_exit direction
end

describe IF::Room do
  context "when creating" do
    it "raises ArgumentError with less than 2 arguments" do
      expect {
        IF::Room.new
      }.to raise_error ArgumentError, /0 for 2/
    end
  end
  
  context "when created" do  
    its "#exits" do
      new_room.exits.should be_empty
    end
  end
  
  context "when created with config hash" do
    EXITS.each do |direction, to|
      it "sets #{direction} exit" do
        exit = to_exit direction
        room = new_room exit => to
        room.exits[direction].should eq to
      end
    end
  end
  
  context "when created with block" do
    EXITS.each do |direction, to|
      it "sets #{direction} exit" do
        exit = to_exit direction
        room = new_room do
          send(exit, to)
        end
        room.exits[direction].should eq to
      end
    end
  end
  
  it "can set exits" do
    room = new_room
    room.exits = EXITS
    room.exits.should eq EXITS
  end
  
  it "handles closure" do
    r1 = nil
    r2 = new_room do |r|
      r1 = r
    end
    r1.should eq r2
  end
end