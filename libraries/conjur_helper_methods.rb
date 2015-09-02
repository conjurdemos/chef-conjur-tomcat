module ConjurHelperMethods
  def fetch_conjur_variable(variable_name)
    require 'conjur/cli'
    Conjur::Config.load
    Conjur::Config.apply
    
    conjur = Conjur::Authn.connect nil, noask: true
    conjur.variable(variable_name).value
  end
end

class Chef::Recipe
  include ConjurHelperMethods
end
