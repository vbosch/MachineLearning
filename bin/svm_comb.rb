#! /usr/bin/env ruby

require 'ap'
require_relative '../lib/data_set'
require_relative '../lib/svm'
require_relative '../lib/study'
require_relative '../lib/blank_formatters'

data_folder="../test/theory_data/"
results_folder="./svm_combinations_sigmoid_3"


set = MachineLearning::DataSet.new(data_folder+"sat6c.tra",36,:float)

set.file_writer= MachineLearning::SvmFileWriter.new
set.line_writer = MachineLearning::SvmPatternWriter.new
set.line_formatter = MachineLearning::BlankSVMPatternFormatter.new

set.read_data

study_params = Array.new



kernel_type=MachineLearning::Parameter.new(:kernel_type)
kernel_type.fix_set([3])
study_params << kernel_type

algo_param = MachineLearning::Parameter.new(:algo)
algo_param.fix_set(["DAGSVM"])
study_params << algo_param

trade_off = MachineLearning::Parameter.new(:trade_off)

trade_off.fix_set([10.0])

study_params << trade_off

s_sigmoid_factor = MachineLearning::Parameter.new(:s_sigmoid_factor)

s_sigmoid_factor.fix_set([0.00001])

study_params << s_sigmoid_factor

c_sigmoid_factor = MachineLearning::Parameter.new(:c_sigmoid_factor)

c_sigmoid_factor.fix_set([1])

study_params << c_sigmoid_factor

study = MachineLearning::Study.new(results_folder,:SvmCombinations,study_params,set,5,"results.txt","study_list.txt",6)

study.generate_experiments

study.run
