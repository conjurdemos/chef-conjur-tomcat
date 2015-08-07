policy 'tomcat_policy' do
  tokens = context['host_factory_tokens'] = {}

  secrets = [
    variable('database_password'),
    variable('api_key')
  ]

  layer 'tomcat_hosts' do |layer|
    secrets.each do |secret|
      secret.permit('execute', layer)
    end

    host_factory 'tomcat_hosts', layers: [layer], role: policy_role do |hf|
      tokens['tomcat_hosts'] = hf.create_token(Time.now + 7.days).token
    end
  end

  group 'devops' do |devops|
    secrets.each do |secret|
      secret.permit %w(read execute update), devops
    end
  end
end