require 'ap'
require_relative '../lib/data_set'
require_relative '../lib/snns'
require_relative '../lib/study'
require_relative '../lib/chromosome_formatters'


data_folder="../test/chromosome_data/"
results_folder="./prac1"

#Create Data Set
set = MachineLearning::DataSet.new(data_folder+"cromos",1,:string)
#Create and set specific formatters for the task
set.file_writer= MachineLearning::SnnsFileWriter.new
set.line_writer = MachineLearning::SnnsPatternWriter.new
set.line_formatter = MachineLearning::ChromosomePatternFormatter.new
#Load data
set.read_data
#Set the params for the study
study_params = Array.new
#Learning technique
algo_param = MachineLearning::Parameter.new(:algo)
algo_param.fix_set(["BackpropMomentum"])
study_params << algo_param
#Original base model
ini_network=MachineLearning::Parameter.new(:in_model)
ini_network.fix_set([data_folder+"chr_1177_30_22.net"])
study_params << ini_network

#Learning parameter will range from 0.2 to 0.5 in 0.1 Increments
learning_param = MachineLearning::Parameter.new(:learning)

learning_param.numeric_range(0.2,0.5,0.1)

study_params << learning_param

#Momentum parameter will range from 0.1 to 0.5 in 0.1 increments
momentum_param = MachineLearning::Parameter.new(:momentum)

momentum_param.numeric_range(0.1,0.5,0.1)

study_params << momentum_param

#Creates the study indicating where to set the results, the 
#learning technique SNNS, the parameters, num cross validation blocks 
study = MachineLearning::Study.new
            (results_folder,:snns,study_params,set,5,"results.txt","study_list.txt")

#Generates the different combinations of all of the parameters indicated hence
#creating the different experiments
study.generate_experiments

#Runs the actual experiments
study.run