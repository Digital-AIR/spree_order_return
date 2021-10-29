module SpreeOrderReturn
  module LineItemSerializerDecorator
    def self.prepended(base)
      base.attributes :returnable, :return_days
    end
  end
end
	
Spree::V2::Storefront::LineItemSerializer.prepend(SpreeOrderReturn::LineItemSerializerDecorator)