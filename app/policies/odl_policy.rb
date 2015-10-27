class OdlPolicy < ApplicationPolicy
  def network_topology?
    logged_in?
  end
  def add_rule?
    logged_in?
  end
  def edit_rule?
    logged_in?
  end
  def remove_rule?
    logged_in?
  end
end
