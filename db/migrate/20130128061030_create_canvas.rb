class CreateCanvas < ActiveRecord::Migration
  def change
    create_table :canvas do |t|
      t.integer :w
      t.integer :h

      t.timestamps
    end
  end
end
