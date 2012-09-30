class CreateMindmeisterTables < ActiveRecord::Migration
  def change
    create_table :mindmeister_tables do |t|
     t.integer :map_id, null: false
      t.integer :idea_id, null: false
      t.string :title, null: false

      t.timestamps
    end

#    add_index :id_roots, [ :id, :map_id ], unique: true
  end
end
