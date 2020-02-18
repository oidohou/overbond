class AddTypeToOverbonds < ActiveRecord::Migration[6.0]
  def up

    execute <<-SQL
      CREATE TYPE bond_type AS ENUM ('corporate', 'government');
    SQL
 
    add_column :overbonds, :type, :bond_type
  end

  def down
    remove_column :overbonds, :type
    execute <<-SQL
      DROP TYPE bond_type;
    SQL
  end
end
