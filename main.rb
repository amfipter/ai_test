#!/usr/bin/env ruby2.0
require '~/Documents/research/ai_test/model.rb'

$planets = Planets.new()
$model = Model.new()
$id = nil
$ship_capt_overhead_free = 1.1
$ship_capt_overhead = 1.3
$upgrade_prob = 75

def read_parse
  ARGF.each do |i|
    p = i.split(" ")
    # STDERR.puts i 
    if(p[0].eql? 'P')
      $planets.update(p[1].to_i, p[2].to_f, p[3].to_f, p[4].to_i, p[5].to_i, p[6].to_i)
    elsif(p[0].eql? 'Y')
      $id = p[1].to_i if $id.nil?
    end 
    break if i.chomp.eql? '.'
  end
  # puts $id 
  # $planets.debug
end

while(true)
  read_parse()
  $model.update()
  # STDERR.puts $model.exec
  puts $model.exec()
  STDOUT.flush()
end



