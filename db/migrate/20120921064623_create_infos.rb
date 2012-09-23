class CreateInfos < ActiveRecord::Migration
  def change
    create_table :infos do |t|
      t.string :user_name_d
      t.string :password_d

      t.timestamps
    end
  end
end
