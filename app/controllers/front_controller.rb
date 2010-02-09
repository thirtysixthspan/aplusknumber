class FrontController < ApplicationController

  def index
    file = File.new("#{RAILS_ROOT}/completeness.dat", "r")
    @completeness = file.gets
    file.close
  end

  def get_number
    redirect_to :action=>'number', :id=>params[:id]
  end

def number
  user = User.find(:first,:conditions=>['user_aid = ?',params[:id]]) 
  if !user
    redirect_to "/not_yet_determined" and return
  else
    @id = user.user_aid
    @paths = Marshal.load(user.path)
    lengths = Array.new
    @paths.collect { |p| lengths.push(p.size) }
    @number = lengths.min-1    
  end
end

  def not_yet_determined
  end

end

