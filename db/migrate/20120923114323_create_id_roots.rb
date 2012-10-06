class CreateIdRoots < ActiveRecord::Migration
  def change
    create_table :id_roots, :primary_key => "user_name_d" do |t|
#      t.string :user_name_d
      t.string :redmine_url
      t.string :redmine_user_name
      t.string :redmine_password

      t.timestamps
    end

#    add_index :redmine_tables, [  ], unique: true
#    add_index :mindmeister_tables, [ :id, :map_id ], unique: true
  end
end
