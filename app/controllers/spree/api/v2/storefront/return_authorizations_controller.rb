module Spree
  module Api
    module V2
      module Storefront
        class ReturnAuthorizationsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers
          include Spree::BaseHelper

          before_action :require_spree_current_user, only:[:create]

          def returned_items
            render_serialized_payload { {"data": {"returned_items": order.return_items.map(&:inventory_unit)} } }
          end 

          def create            
            if order.shipment_state == "shipped"
              for li in params[:return_items] do
                for shipment in order.shipments
                  line_item =  shipment.line_items.select{|hash| hash['variant_id'] == li[:variant_id]}
                  if line_item.any?
                    if line_item.first.product.returnable == true
                      if Time.current > shipment.shipped_at + line_item.first.product.return_days.days
                        return render_serialized_payload { {"data":  "Return days exceeded, can not return variant id " + li[:variant_id].to_s} }
                      end
                    else 
                      return render_serialized_payload { {"data":  "Variant id " + li[:variant_id].to_s + " is not returnable"} }
                    end
                  end
                end
              end
            else
              return render_serialized_payload { {"data":  "Order is not shipped"} }
            end            

            for ri in params[:return_items] do
              inventory_ids = []
              for inventory in order.inventory_units
                if inventory[:variant_id] == ri[:variant_id]
                  inventory_ids.push(inventory[:id])
                end
              end

              main_inventory_unit = order.inventory_units.select{|hash| hash['id'] == inventory_ids.min}
              item = order.line_items.select{|hash| hash['variant_id'] == main_inventory_unit.first[:variant_id]}

              if main_inventory_unit.first[:quantity] > ri[:quantity]
                left_qty = main_inventory_unit.first[:quantity].to_f - ri[:quantity].to_f
                new_inventory_unit = Spree::InventoryUnit.new()
                new_inventory_unit.state = main_inventory_unit.first[:state]
                new_inventory_unit.variant_id = main_inventory_unit.first[:variant_id]
                new_inventory_unit.order_id = main_inventory_unit.first[:order_id]
                new_inventory_unit.shipment_id = main_inventory_unit.first[:shipment_id]
                new_inventory_unit.pending = main_inventory_unit.first[:pending]
                new_inventory_unit.line_item_id = main_inventory_unit.first[:line_item_id]
                new_inventory_unit.quantity = ri[:quantity].to_f
                new_inventory_unit.save

                update_inventory_unit = Spree::InventoryUnit.find(main_inventory_unit.first[:id])
                update_inventory_unit.quantity = left_qty
                update_inventory_unit.save
                return_authorization = create_return_authorizations(main_inventory_unit, ri)
                if return_authorization.persisted?
                  return_items = Spree::ReturnItem.new() 
                  return_items.return_authorization_id = return_authorization.id
                  return_items.inventory_unit_id = new_inventory_unit.id
                  return_items.pre_tax_amount = (item.first[:price].to_f * ri[:quantity]).round(2)
                  return_items.save
                end

              elsif main_inventory_unit.first[:quantity] == ri[:quantity]
                return_authorization = create_return_authorizations(main_inventory_unit, ri)
                if return_authorization.persisted?
                  return_items = Spree::ReturnItem.new() 
                  return_items.return_authorization_id = return_authorization.id
                  return_items.inventory_unit_id = main_inventory_unit.first[:id]
                  return_items.pre_tax_amount = (item.first[:price].to_f * ri[:quantity]).round(2)
                  return_items.save
                end
              else 
                return render_serialized_payload { {"data":  "Qunatity exceeded for variant id " +  ri[:variant_id].to_s} }
              end
            end    
            render_serialized_payload { {"data": {"returned_items": order.return_items.map(&:inventory_unit)} } }

            #in case if you want to render return_authorizations, return_items, inventory_units data
            # render_serialized_payload { {"data": {"return_authorizations": order.return_authorizations, "return_items": order.return_items,"inventory_units": order.inventory_units} } }

          end

          private

          def create_return_authorizations(main_inventory_unit, ri)
            return_authorization = order.return_authorizations.build()
            return_authorization.state = "authorized"
            return_authorization.order_id = order.id
            return_authorization.memo = ri[:memo]
            return_authorization.return_authorization_reason_id = ri[:return_authorization_reason_id]
            return_authorization.stock_location_id = main_inventory_unit.first.shipment.stock_location_id
            return_authorization.save
            return return_authorization
          end

          def order
            @order ||= Spree::Order.find_by!(number: params[:order_number])
            authorize! :show, @order
          end

     		end
      end
    end
  end
end