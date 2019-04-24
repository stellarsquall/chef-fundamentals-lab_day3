name 'iis'
description 'role for IIS webservers'
run_list 'recipe[mychef_client]','recipe[myiis]'
default_attributes 'apache' => {
  'company_name' => 'IIS Inc.'
}