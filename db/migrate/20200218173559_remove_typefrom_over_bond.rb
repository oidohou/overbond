class RemoveTypefromOverBond < ActiveRecord::Migration[6.0]
  def change
    remove_column :overbonds, :type
  end
end
