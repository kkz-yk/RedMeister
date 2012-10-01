class CreateRedmeisterRelationships < ActiveRecord::Migration
  def change
    create_table :redmeister_relationships do |t|
      t.integer :project_id
      t.integer :map_id

      t.timestamps
    end
  end
end
