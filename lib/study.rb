require_relative './parameter'
require_relative './experiment'
require_relative '../lib/study'
require 'ap'

module MachineLearning

  class Study
    
    attr_accessor :tools, :study_params
    attr_reader :experiments
    
    def initialize(exdirectory,extool,study_params,data,expartition,ex_result_file,ex_study_file,ex_num_classes)
      @directory=exdirectory+"/"
      Dir.mkdir(@directory) unless File.exists?(@directory) && File.directory?(@directory)
      @tool = extool
      @study_params = study_params
      @num_classes = ex_num_classes
      @data_set = data
      @num_data_partition = expartition
      @experiments = Array.new
      @result_file=@directory+ex_result_file
      @study_file=@directory+ex_study_file
      @id=0
      @max_right=-1
      @max_right_id=-1
    end
    
    def generate_experiments 
      old_set=Array.new
      new_set=Array.new
      params_used = Array.new
      
      @study_params[0].each do |value|
         old_set << {@study_params[0].name => value}
      end
      
      params_used << @study_params[0].name
      
      #performing the combinations
      @study_params.each do |param|
        next if params_used.include?(param.name)
        param.each do |value|
          old_set.each do |partial_experiment|
          new_partial_experiment = partial_experiment.dup
          new_partial_experiment[param.name]=value
          new_set << new_partial_experiment
          end
        end
        old_set = new_set
        new_set = Array.new
        params_used << param.name
      end
      
      #saving the experiments into the set
      old_set.each do |params|
      params[:id]=@id
      @id+=1
      exp = Experiment.new(@directory,@tool,params,@data_set,@num_data_partition,@num_classes)
      @experiments << exp    
      end 
    end
    
    def run
      puts "Total number of experiments: #{@experiments.length}"
      @experiments.each do |exp|
       puts "Experiment: #{exp.params[:id]}"
       exp.run
       File.open(@result_file,"a+") do |file|
         file.puts "#{exp.params[:id]} #{exp.results[:val_error].round(3)} #{exp.results[:val_wrong].round(3)} #{exp.results[:val_right].round(3)} #{exp.results[:test_error].round(3)} #{exp.results[:test_wrong].round(3)} #{exp.results[:test_right].round(3)}"
       end
       File.open(@study_file, "a+") do |file|
         file.puts "______________________________________________________________________________________"
         file.puts "#{exp.params[:id]}"
         file.puts "#{exp.params}"
       end
       if (@max_right_id == -1 or (@max_right_id != -1 and @max_right < exp.results[:test_right]))
          @max_right_id = exp.params[:id]
          @max_right = exp.results[:test_right]
       end
      end 
      puts "BEST EXPERIMENT #{@max_right_id} -> #{@max_right}"    
    end 
    
  end #class 
end #module
