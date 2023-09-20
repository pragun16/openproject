class AddTdFieldsToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :td_payback_likelihood_high, :float, default: 0.5
    add_column :projects, :td_payback_likelihood_medium, :float, default: 0.25
    add_column :projects, :td_payback_likelihood_low, :float, default: 0.1
    add_column :projects, :td_principal, :float
  end
end
