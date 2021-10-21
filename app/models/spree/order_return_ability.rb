class Spree::OrderReturnAbility
  include CanCan::Ability

  def initialize(user)
    can :create, Spree::ReturnAuthorization 
    can :create, Spree::InventoryUnit 
    can :create, Spree::ReturnItem 
  end

end