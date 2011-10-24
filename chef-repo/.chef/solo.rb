current_dir = File.dirname(__FILE__)
file_cache_path "#{current_dir}/cache"
file_backup_path "#{current_dir}/backup"
cache_options     ({:path => "#{current_dir}/cache/checksums", :skip_expires => true})
cookbook_path "#{current_dir}/../cookbooks"
