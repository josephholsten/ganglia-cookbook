
actions :enable, :disable

attribute :script_name, :kind_of => String, :name_attribute => true
attribute :options, :kind_of => Hash, :default => {}
attribute :minute, :kind_of => String, :default => '*' 
attribute :hour, :kind_of => String, :default => '*' 
attribute :day, :kind_of => String, :default => '*' 
attribute :month, :kind_of => String, :default => '*' 
attribute :weekday, :kind_of => String, :default => '*' 
