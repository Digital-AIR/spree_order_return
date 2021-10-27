module SpreeOrderReturn
  module ProductSerializerDecorator
    def self.prepended(base)
      base.attributes :returnable, :return_days
    end
  end
end
	
Spree::V2::Storefront::ProductSerializer.prepend(SpreeOrderReturn::ProductSerializerDecorator)