require 'ap'
require 'open3'
require 'singleton'
require 'ruby-debug'
require_relative '../lib/svm'


module MachineLearning 
  class SvmCombinations
    def initialize(extoolspath="",type=:one_against_all)
      @num_classes=nil
    end
    def set_directory(exdirectory)
      @directory=exdirectory
    end
    
    def cross_training(partitioned_data,ex_num_classes)
      
      @num_classes=ex_num_classes
      create_sub_svms
      res = Array.new()
      res[0] = partitioned_data[0] #test
      res[1] = partitioned_data[1] #validation
      2.upto(partitioned_data.length-1) do |p|
        res[1].add!(partitioned_data[p])
      end
      res[2]=res[1].clone
      train = Hash.new
      1.step(@num_classes,1) do |curr_class|
        @num_classes.downto(curr_class+1) do |vs_class|
          train["#{curr_class}-#{vs_class}"]=res[2].filter_and_binarize_classes([curr_class,vs_class])
          #puts "#{curr_class}-#{vs_class} #{train["#{curr_class}-#{vs_class}"].classes}"
        end
      end
      res[2]=train
      return res
    end
    
    def create_sub_svms
     @svms = Hash.new{|h,key|h[key]=Hash.new}  
     1.step(@num_classes,1) do |curr_class|
       @num_classes.downto(curr_class+1) do |vs_class|
         @svms[curr_class][vs_class]=Svm.new("",:light)
       end
     end
    end
    
    def set_internal_directory
      Dir.mkdir(@internal_directory) unless File.exists?(@internal_directory) && File.directory?(@internal_directory)
      1.step(@num_classes,1) do |curr_class|
        @num_classes.downto(curr_class+1) do |vs_class|
          @svms[curr_class][vs_class].set_directory @internal_directory
        end
      end
    end
    
    def launch_experiment(params)
      raise "Cross training must be called before launching an experiment" if @num_classes.nil?
      @parameter = params
      @internal_directory = @parameter[:out_model]
      set_internal_directory
      1.step(@num_classes,1) do |curr_class|
        @num_classes.downto(curr_class+1) do |vs_class|
          aux_param = @parameter.clone
          aux_param[:out_model] = aux_param[:out_model] + "/#{curr_class}_#{vs_class}.net"
          aux_param[:train_pat] = aux_param[:train_pat]["#{curr_class}-#{vs_class}"]
          #puts "Training #{curr_class}-#{vs_class}"
          @svms[curr_class][vs_class].launch_experiment(aux_param)
        end
      end  
    end
    
    def classify_pattern(pattern_line)
        curr_class = 1
        vs_class = @num_classes
        class_found = false
        aux_line = pattern_line.chop.split
        aux_line[0]="1"
        new_pattern_line= aux_line.inject(""){|res,i| res += i + " "}.chop
        
        while not class_found
           #puts "Launching for #{curr_class} #{vs_class}"
           res = @svms[curr_class][vs_class].classify_pattern(new_pattern_line)
           #puts "BEFORE #{res} #{curr_class} #{vs_class}"
           if res > 0
             vs_class-=1
             return curr_class if @svms[curr_class][vs_class].nil?
           else
             curr_class+=1
             return vs_class if @svms[curr_class].nil? or @svms[curr_class][vs_class].nil?
           end   
           #puts "AFTER #{res} #{curr_class} #{vs_class}"          
        end
    end
    
    def result(pattern_file)
      puts "Classifying #{pattern_file}"
      res = Hash.new
      res[:right] = 0.0
      res[:wrong] = 0.0
      count = 0.0
      File.open(pattern_file) do |file|
        while pattern_line = file.gets
          count +=1.0
          printf(".")
          real_label= get_label(pattern_line)
          est_label = classify_pattern(pattern_line)
          if est_label == real_label
            res[:right] += 1.0
          else
            res[:wrong] += 1.0
          end
        end
      end
      puts
      #debugger
      puts res
      puts count
      res[:right] /= count
      res[:wrong] /= count
      res[:error] = res[:wrong]
      
      return res
    end
    
    def get_label(pattern_line)
      return pattern_line.chop.split[0].to_f
    end
    
    
  end
end