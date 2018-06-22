require "sinatra/base"
require "open3"

# XML
require "nori"
require "nokogiri"

require_relative "nav"
require_relative "job"

class App < Sinatra::Base
  
  configure do
     set :erb, :escape_html => true
   end

  def title
    "User Statistics"
  end
  
  before do
    @path = request.path_info
    @navlinks = [ NavLink.new("/home_dir", "Home Directory", "home"),
                  NavLink.new("/find_file", "Search Directory or User", "search"),
                  NavLink.new("/all", "View All Jobs", "users"),
                  NavLink.new("/help", "Help", "question")]
  end

  get "/" do
    @pagetitle = title
    erb :index
  end
  
  get "/search" do
    @pagetitle = "Search for a User"
    erb :search
  end
  
  get "/search_user" do
    @user = params[:user]
    redirect url("/user/#{@user}")
  end
  
  get "/all" do
    @pagetitle = "All Users"
    @output = Job.get_jobs
    erb :jobs
  end
  
  get "/help" do
    @pagetitle = title + " Help"
    erb :help
  end
  
  get "/user/" do
    @pagetitle = "Error"
    @error = "Error: no user selected. For all users, try /all."
    redirect to "/"
  end

  get "/user/:user" do
    @user = params[:user]
    @pagetitle = "#{@user}'s Jobs"
    user_jobs = Job.get_jobs(@user)
    
    # FILES
    path = Pathname.new("~jnicklas/home.json").expand_path 
    data = path.read
    json = JSON.parse(data)["quotas"]
    filtered = json.select {|x| x["user"] == "#{params[:user].to_s.strip}"}
    unless filtered.empty? 
      filtered = filtered[0]
      @user = filtered["user"]
      @file_limit = filtered["file_limit"]
      @block_limit = filtered["block_limit"]
      @total_block_usage = filtered["total_block_usage"]
      @total_file_usage = filtered["total_file_usage"]
      @blckcalc = ((@total_block_usage.to_f / @block_limit) * 100).round(2)
      @filecalc = ((@total_file_usage.to_f / @file_limit) * 100).round(2)
    else
      @output = []
      @filecalc = 0
      @blckcalc = 0
      @error = "No user process find for user #{params[:user].to_s.strip}"
    end
    # FILES END
    
    @output = user_jobs
    erb :user
  end
  
  # File Sub-App
  
  get "/find_file" do
    @pagetitle = "Locate Files/User"
    erb :dir_form
  end
  
  get "/files" do
    #@number = params[:file_number]
    @pagetitle = "File Information"
    @output = %x(du -x -h -a -S "#{params[:file].to_s.strip}"| sort -h -r | head -n 10).split("\n")
    @modified = []
    @output.each do |x|
        a = x.index("\t") + 1
        b = x.length -  1
        c = x[a , b]
        @modified.push(%x{date -r "#{c}"})
    end
    erb :files
  end
  
  get "/home_dir" do
    @pagetitle = "Number of Files Displayed from Your Home Directory"
    erb :home_form
  end
  
  get "/home_files" do
   @pagetitle = "File Information"
   @number = params[:file_number]
   @output = %x(du -x -h -a -S ~| sort -h -r | head -n "#{@number}").split("\n")
   @modified = []
   @output.each do |x|
        a = x.index("\t") + 1
        b = x.length -  1
        c = x[a , b]
        @modified.push(%x{date -r "#{c}"})
    end
    erb :files
  end
end
