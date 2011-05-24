module MachineLearning 

class DataPattern
  attr_accessor :label, :data, :dimension
 
  def initialize(ex_data,label_pos,ex_type)
    ex_data = ex_data.chomp.split if ex_data.kind_of? String
    @dimension=ex_data.size - 1 #the label is not a dimension
    @label = ex_data[label_pos]
    ex_data.delete_at(label_pos)
    @data = Hash.new
    @type = ex_type
    fill_data(ex_data)
  end

  def [](index)
    return @data[index] unless @data[index].nil?
    return 0  
  end
  
  def each
    for i in 0..@dimension do
      yield(self[i])
    end
  end
  
  def clone
    Marshal.load( Marshal.dump(self))
  end
  
  def <=> (o)
    case
      when @label > o.label 
        return 1
      when @label == o.label 
        return 0
      else 
        return -1
    end     
  end
  
  def to_s
    line =""
    for i in 0..@dimension-1 do
      line+=self[i].to_s + " "
    end
    line+= @label.to_s
  end
  
  def fill_data(ex_data)
    ex_data.each_index do |x| 
      unless (ex_data[x].nil? || ex_data[x] == 0 || ex_data[x] == 0.0)
        if @type == :string
           @data[x]=ex_data[x] 
        else
           @data[x]=ex_data[x].to_f
        end
      end
    end

  end
  
  private :fill_data
  
end

end
