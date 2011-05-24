#! /usr/bin/env ruby

require 'ap'
require_relative '../lib/data_set'
require_relative '../lib/snns'
require_relative '../lib/study'
require_relative '../lib/snns'
directory=ARGV[0]
best_right=0
best_res=""

snns= MachineLearning::Snns.instance
snns.set_directory(directory)
d = Dir.new(directory)

#save result

d.each do |file|

  if file =~ /test.res/  
    test_res=snns.result(directory+"/"+file)
    
    if test_res[:right] > best_right
      best_res = file
      best_right = test_res[:right]
      puts best_res
      ap test_res
    end
    
  end
end

test_res=snns.result(directory+"/"+best_res)
puts best_res
ap test_res
