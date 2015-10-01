class OdlPolicy < ApplicationPolicy
  def network_topology?
    logged_in?
  end
end
