#! /usr/bin/env ruby

require 'ap'
require_relative '../lib/data_set'
require_relative '../lib/svm'
require_relative '../lib/study'
require_relative '../lib/blank_formatters'

data_folder="../test/theory_data/"
results_folder="./svm_combinations_rbf"


set = MachineLearning::DataSet.new(data_folder+"sat6c.tra",36,:float)

set.file_writer= MachineLearning::SvmFileWriter.new
set.line_writer = MachineLearning::SvmPatternWriter.new
set.line_formatter = MachineLearning::BlankSVMPatternFormatter.new

set.read_data

study_params = Array.new



kernel_type=MachineLearning::Parameter.new(:kernel_type)
kernel_type.fix_set([2])
study_params << kernel_type

algo_param = MachineLearning::Parameter.new(:algo)
algo_param.fix_set(["SVM_Class"])#"RadialBasisLearning"])
study_params << algo_param

gamma_rbf_factor = MachineLearning::Parameter.new(:gamma_rbf_factor)

gamma_rbf_factor.numeric_range(0.5,3,0.5)

study_params << gamma_rbf_factor

#d_polynomial_factor = MachineLearning::Parameter.new(:d_polynomial_factor)

#d_polynomial_factor.numeric_range(1,3,1)

#study_params << d_polynomial_factor

#ap study_params

study = MachineLearning::Study.new(results_folder,:SvmCombinations,study_params,set,5,"results.txt","study_list.txt",6)

study.generate_experiments

study.run
