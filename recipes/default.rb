include_recipe 'apt'
include_recipe 'build-essential'
include_recipe 'conjur-host-identity'
include_recipe 'conjur'

template '/etc/webapp1.xml' do
  source 'myapp.xml.erb'
  variables({
    :database_password => fetch_conjur_variable('demo/webapp1/database_password'),
    :api_token => fetch_conjur_variable('demo/webapp1/api_key')
  })
end
