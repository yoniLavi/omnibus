CURRENT_PATH = File.expand_path(File.dirname(__FILE__))
puts CURRENT_PATH
file_cache_path "#{CURRENT_PATH}/cache"
cookbook_path CURRENT_PATH 
