require 'rubygems'
require 'active_record'
require 'twitter'


class User < ActiveRecord::Base
  set_table_name 'users'
  set_primary_key 'id'
end

class Rsearch

  def initialize
    @httpauth = Twitter::HTTPAuth.new('okcCoCo', '')
    @base = Twitter::Base.new(@httpauth)
    @max_depth = 2
  
    
    ActiveRecord::Base.establish_connection(
      :adapter  => "mysql",
      :socket => "/var/run/mysqld/mysqld.sock",
      :database => "aksearch",
      :username => "aksearch",
      :password => "aksearch"
    )

    initialize_database()

  end

  def initialize_database

    if !User.table_exists? 
      ActiveRecord::Schema.define do 
        create_table :users do |t|
          t.column :user_nid, :integer
          t.column :user_aid, :string
          t.column :name, :string
          t.column :location, :string
          t.column :profile_image_url, :string
          t.column :friends, :text
          t.column :followers, :text
          t.column :path, :text
        end
      end
    end

  end  


  def search(source,target,max_depth)
    max_depth.times do |depth|
      file = File.new("completeness.dat", "w")
      file.puts depth
      file.close

      @max_depth = depth+1
      path = get_path([source],[target],1)
      return path if path.last==-1 
    end
    return []
  end

  def get_friends(user)
    if user.friends && user.friends!=""    
      begin
        return Marshal.load(user.friends)
      rescue
      end
    end

    begin
      friends = @base.friend_ids(:id => user.user_nid)
    rescue
      return []
    end

    user.friends = Marshal.dump(friends)
    user.save

    return friends
  end

  def get_path(source,target,depth)
    ids = target
    ids.each do |id| 
      print "#{id}-"
    end

    user=get_user(ids.last,ids)  

    if user==nil || user.name==nil    
      ids.pop
      return ids
    end

    puts user.user_aid

    friends=get_friends(user)

    if friends.include?(source.last)
      ids << source.last      
      ids << -1      
      return ids
    end

    if depth>=@max_depth    
      ids.pop
      return ids
    end

    friends.each do |id|
      next if ids.include?(id)

      attempt_ids = ids
      attempt_ids << id
      path = get_path(source, attempt_ids, depth+1)

      return path if path.last == -1    
    end
  
    ids.pop
    return ids
  end

  def get_id(name)
    current_user = User.find_by_user_aid(name)
    if current_user
      return current_user.user_nid
    end
    
    begin
      u = Twitter.user(name)
    rescue
      return nil
    end

    current_user = User.new
    current_user.name = u[:name]
    current_user.user_nid = u[:id]      
    current_user.user_aid = u[:screen_name]      
    current_user.location = u[:location]      
    current_user.profile_image_url = u[:profile_image_url]      
    current_user.path=Marshal.dump([])
    current_user.save


    return u[:id]

  end

  def get_screen_name(id)
    current_user = User.find_by_user_nid(id)
    if current_user
      return current_user.user_aid
    end
    
    begin
      u = Twitter.user(id)
    rescue
      return -1
    end

    current_user = User.new
    current_user.name = u[:name]
    current_user.user_nid = u[:id]      
    current_user.user_aid = u[:screen_name]      
    current_user.location = u[:location]      
    current_user.profile_image_url = u[:profile_image_url]      
    current_user.path=Marshal.dump([])
    current_user.save

    return current_user.user_aid

  end

  def get_user(id,path)
    current_user = User.find_by_user_nid(id)

    if current_user
      current_user.path = Marshal.dump(Marshal.load(current_user.path).push(path))
      return current_user if current_user
    end
 
    begin
      u = Twitter.user(id)
    rescue
      return nil
    end

    current_user = User.new
    current_user.name = u[:name]
    current_user.user_nid = u[:id]      
    current_user.user_aid = u[:screen_name]      
    current_user.location = u[:location]      
    current_user.profile_image_url = u[:profile_image_url]      
    current_user.path = Marshal.dump([path])
    current_user.save

    return current_user
  end

  def delete_user(id)
    current_user = User.find_by_user_nid(id)
    return false if !current_user
    current_user.delete
    return true
  end

  def list_users_in_db
    @users = User.find(:all)
    @users.each do |user| 
      puts user.name   
    end
  end

end


r = Rsearch.new
r.initialize_database

target =  r.get_id('aplusk')

followers = r.search(0,target,3)

followers.each do |f|
  current_user = User.find_by_user_nid(f)
  puts "#{current_user.name} #{current_user.user_nid} #{current_user.user_aid}" unless f==-1
end
puts ""
