module MachineLearning
  
  class ChromosomePatternFormatter
    
    attr_accessor :max_length
    
    def initialize
      @max_length=-1
      @symbol_trans = {
        '0' => '0 0 0 0 0 0 0 0 0 0 0 ',
        '=' => '0 0 0 0 0 0 0 0 0 0 1 ',
        'A' => '0 0 0 0 0 0 0 0 0 1 0 ',
        'a' => '0 0 0 0 0 0 0 0 1 0 0 ',
        'B' => '0 0 0 0 0 0 0 1 0 0 0 ',
        'b' => '0 0 0 0 0 0 1 0 0 0 0 ',
        'C' => '0 0 0 0 0 1 0 0 0 0 0 ',
        'c' => '0 0 0 0 1 0 0 0 0 0 0 ',
        'D' => '0 0 0 1 0 0 0 0 0 0 0 ',
        'd' => '0 0 1 0 0 0 0 0 0 0 0 ',
        'E' => '0 1 0 0 0 0 0 0 0 0 0 ',
        'e' => '1 0 0 0 0 0 0 0 0 0 0 ',
      }
    end
    
    def class_format(type)
      line = "0 " * 22
      line[(type.to_i-1)*2] = "1" 
      return line
    end
    
    def data_format(data)
      
      diff=@max_length - (data.length)

      zero_add = "0"*(diff / 2)
      
      data = zero_add + data + zero_add
      
      data+='0' if diff % 2 == 1 #difference is odd we add one more zeros on the right side
      
      raise "Error size not equals" if @max_length != data.length
      
      #translate
      res=""
      
      data.chars.each do |c|
        
        res+=@symbol_trans[c]
        
      end
      return res
    end
    
    def format!(pattern)
      #formatting the data
      #ap pattern
      pattern.data[0]=data_format(pattern.data[0])
      #ap pattern
      #formatting the class 
      pattern.label = class_format(pattern.label)
      
      return pattern
    end
    
    def formatted_length
      @max_length * 11
    end
    
    def write(data,label)
      
      res=''
      
      return res
    end
    
    def read(input)
      
      temp_length = input.index(' ')+1
      @max_length = temp_length if temp_length > @max_length
      return input
    end
    
    private :class_format, :data_format
  end
  
end