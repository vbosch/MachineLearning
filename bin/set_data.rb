#! /usr/bin/env ruby

require 'ap'
require_relative '../lib/data_set'
require_relative '../lib/snns'
require_relative '../lib/study'
require_relative '../lib/chromosome_formatters'

#puts "sample"

#data = MachineLearning::DataSet.new("./test.dat",4)

#data.statistics

#puts "TRAINING"

data_folder="../test/theory_data/"

set = MachineLearning::DataSet.new(data_folder+"sat6c.public.tst.norm",36,:float)

#data.statistics

set.file_writer= MachineLearning::SnnsFileWriter.new
set.line_writer = MachineLearning::SnnsPatternWriter.new
set.read_data
#set.to_file!("./theo_data.txt")

ap set.classes

ap set.pattern_set.length