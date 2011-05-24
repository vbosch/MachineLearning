require 'ap'
require 'date'
require 'ruby-debug'
require_relative '../lib/snns'
require_relative '../lib/svm'
require_relative '../lib/svm_combinations'

module MachineLearning 

  class Experiment
    
    attr_reader :params, :results
    
    def initialize(exdirectory,ex_tool,experiment_params,ex_data,ex_data_partition,ex_num_classes)   
      @num_data_partitions=ex_data_partition
      @status=:new
      @tool=ex_tool
      @num_classes = ex_num_classes
      @percentage_complete=0
      @params=experiment_params
      @orig_data = ex_data
      @results= Hash.new
      @results[:val_error]=0
      @results[:test_error]=0
      @results[:val_right]=0
      @results[:test_right]=0
      @results[:val_wrong]=0
      @results[:test_wrong]=0
      @directory=exdirectory
    end
    
    def generate_file_names()
      file_name=DateTime.now.strftime("%Y%m%d-%H%M%S")
      @params[:test_pat]=@directory+file_name+"_test.pat"
      @params[:val_pat]=@directory+file_name+"_val.pat"
      @params[:train_pat]=@directory+file_name+"_train.pat"
      @params[:out_model]=@directory+file_name+@params[:algo]+".net"
      @params[:test_res]=@directory+file_name+"test.res"
      @params[:val_res]=@directory+file_name+"val.res"
    end
    
    def save_data_to_file(res)
#      debugger
      if @tool == :Snns
        test=res[0]
        validation=res[1]
        train=res[2]
        validation.to_file!(@params[:val_pat])
        train.to_file!(@params[:train_pat])
      elsif @tool == :Svm
        test=res[0]
        validation=res[1]
        train=res[1]
        test.to_file!(@params[:test_res])
        validation.to_file!(@params[:val_res])
        validation.to_file!(@params[:val_pat])
        train.to_file!(@params[:train_pat])
      elsif @tool == :SvmCombinations
        test=res[0]
        validation=res[1]
        train=res[2]
        test.to_file!(@params[:test_res])
        validation.to_file!(@params[:val_res])
        validation.to_file!(@params[:val_pat])
        train_files = Hash.new
        1.step(@num_classes,1) do |curr_class|
          @num_classes.downto(curr_class+1) do |vs_class|
            train_files["#{curr_class}-#{vs_class}"]=@params[:train_pat]+"_#{curr_class}-#{vs_class}.pat"
            train["#{curr_class}-#{vs_class}"].to_file!(train_files["#{curr_class}-#{vs_class}"])
          end
        end
        
        @params[:train_pat]=train_files
        
      else
        raise "There is no default partition identified for the tool #{@tool}"
      end
      
      test.to_file!(@params[:test_pat])
    end
    
    def generate_experiment_files_for_cross_group(classifier,i)
      #partition the original set  
       partitioned_data=@orig_data.clone.partition(@num_data_partitions)
       #set data groups
       partitioned_data.rotate!(i)
       res=classifier.cross_training(partitioned_data,@num_classes)
       generate_file_names
       save_data_to_file(res)
    end
    
    def update_results(classifier)
      test_res=classifier.result(@params[:test_res])
      val_res=classifier.result(@params[:val_res])
      @results[:val_error]+=val_res[:error]
      @results[:test_error]+=test_res[:error]
      @results[:val_right]+=val_res[:right]
      @results[:test_right]+=test_res[:right]
      @results[:val_wrong]+=val_res[:wrong]
      @results[:test_wrong]+=test_res[:wrong]
    end
    
    def calculate_results_averages
      @percentage_complete+=100/@num_data_partitions
      @results[:val_error]/=@num_data_partitions
      @results[:test_error]/=@num_data_partitions
      @results[:val_right]/=@num_data_partitions
      @results[:test_right]/=@num_data_partitions
      @results[:val_wrong]/=@num_data_partitions
      @results[:test_wrong]/=@num_data_partitions
    end
    
    def obtain_classifier
      classifier= Object.const_get("MachineLearning").const_get(@tool).new
      classifier.set_directory(@directory)
      return classifier
    end
    
    def run
      @status=:running
      classifier=obtain_classifier
      #loop partitions
      @orig_data.shuffle!
      0.upto(@num_data_partitions-1) do |i|
        generate_experiment_files_for_cross_group(classifier,i)
        #run expirement
        classifier.launch_experiment(@params)
        printf(".")
        #save result
        update_results(classifier)
      end
      puts
      #end loops
      calculate_results_averages
      
      @status=:finish
      return @results
    end
  
  end
  
end