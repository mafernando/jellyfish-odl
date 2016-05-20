class OdlPolicy < ApplicationPolicy
  def network_topology?
    logged_in?
  end
  def get_all_firewall_rules?
    logged_in?
  end
  def enable_video_policy?
    logged_in?
  end
  def disable_video_policy?
    logged_in?
  end
  def shift_drop_rule?
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
