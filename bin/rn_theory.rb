#! /usr/bin/env ruby

require 'ap'
require_relative '../lib/data_set'
require_relative '../lib/snns'
require_relative '../lib/study'
require_relative '../lib/snns'

data_folder="../test/theory_data/"
results_folder="./BESTRBF36_100_6"


set = MachineLearning::DataSet.new(data_folder+"full_set.norm",36,:float)

set.file_writer= MachineLearning::SnnsFileWriter.new
set.line_writer = MachineLearning::SnnsPatternWriter.new
set.read_data

study_params = Array.new

algo_param = MachineLearning::Parameter.new(:algo)
algo_param.fix_set(["RadialBasisLearning"])#"RadialBasisLearning"])
study_params << algo_param

ini_network=MachineLearning::Parameter.new(:in_model)
ini_network.fix_set([data_folder+"rbf_36_100_6.net"])
study_params << ini_network


learning_param = MachineLearning::Parameter.new(:learning)

learning_param.numeric_range(0.1,0.1,0.05)

study_params << learning_param

centers_param = MachineLearning::Parameter.new(:centers)

centers_param.numeric_range(0.01,0.01,0.05)

study_params << centers_param

bias_param = MachineLearning::Parameter.new(:bias)

bias_param.numeric_range(0.0,0.0,0.05)

study_params << bias_param

#momentum_param = MachineLearning::Parameter.new(:momentum)

#momentum_param.numeric_range(0.5,0.5,0.1)

#study_params << momentum_param

#max_growth_param = MachineLearning::Parameter.new(:max_growth)

#max_growth_param.numeric_range(0.7,0.7,0.1)

#study_params << max_growth_param

#ap study_params

study = MachineLearning::Study.new(results_folder,:Snns,study_params,set,30,"results.txt","study_list.txt")

study.generate_experiments

study.run
