class Pages
	#attr_accessible :query
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  
  validates :query, :presence => :true 
		
	
	def persisted?
		false
	end
	
	
end
