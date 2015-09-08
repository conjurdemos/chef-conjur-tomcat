include_recipe 'apt'
include_recipe 'build-essential'
include_recipe 'conjur-host-identity'
include_recipe 'conjur'

template '/etc/myapp.xml' do
  source 'myapp.xml.erb'
  variables({
    :database_password => fetch_conjur_variable('demo/tomcat_policy/database_password'),
    :api_token => fetch_conjur_variable('demo/tomcat_policy/api_key')
  })
end
