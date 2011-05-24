module MachineLearning
  class BlankFileFormatter
    def header(*input)
    end
    def footer(*input)
    end   
  end
  
  class BlankSNNSPatternFormatter
    
    attr_accessor :formatted_length, :class_num
  
    def write(pattern)
      line =""
      for i in pattern.dimension do
        line+=pattern[i].to_s + " "
      end
      line+= @label.to_s
    end
  
    def read(input)
      return input
    end
    
    def class_format(type)
      line = "0 " * @class_num
      line[(type.to_i-1)*2] = "1" 
      return line
    end
    
    def format!(pattern)
      
      pattern.label = class_format(pattern.label)
      
      return pattern
    end   
  end
  
  class BlankSVMPatternFormatter
    
    attr_accessor :formatted_length, :class_num
    

    
    def write(pattern)
      line =""
      for i in pattern.dimension do
        line+=pattern[i].to_s + " "
      end
      line+= @label.to_s
    end
  
    def read(input)
      return input
    end
    
    def class_format(type)
      return type
    end
    
    def format!(pattern)
      
      pattern.label = class_format(pattern.label)
      
      return pattern
    end
    
  end
  

end
