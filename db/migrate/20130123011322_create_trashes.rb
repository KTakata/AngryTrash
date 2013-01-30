class CreateTrashes < ActiveRecord::Migration
  def change
    create_table :trashes do |t|
      t.integer :x
      t.integer :y

      t.timestamps
    end
  end
end
