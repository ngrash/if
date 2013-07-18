require "spec_helper"

describe IF::RoomContext do
  it_behaves_like "context"
  
  include ContextHelper
  
  it "can't move" do
    new_story
    hall = room_context :hall
  
    expect { hall.move_to }.to raise_error NoMethodError
  end

  it "can get exits room" do
    @story = IF::Story.new do
      room :center_room, "Center" do
        north_to :north_room
        east_to :east_room
        south_to :south_room
        west_to :west_room
      end
      room :north_room, "North"
      room :east_room, "East"
      room :south_room, "South"
      room :west_room, "West"
    end
   
    center = @story.get_context(:center_room)
    center.north.should eq :north_room
    center.east.should eq :east_room
    center.south.should eq :south_room
    center.west.should eq :west_room
  end
  
  it "gets child objects" do
    new_story
    hall = room_context :hall
    
    objects = hall.objects
    objects.count.should eq 2
    objects[0].should be object_context :carpet
    objects[1].should be object_context :picture
  end
  
  it "gets child objects recursively" do
    @story = IF::Story.new do
      room :room, "Room" do
        object :obj1, "Object 1" do
          object :obj1_1, "Object 1.1"
          object :obj1_2, "Object 1.2"
          actions do
            def objects
              @_entity.objects.map { |o| @_story.get_context(o) }
            end
          end
        end
        object :obj2, "Object 2"
      end
    end
      
    room = room_context :room
    expected_objects = [:obj1, :obj1_1, :obj1_2, :obj2].map { |o| object_context o }
    actual_objects = room.objects
    actual_objects.length.should eq expected_objects.length
    actual_objects.should eq expected_objects
  end
  
end