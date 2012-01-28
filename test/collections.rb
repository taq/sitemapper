class ArrayTest < Array
   def initialize(values)
      self.class.values = values       
   end
end
