name 'iis'
description 'role for IIS webservers'
run_list 'recipe[mychef_client]','recipe[apache]'
override_attributes({'myiis' => {
  'company_name' => 'IIS Inc.'}
})