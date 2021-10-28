class AddReturnDaysToProducts < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_products, :return_days, :integer, default: 30, null: false

    Spree::Product.reset_column_information
    Spree::Product.all.each do |product|
      product.update_attribute(:return_days, 30)
    end
  end
end
