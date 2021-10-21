module Spree
  module Api
    module V2
      module Storefront
        class ReturnAuthorizationReasonsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          def index
            @reasons = Spree::ReturnAuthorizationReason.active.to_a
            render_serialized_payload { {"reasons": @reasons } }
          end

     		end
      end
    end
  end
end