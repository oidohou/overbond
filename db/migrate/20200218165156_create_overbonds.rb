class CreateOverbonds < ActiveRecord::Migration[6.0]
  def change
    create_table :overbonds do |t|
      t.string :bond
      t.decimal :term
      t.decimal :yield

      t.timestamps
    end
  end
end
