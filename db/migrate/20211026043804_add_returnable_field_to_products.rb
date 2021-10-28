class AddReturnableFieldToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products, :returnable, :boolean, default: false
  end
end
