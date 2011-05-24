module MachineLearning

  class Parameter
    
    attr_reader :type, :values, :name,:set
    
    def initialize(ex_name)
      @name = ex_name
    end
    
    def set
      return @set.to_a
    end
    
    def numeric_range(nstart,nend,nincrement)
      @num_start = nstart
      @num_end= nend
      @increment = nincrement 
      @set = (@num_start..@num_end).step(@increment)
      @type = :range
    end
    
    def fix_set(array)
      @set = array
      @type = :set
    end
    
    def each
      @set.each &proc unless @type.nil?
    end
      
    
  end
  
end