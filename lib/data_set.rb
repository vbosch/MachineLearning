require_relative './data_pattern'
require_relative './blank_formatters'
require 'ap'

module MachineLearning

class DataSet
  
  attr_accessor :file_writer, :line_writer, :line_formatter
  attr_reader :dimensions, :classes, :type, :pattern_set
  
  def initialize(exfilepath,exlabel_pos,ex_type)
    @pattern_set = Array.new
    @label_pos = exlabel_pos
    @file_path = exfilepath
    @sorted=false
    @labels = Hash.new
    @type = ex_type
    @line_formatter = BlankSNNSPatternFormatter.new
  end
  
  def read_data
    File.open(@file_path) do |file|
      while line = file.gets
        @pattern_set << DataPattern.new(@line_formatter.read(line),@label_pos,@type)
        @labels[@pattern_set.last.label] = 0 if @labels[@pattern_set.last.label].nil?
        @labels[@pattern_set.last.label] +=1
       # raise "Patterns with different input dimension space" if (@pattern_set.length > 1 && @pattern_set[@pattern_set.length-2].dimension != @pattern_set.last.dimension)
      end
    end
    if @line_formatter.class == MachineLearning::BlankSNNSPatternFormatter
      @line_formatter.formatted_length = self.dimensions 
      @line_formatter.class_num=@labels.length
    end
  end
  
  def set_data(data)
    @pattern_set=data  
    @pattern_set.each do |pattern|
      @labels[pattern.label] = 0 if @labels[pattern.label].nil?
      @labels[pattern.label] +=1
    end
  end
  
  def add! (set)  
    set.pattern_set.each do |pattern|
      @pattern_set << pattern.clone
      @labels[@pattern_set.last.label] = 0 if @labels[@pattern_set.last.label].nil?
      @labels[@pattern_set.last.label] +=1      
    end
  end
  
  def dimensions
    @pattern_set.last.dimension
  end
  
  def is_sorted?
    @sorted
  end
  
  def num_classes
    @labels.length
  end
  
  def classes
    @labels
  end
  
  def sort!
    @pattern_set.sort! unless @sorted
  end
  
  def shuffle!
    @pattern_set.shuffle!
    @sorted=false
  end
  
  def filter_classes(accepted_class_list)
    old_set = @pattern_set
    new_set = Array.new
    old_set.each do |pattern|
      new_set.push(pattern.clone) if accepted_class_list.include? pattern.label
    end
    result_set=DataSet.new(@file_path,@label_pos,@type)
    result_set.set_data new_set
    result_set.file_writer= @file_writer
    result_set.line_writer = @line_writer
    result_set.line_formatter = @line_formatter
    return  result_set
  end
  
  def filter_and_binarize_classes(accepted_class_list)
    old_set = @pattern_set
    new_set = Array.new
    old_set.each do |pattern|
      if accepted_class_list.include? pattern.label.to_i
        new_pat = pattern.clone
        if new_pat.label.to_i == accepted_class_list[0]
          new_pat.label = 1
        else
          new_pat.label = -1
        end
        new_set.push(new_pat) 
      end
    end
    result_set=DataSet.new(@file_path,@label_pos,@type)
    result_set.set_data new_set
    result_set.file_writer= @file_writer
    result_set.line_writer = @line_writer
    result_set.line_formatter = @line_formatter
    return  result_set
  end
  
  
  def to_file!(exfilepath)
    #deletes the file if it exists, forcefull file writing
    File.delete(exfilepath) if File.exists?(exfilepath)
    to_file(exfilepath)
  end
  
  def to_file(exfilepath)
    count =1
    raise "MC: Error #{exfilepath} file already exists " if File.exist?(exfilepath)
    @file_writer.write_header(exfilepath,@pattern_set.length,@line_formatter.formatted_length,self.num_classes)
    File.open(exfilepath, "a+") do |file|
      @pattern_set.each do |pattern| 
          pattern_copy=pattern.clone
          #file.puts "#Pattern : #{count}"
          count+=1
          @line_writer.write(@line_formatter.format!(pattern_copy),file)  
      end  
    end
    
    @file_writer.write_footer(exfilepath)
    
    
  end
  
  def clone
    return Marshal::load(Marshal.dump(self))
  end
  
  def partition(numparts)
    partitioned_set = Array.new(numparts)
    result_set=Array.new(numparts)
    partitioned_set.map!{Array.new}
    self.sort!
    work_set = @pattern_set.dup
    sorted_labels=@labels.sort
    sorted_labels.each do |set|
      key=set[0]
      value=set[1]
      subset_count = value/numparts
      remains = value%numparts
      for i in 0..numparts-1 do
        partitioned_set[i]<<work_set.slice!(0..(subset_count-1))
        if(remains > 0)
          partitioned_set[i]<<work_set.slice!(0)
          remains -=1
        end
      end
    end
    
  for i in 0..numparts-1 do 
    partitioned_set[i].flatten!
    partitioned_set[i].shuffle!
    result_set[i]=DataSet.new(@file_path,@label_pos,@type)
    result_set[i].set_data partitioned_set[i]
    result_set[i].file_writer= @file_writer
    result_set[i].line_writer = @line_writer
    result_set[i].line_formatter = @line_formatter
  end
  
  return result_set
    
  end
      
  def statistics
    
    ap self.classes

    ap self.dimensions
    
    #self.sort!
    class_statistics = Hash.new
    
    @labels.each_key{|key| class_statistics[key]=Array.new(self.dimensions,0) }
    
    class_statistics['global']=Array.new(self.dimensions,0)
    #mean by dimension by class
      @pattern_set.each do |pattern|
      class_statistics[pattern.label]=class_statistics[pattern.label].zip(pattern).map{|x,y| x+y}
      class_statistics['global']=class_statistics['global'].zip(pattern).map{|x,y| x+y}
    end
    
    @labels.each_key do |key|
      class_statistics[key].each_index{|index|class_statistics[key][index]/=@labels[key]}
    end
    class_statistics['global'].each_index{|index|class_statistics['global'][index]/=@pattern_set.size}
    
    ap class_statistics
    
    #standard deviation by dimension by class
    
    #covariance
    
    #eigen vectors
    
    #eigen values
  
  end
  

end

end
