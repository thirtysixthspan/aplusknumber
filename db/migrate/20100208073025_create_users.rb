class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :user_nid
      t.string :user_aid
      t.string :name
      t.string :location
      t.string :profile_image_url
      t.text :friends
      t.text :followers
      t.text :path

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
