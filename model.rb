class Model
  def initialize()
    @planets = $planets
    @c1 = 0.3
    @c2 = 0.3
    @c3 = 0.3
    @solution = Array.new
  end

  def calculate_capture_prof()
    nil
  end

  def economic_solver()
    slaves = @planets.give_our_slaves()
    solution = Array.new
    slaves.each do |s|
      solution.push [s.upgrade_cost, 1, "upgrade_#{s.id}"]
    end
    slaves.each do |s|
      solution += @planets.calculate_capture_nships(s)
    end
    solution_1 = Array.new 
    solution_2 = Array.new 
    solution_3 = Array.new
    solution.each do |s|
      if(s[1] > 0)
        solution_1.push s 
      elsif(s[1] == 0)
        solution_2.push s 
      else
        solution_3.push s 
      end
    end
    solution_1.sort! {|e1, e2| (e1[0].to_f / e1[1].to_f) <=> (e2[0].to_f / e2[1].to_f)}
    solution_2.sort! {|e1, e2| e1[0].to_f <=> e2[0].to_f}
    solution_3.sort! {|e1, e2| (e1[0].to_f / e1[1].to_f) <=> (e2[0].to_f / e2[1].to_f)}
    solution = solution_1 + solution_2 + solution_3
    solution
  end

  def aggr_solver_simple()
    solution = Array.new
    enemy = @planets.find_closest_enemy()
    solution.push [enemy[1].caclulate_capture_cost(enemy[0]), enemy[0].gr, "capture_#{enemy[1]}_#{enemy[0]}"]
    solution
  end

  def protect_solver()
    solution = Array.new
    nil
  end

  def state_analysis()
    @c1 = 1
    @c2 = 0
    @c3 = 0
  end

  def update()
    @solution = Array.new
    state_analysis()
    solution_1 = economic_solver()
    solution_2 = aggr_solver_simple()
    solution_3 = protect_solver()

    #shitcode
    solution_1.each do |s|
      src = $1.to_i if s[2] =~ /^.*?_(\d+)/
      p = @planets.find_planet(src)
      # puts s.to_s
      if(p.ns >= s[0])
        @solution.push s 
        p.remove_ships(s[0])
      end
    end
  end

  def exec()
    out = ''
    @solution.each do |s|
      if(s[2] =~ /^.*?_(\d+)_(\d+)/)
        src = $1
        dist = $2
        out += "F #{src} #{dist} #{s[0]}\n"
      else
        if(Random.rand(1..100) <= $upgrade_prob)
          s[2] =~ /_(\d+)/
          src = $1 
          out += "B #{src}\n"
        end
      end
    end
    out += "."
    out
  end

end

class Planets
  def initialize()
    @planets = Array.new
  end

  def update(id, x, y, gr, pl_id, ns)
    p = nil
    @planets.each do |obj|
      p = obj if obj.id == id 
    end
    if(p.nil?)
      p = Planet.new(id, x, y, gr, pl_id, ns)
      @planets.push p 
    else
      p.update(gr, pl_id, ns)
    end
    nil
  end

  def give_our_slaves()
    out = Array.new
    @planets.each do |planet|
      out.push planet if planet.pl_id == $id
    end
    out
  end

  def find_planet(id)
    @planets.each do |p|
      return p if p.id == id
    end
  end

  def calculate_capture_nships(planet)
    out = Array.new
    @planets.each do |p|
      next if p.pl_id == $id 
      out.push [planet.caclulate_capture_cost(p)[0].ceil, p.gr, "capture_#{planet.id}_#{p.id}"]
    end
    out
  end

  def find_closest_enemy()
    enemy = nil
    slaves = give_our_slaves()
    slaves.each do |s|
      @planets.each do |p|
        next if p.pl_id == $id 
        next if p.pl_id == 0
        enemy = [p, s] if enemy.nil? 
        enemy = [p, s] if s.dist(p) < s.dist(enemy[0])
      end
    end
    enemy 
  end


  def debug()
    puts "========PLANET_DEBUG========"
    @planets.each do |p|
      puts p.to_s
    end
    puts "========PLANET_DEBUG========"
  end
end

class Planet
  attr_reader :id, :x, :y, :gr, :pl_id, :ns, :upgrade_cost
  def initialize(id, x, y, gr, pl_id, ns)
    @id = id
    @x = x
    @y = y
    @gr = gr
    @pl_id = pl_id
    @ns = ns
    @upgrade_cost = 2**(gr.abs)

    nil
  end

  def update(gr, pl_id, ns)
    @gr = gr 
    @pl_id = pl_id
    @ns = ns
    @upgrade_cost = 2**(gr.abs)
    nil
  end

  def remove_ships(n)
    @ns -= n
    nil
  end

  def dist(planet)
    return Math.sqrt((@x - planet.x)**2 + (@y - planet.y)**2).ceil
  end

  def to_s()
    "PLANET ID: #{@id}; #{@x}:#{@y}; GR: #{@gr}; OWNER: #{@pl_id}; NS: #{@ns}"
  end

  def caclulate_capture_cost(other_planet)
    dist = Math.sqrt((@x - other_planet.x)**2 + (@y - other_planet.y)**2).ceil
    return 2**64, dist if other_planet.pl_id == $id 
    if(other_planet.pl_id == 0)
      cost = other_planet.ns * $ship_capt_overhead_free
      return cost, dist
    elsif(other_planet.pl_id > 0)
      cost = (other_planet.ns + other_planet.gr * dist) * $ship_capt_overhead
      return cost, dist
    end
    return 2**64, dist
  end
        


end