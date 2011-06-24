#! /usr/bin/env ruby

require 'ap'
require_relative '../lib/data_set'
require_relative '../lib/svm'
require_relative '../lib/study'
require_relative '../lib/blank_formatters'

data_folder="../test/theory_data/"
results_folder="./best_poly_combi"
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

classifier= MachineLearning::SvmCombinations.new
classifier.set_directory(results_folder)

study_params = {:kernel_type=>1,
                :algo=>"DAGSVM",
                :trade_off=>0.0001,
                #:gamma_rbf_factor=>0.0001,
                :out_model =>results_folder+"/model.svm",
                :d_polynomial_factor=>1,
                :s_sigmoid_factor=>4.0,
                :c_sigmoid_factor=>1.0,
                :train_pat=>results_folder+"/train.pat"}

train=classifier.base_training(train_set,6)
train_files = Hash.new
1.step(6,1) do |curr_class|
  6.downto(curr_class+1) do |vs_class|
    train_files["#{curr_class}-#{vs_class}"]=study_params[:train_pat]+"_#{curr_class}-#{vs_class}.pat"
    train["#{curr_class}-#{vs_class}"].to_file!(train_files["#{curr_class}-#{vs_class}"])
  end
end
study_params[:train_pat]=train_files

classifier.launch_experiment(study_params)

#puts "TRAINING"
#ap classifier.result(results_folder+"/train.pat")

puts "TEST"
ap classifier.result(results_folder+"/test.pat")