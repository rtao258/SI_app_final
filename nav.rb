require "sinatra/base"

class NavLink
  attr_accessor :path, :text, :icon
  
  def initialize (path, text, icon="")
    @path = path
    @text = text
    @icon = icon
  end
  
  def active (current_path)
    current_path == @path ? "active" : ""
  end
end
