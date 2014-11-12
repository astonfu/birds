require 'matrix'

BIRD_SIZE = 7
POPULATION_SIZE = 30
WORLD = {:xmax => BIRD_SIZE * 100, :ymax => BIRD_SIZE * 100}
MAGIC_NUMBER = 7
SEPARATION_RADIUS = BIRD_SIZE * 3
ALIGMENT_RADIUS = BIRD_SIZE * 15
COHESION_RADIUS = BIRD_SIZE * 15
MAX_BIRD_SPEED = BIRD_SIZE

SEPARATION_ADJUSTMENT = 10 # how far away should roids stay from each other (small further away)
ALIGNMENT_ADJUSTMENT = 8 # how aligned are the roids with each other (smaller more aligned)
COHESION_ADJUSTMENT = 100 # how cohesive the roids are with each other (smaller more cohesive)

OBSTACLE_SIZE = 10
CENTER_RADIUS = BIRD_SIZE * 5

class Vector
  def /(x)
    if (x != 0)
      Vector[self[0]/x.to_f,self[1]/x.to_f]
    else
      self
    end
  end  
end

class Bird
  attr_reader :velocity, :position
  def initialize(slot, position, velocity)
    @slot = slot
    @position = position
    @velocity = velocity
    puts "new bird: #{self.inspect}"
    draw
  end

  def distance_from(bird)
    distance_from_point(bird.position)
  end

  def distance_from_point(vector)
    x = self.position[0] - vector[0]
    y = self.position[1] - vector[1]
    Math.sqrt(x*x + y*y)    
  end

  def nearby?(threshold, bird)
    return false if bird === self
    (distance_from(bird) < threshold) and within_fov?(bird)
  end

  def within_fov?(bird)
    v1 = self.velocity - self.position
    v2 = bird.position - self.position
    cos_angle = v1.inner_product(v2)/(v1.r*v2.r)
    Math.acos(cos_angle) < 0.75 * Math::PI
  end

  def draw
    @slot.oval left: @position[0], top: @position[1], radius: BIRD_SIZE
    @slot.line @position[0], @position[1], @position[0]-@velocity[0], @position[1]-@velocity[1]
  end

  def separate
    distance = Vector[0,0]
    $birds.each do |bird|
      if nearby?(SEPARATION_RADIUS, bird)
        distance += self.position - bird.position
        puts "distance: #{distance}"
      end
    end
    @delta += distance/SEPARATION_ADJUSTMENT
  end

  def align
    nearby, average_velocity = 0, Vector[0,0]
    $birds.each do |bird|
      if nearby?(ALIGMENT_RADIUS, bird)
        average_velocity += bird.velocity
        nearby += 1
      end
    end

    average_velocity /= nearby if nearby > 0
    @delta += (average_velocity - self.velocity) / ALIGNMENT_ADJUSTMENT
  end

  def cohere
    nearby, average_position = 0, Vector[0,0]
    $birds.each do |bird|
      if nearby?(COHESION_RADIUS, bird)
        average_position += bird.position
        nearby += 1
      end
    end

    average_position /= nearby if nearby > 0
    @delta += (average_position - self.position) / COHESION_ADJUSTMENT
  end

  def muffle
    if @velocity.r > MAX_BIRD_SPEED
      @velocity /= @velocity.r
      @velocity *= MAX_BIRD_SPEED
    end
    puts "muffle @velocity: #{@velocity}"
  end
  
  def center
    @delta -= (@position - Vector[WORLD[:xmax]/2, WORLD[:ymax]/2]) / CENTER_RADIUS
    puts "center @delta: #{@delta}"
  end
  
  def allow_fallthrough
    x = case
    when @position[0] < 0 then WORLD[:xmax] + @position[0]
    when @position[0] > WORLD[:xmax] then WORLD[:xmax] - @position[0]
    else @position[0]
    end
    y = case
    when @position[1] < 0 then WORLD[:ymax] + @position[1]
    when @position[1] > WORLD[:ymax] then WORLD[:ymax] - @position[1]
    else @position[1]
    end
    @position = Vector[x,y]
  end

  def move
    @delta = Vector[0,0]
    %w[separate align cohere muffle center].each do |action|
      puts "action: #{action}"
      self.send action
    end
    @velocity += @delta
    @position += @velocity
    # back
    # if @position[0] > WORLD[:xmax] or @position[0] < 0 or @position[1] > WORLD[:ymax] or @position[1] < 0
      # @velocity = Vector[rand(11)-5,rand(11)-5]
    # end
    allow_fallthrough
    draw
  end
end