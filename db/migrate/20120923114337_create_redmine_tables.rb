class CreateRedmineTables < ActiveRecord::Migration
  def change
    create_table :redmine_tables do |t|
      t.integer :project_id, null: false
      t.integer :issue_id, null: false
      t.integer :parent_id, null: false
      t.string :subject, null: false

      t.timestamps
    end

#    add_index :Id_roots, [ :id, :project_id ], unique: true
  end
end
