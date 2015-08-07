# chef-conjur-tomcat

An example of laying down Tomcat application properties files with Chef using secrets
from Conjur.

## Walkthrough

### 1. Apply the policy

Our security policy is defined in [policy.rb](policy.rb).
Read this before moving on.

Apply the policy:

```sh-session
$ conjur policy load --as-group security_admin --collection demo policy.rb
...
"host_factory_tokens": {
    "tomcat_hosts": "2qf26ke3e9yzrc1qdz6tv3bzv35p2c6669t22x89n52895xpf1569ks6"
  }
}
```

The long string here is your host-factory token, the bearer token that you will use to bootstrap
new hosts into the `tomcast_hosts` layer. The token is valid for 7 days, as defined in the policy.
You will use this token in Step 2.

### 2. Add values to your secrets

Our policy defined the names of secrets and permission on them, but did not give them an initial value.
That's why we can check out policy into source control, it contains no sensitive information.

Let's view our secrets with the Conjur CLI:

```sh-session
$ conjur variable list -i
"dustinops:variable:demo/tomcat_policy/database_password"
"dustinops:variable:demo/tomcat_policy/api_key"
```

We ran the policy with the collection 'demo', so that is our namespace.

This is how it breaks down.

|dustinops|variable|demo|tomcat_policy|database_password|
|---|---|---|---|---|
|Account|Type|Policy collection|Policy name|Variable name|

We can now add values to our secrets with the Conjur CLI.

```sh-session
$ conjur variable values add demo/tomcat_policy/database_password dy9hA6glyd8Tann5yEj5
$ conjur variable values add demo/tomcat_policy/api_key nUp3Ji4op1Hu6flEc3oj
```

### 3. Configure your Chef run

We'll export some variables to the environment that `.kitchen.yml` will
pass as attributes to the Chef run.

```
export CONJUR_HOST_FACTORY_TOKEN=<token from Step 1>
export CONJUR_HOST_IDENTITY="myhost5158" # choose a unique name

# These values are in your ~/.conjurrc
export CONJUR_ACCOUNT=<account>
export CONJUR_APPLIANCE_URL=<appliance_url>
export CONJUR_SSL_CERTIFICATE_PATH=<cert_file>
```

### 4. Run Chef

Converge the node with test-kitchen

```
kitchen converge
```

Our host has now been bootstrapped in the 'tomcat_hosts' layer.
You can verify its permissions in the Conjur UI at `/ui/hosts/myhost5158/`.

![Conjur UI host detail](https://i.imgur.com/dJwXhpn.png)


