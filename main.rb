require './bird'

FPS = 10

Shoes.show_log
Shoes.app(:title => 'Birds', :width => WORLD[:xmax] + BIRD_SIZE*2, :height => WORLD[:ymax] + BIRD_SIZE*2) do
  stroke blue
  fill lightblue

	$birds = []
	$obstacles = []

	POPULATION_SIZE.times do |i|
		puts i
		random_location = Vector[rand(WORLD[:xmax]),rand(WORLD[:ymax])]
    random_velocity = Vector[rand(11)-5,rand(11)-5]
    $birds << Bird.new(self, random_location, random_velocity)
  end

  animate(FPS) do
    click do |button, left, top|
      $obstacles << Vector[left,top]
    end

  	clear do
  		line 0,0,0,WORLD[:ymax]
			line 0,0,WORLD[:xmax],0
			line 0,WORLD[:ymax],WORLD[:xmax],WORLD[:ymax]
			line WORLD[:xmax],0,WORLD[:xmax],WORLD[:ymax]
			
			$obstacles.each do |obstacle|
			  oval(left: obstacle[0], top: obstacle[1], radius: OBSTACLE_SIZE, center: true, stroke: red, fill: pink)
			end

  		$birds.each do |bird| bird.move end
  	end
  end
end
