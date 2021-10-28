module Spree
  module ProductDecorator
  	def self.prepended(base)
      base.validates :return_days, numericality: { greater_than_or_equal_to: 0 }
	  base.scope :returnable, -> { where(returnable: true) }
    end

    Spree::Product.prepend Spree::ProductDecorator
  end
end