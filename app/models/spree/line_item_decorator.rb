module Spree
  module LineItemDecorator
  	def returnable
       	variant.product.returnable
    end

    def return_days
       	variant.product.return_days
    end

    Spree::LineItem.prepend Spree::LineItemDecorator
  end
end