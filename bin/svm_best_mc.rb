#! /usr/bin/env ruby

require 'ap'
require_relative '../lib/data_set'
require_relative '../lib/svm'
require_relative '../lib/study'
require_relative '../lib/blank_formatters'

data_folder="../test/theory_data/"
results_folder="./best_poly_multiclass"
Dir.mkdir(results_folder)

train_set = MachineLearning::DataSet.new(data_folder+"sat6c.tra",36,:float)

train_set.file_writer= MachineLearning::SvmFileWriter.new
train_set.line_writer = MachineLearning::SvmPatternWriter.new
train_set.line_formatter = MachineLearning::BlankSVMPatternFormatter.new
train_set.read_data
train_set.to_file!(results_folder+"/train.pat")


test_set = MachineLearning::DataSet.new(data_folder+"sat6c.public.tst",36,:float)

test_set.file_writer= MachineLearning::SvmFileWriter.new
test_set.line_writer = MachineLearning::SvmPatternWriter.new
test_set.line_formatter = MachineLearning::BlankSVMPatternFormatter.new
test_set.read_data
test_set.to_file!(results_folder+"/test.pat")
                
study_params = {:kernel_type=>1,
                :algo=>"MCSVM",
                :trade_off=>0.0001,
                :out_model =>results_folder+"/model.svm",
                :d_polynomial_factor=>1,
                :s_sigmoid_factor=>4.0,
                :c_sigmoid_factor=>1.0,
                :train_pat=>results_folder+"/train.pat"}                

classifier= MachineLearning::Svm.new
classifier.set_directory(results_folder)

classifier.launch_experiment(study_params)

ap classifier.result(results_folder+"/test.pat")