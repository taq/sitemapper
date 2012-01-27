class ArrayTest < Array
   include SiteMapper

   class << self
      attr_accessor :values      
   end

   def initialize(values)
      self.class.values = values       
   end
end
