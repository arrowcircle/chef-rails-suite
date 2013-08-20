cookbook_path "cookbooks"
role_path     "roles"
data_bag_path "data_bags"
encrypted_data_bag_secret "#{ENV['HOME']}/.chef/data_bag_key"