require './bird'
Shoes.show_log
Shoes.app(:title => 'Birds', :width => WORLD[:xmax] + BIRD_SIZE*2, :height => WORLD[:ymax] + BIRD_SIZE*2) do
	$birds = []
	POPULATION_SIZE.times do |i|
		puts i
		random_location = Vector[rand(WORLD[:xmax]),rand(WORLD[:ymax])]
    random_velocity = Vector[rand(11)-5,rand(11)-5]
    $birds << Bird.new(self, random_location, random_velocity)
  end

  animate(10) do
  	clear do
  		line 0,0,0,WORLD[:ymax]
			line 0,0,WORLD[:xmax],0
			line 0,WORLD[:ymax],WORLD[:xmax],WORLD[:ymax]
			line WORLD[:xmax],0,WORLD[:xmax],WORLD[:ymax]
  		$birds.each do |bird| bird.move end
  	end
  end
end
