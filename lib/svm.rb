require 'ap'
require 'open3'
require 'singleton'
require 'ruby-debug'

module MachineLearning 
  
  class Svm
    
    MULTICLASS_LEARN = "svm_multiclass_learn"
    MULTICLASS_CLASSIFY = "svm_multiclass_classify"
    SIMPLE_LEARN = "svm_learn"
    SIMPLE_CLASSIFY = "svm_classify"
    
    attr_accessor :type
    
    def initialize(extoolspath="",type=:multiclass)
      @toolspath=extoolspath
      @directory="./"
      @type = type
    end
    
    def set_directory(exdirectory)
      @directory=exdirectory
    end
    
    def cross_training(partitioned_data)
      
      res = Array.new()
      
      res[0] = partitioned_data[0] #test
      res[1] = partitioned_data[1] #train
      2.upto(partitioned_data.length-1) do |p|
        res[1].add!(partitioned_data[p])
      end
      
      return res
    end
    
    def learn_comand
      return @type == :multiclass ? MULTICLASS_LEARN : SIMPLE_LEARN
    end
    
    def classify_comand
      return @type == :multiclass ? MULTICLASS_CLASSIFY : SIMPLE_CLASSIFY
    end
    
    def launch_experiment(params)
      @parameter = params
      
      svm_learn(generate_call_params)
      
    end
    
    def generate_call_params
      
      line = "-c #{@parameter[:trade_off]} -t #{@parameter[:kernel_type]}"
      
      case @parameter[:kernel_type]
      when 1 then #polynomial kernel
        line += " -d #{@parameter[:d_polynomial_factor]}"
      when 2 then #RBF kernel
        line += " -g #{@parameter[:gamma_rbf_factor]}"
      when 3 then #Sigmoid kernel
        line += " -s #{@parameter[:s_sigmoid_factor]} -r #{@parameter[:c_sigmoid_factor]}" 
      else
        raise "The selected kernel #{@parameter[:kernel_type]} has not been implemented"
      end    
      line+= " #{@parameter[:train_pat]} #{@parameter[:out_model]}"
      
      return line 
      
    end
    
    def pattern_to_file(pattern_line,pattern_file)
      File.open(pattern_file,"w") do |file|
        file.puts pattern_line
      end
    end
    
    def classify_pattern(pattern_line)
      aux_pattern_file = "./aux_pat.txt"
      aux_res_file = "./aux_res.txt"
      pattern_to_file(pattern_line,aux_pattern_file)
      #puts "#{@toolspath}#{classify_comand} -v 0 #{aux_pattern_file} #{@parameter[:out_model]} #{aux_res_file}"
      system "#{@toolspath}#{classify_comand} -v 0 #{aux_pattern_file} #{@parameter[:out_model]} #{aux_res_file}"
      val = extract_classification_from_file(aux_res_file)
      File.delete(aux_pattern_file,aux_res_file)
      return val
    end
    
    def extract_classification_from_file(exfile)
      aux = 0.0
      File.open(exfile) do |file|
        while line = file.gets
          aux = line.chomp.split[0].to_f
        end
      end
      return aux > 0 ? 1 : -1
    end
    
    def svm_learn(parameter_line)
      #puts "#{@toolspath}#{learn_comand} -v 0 -m 1024 -c 0.01 #{parameter_line}"      
      system "#{@toolspath}#{learn_comand} -v 0 -m 1024 #{parameter_line}"      
    end
    
    def result(pattern_file)
      res = Hash.new
      Open3.popen3("#{@toolspath}#{classify_comand} -v 0 #{pattern_file} #{@parameter[:out_model]}" ) do |stdin,stdout,stderr|
        while line = stdout.gets
          puts line
          array=line.chomp.split
          index=array.find_index("set:")
          if not index.nil? and array[0]=="Average"
            res[:wrong]=array[index+1].to_f
            break
          end
        end #reading lines
      end #open3
      res[:right] = 100.0 - res[:wrong]
      res[:error] = res[:wrong]
      return res
    end #svn
    
    private :generate_call_params, :svm_learn   
  end

  class SvmFileWriter
    attr_reader :toolspath
    def initialize(extoolspath="")
      @toolspath=extoolspath
    end
    def write_header(exfilepath,num_pats,in_units,out_units)
      system "touch #{exfilepath}"
    end
    def write_footer(exfilepath)
      File.open(exfilepath, "a+") do |file|
        file.puts "#EOF\n"
      end
    end
  end #svnfilewriter
  
  class SvmPatternWriter
    
    def write(pattern,file)
      line = pattern.label.to_s + " "
      pattern.dimension.times{ |i| line+="#{i+1}:#{pattern[i].to_s} " unless pattern[i].zero?      }
      file.puts line
    end
    
  end #svnpatternwriter
  
end