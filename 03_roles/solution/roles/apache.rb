name 'apache'
description 'role for apache webservers'
run_list 'recipe[mychef_client]','recipe[apache]'
override_attributes({'apache' => {
  'company_name' => 'Apache Inc.'}
})