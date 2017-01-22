class Hello < Skippy::Command

  desc 'world PERSON', 'Oh, hi there!'
  def world(person)
    say "Hello #{person}"
  end
  default_command(:world)

  desc 'universe', 'Greets the universe in general'
  def universe
    say "DARK IN HERE, ISN'T IT?"
  end

end
