require 'ap'
require 'open3'
require 'singleton'

module MachineLearning 
  
  class Snns
    include Singleton 
    
    def initialize(extoolspath="")
      @toolspath=extoolspath
      @directory="./"
    end
    
    def set_directory(exdirectory)
      @directory=exdirectory
    end
    
    
    def launch_experiment(params)
      @parameter = params
      @script=@directory+params[:id].to_s+".bat"
      @log=@directory+params[:id].to_s+".log"
      
      File.open(@script, "w") do |file|
        generate_script(file)
      end
      
      batchman(@script,@log)
      
      #return result_file_error(@parameter[:test_res])
    end
    
    def generate_script(file)
      file.puts "loadNet (\"#{@parameter[:in_model]}\")"
      file.puts "loadPattern (\"#{@parameter[:val_pat]}\")"
      file.puts "loadPattern (\"#{@parameter[:test_pat]}\")"
      file.puts "loadPattern (\"#{@parameter[:train_pat]}\")"
      case @parameter[:algo]
      when "Std_Backpropagation","BackpropBatch" then 
        file.puts "setLearnFunc(\"#{@parameter[:algo]}\",#{@parameter[:learning]})"
      when "BackpropMomentum" then
        file.puts "setLearnFunc(\"#{@parameter[:algo]}\",#{@parameter[:learning]},#{@parameter[:momentum]})"
      when "Quickprop" then 
        file.puts "setLearnFunc(\"#{@parameter[:algo]}\",#{@parameter[:learning]},#{@parameter[:max_growth]})"
      when "RadialBasisLearning"
        file.puts "setLearnFunc(\"#{@parameter[:algo]}\",#{@parameter[:centers]},#{@parameter[:bias]},0.01,0.1,0.8)"
      else
        raise "The selected learning algorythm #{parameter[:algo]} has not been implemented"
      end
      
      if @parameter[:algo] == "RadialBasisLearning"
        file.puts "setPattern (\"#{@parameter[:train_pat]}\")"
        file.puts "trainNet()"
        file.puts "setInitFunc(\"Randomize_Weights\",0.1,-0.1)"
        file.puts "initNet()"
        file.puts "setInitFunc(\"RBF_Weights_Kohonen\",50.0,0.3,1.0)"
        file.puts "initNet()"
        file.puts "setInitFunc(\"RBF_Weights\",-3.0, 3.0 ,0.0 , 0.095, 0.0)"
        file.puts "setUpdateFunc(\"Topological_Order\")"
        file.puts "setShuffle(TRUE)"
        file.puts "initNet()"
      end
      
      file.puts "min_e=-1.0"
      file.puts "count=0"
      file.puts "setShuffle(TRUE)"
      file.puts "while(TRUE) do"
        file.puts "setPattern (\"#{@parameter[:train_pat]}\")" 
        file.puts "for i := 1 to 10 do"
          file.puts "trainNet()"
        file.puts "endfor"
        file.puts "testNet()"  if @parameter[:algo] != "RadialBasisLearning" 
        file.puts "tr_mse=MSE"          
        file.puts "setPattern (\"#{@parameter[:val_pat]}\")"
        file.puts "testNet()" if @parameter[:algo] != "RadialBasisLearning" 
        file.puts "print(CYCLES,\" \",tr_mse,\" \",MSE)"
        file.puts "if min_e == -1.0 or min_e - MSE > 0.0001 then"
          file.puts "min_e=MSE"
          file.puts "count=0"
          file.puts "saveNet(\"#{@parameter[:out_model]}\")"
          file.puts "saveResult (\"#{@parameter[:val_res]}\", 1, PAT, FALSE, TRUE, \"create\")"
        file.puts "else"
          file.puts "count=count+1"  
        file.puts "endif"
      #file.puts "print(count)"
      file.puts "if(count > 100) then break endif"
      file.puts "endwhile"      
      file.puts "loadNet (\"#{@parameter[:out_model]}\")"
      file.puts "setPattern (\"#{@parameter[:test_pat]}\")"
      file.puts "testNet()" if @parameter[:algo] != "RadialBasisLearning"
      file.puts "saveResult (\"#{@parameter[:test_res]}\", 1, PAT, FALSE, TRUE, \"create\")"
      
    
    end
    
    def batchman(script,log_file)
      system "batchman -f #{script} -l #{log_file} -q"
    end
    
    def cross_training(partitioned_data)
      
      res = Array.new()
      
      res[0] = partitioned_data[0] #test
      res[1] = partitioned_data[1] #validation
      res[2] = partitioned_data[2] #train
      3.upto(partitioned_data.length-1) do |p|
        res[2].add!(partitioned_data[p])
      end
      
      return res
    end
    
    def result(res_file)
      res = Hash.new
      Open3.popen3("#{@toolspath}analyze -s -e WTA -i #{res_file}") do |stdin,stdout,stderr|
        while line = stdout.gets
          array=line.chomp.split
          index=array.find_index("wrong")
          if not index.nil?
            res[:wrong]=array[index+2].to_f
            next
          end
          index=array.find_index("right")
          if not index.nil?
            res[:right]=array[index+2].to_f
            next
          end
          index=array.find_index("error")
          if not index.nil?
            res[:error]=array[index+2].to_f
            next
          end
        end #reading lines
      end #open3
      return res
    end
    
    private :generate_script    
  end

  class SnnsFileWriter
    attr_reader :toolspath
    def initialize(extoolspath="")
      @toolspath=extoolspath
    end
    def write_header(exfilepath,num_pats,in_units,out_units)
      system @toolspath + "mkhead #{num_pats} #{in_units} #{out_units} > #{exfilepath}"
    end
    def write_footer(exfilepath)
      File.open(exfilepath, "a+") do |file|
        file.puts "#EOF\n"
      end
    end
  end
  
  class SnnsPatternWriter
    
    def write(pattern,file)
      line =""
      for i in 0..pattern.dimension-1 do
        line+=pattern[i].to_s + " "
      end
      
      file.puts line
      file.puts "\n"
      file.puts pattern.label
      file.puts "\n"
      
    end
    
  end
  
end