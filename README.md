# chef-conjur-tomcat

Inserting secrets into a Tomcat application property file using Chef and Conjur.

In this tutorial, we'll:

1. Create a host-factory that can bootstrap Conjur hosts into a layer
2. Give that layer access to two secrets
3. Converge a Chef run that:
    1. Assigns an identity to the host, given a host-factory token
    2. Inserts secrets into a Tomcat appliation property file

## Setup

You'll need a Conjur appliance running and accessible from your workstation.
[Contact us](mailto:info@conjur.net) for one if you don't already have it.

1. Install the [ChefDK](https://downloads.chef.io/chef-dk/).
We'll use [test-kitchen](http://kitchen.ci/) and [berkshelf](http://berkshelf.com/) to converge the node.
2. Install [Docker](http://docs.docker.com/).
If you're on OSX, use [docker-machine](https://docs.docker.com/machine/) or [boot2docker](http://boot2docker.io/) to create a VM.
3. Install the [kitchen-docker](https://github.com/portertech/kitchen-docker) driver.

    ```sh-session
    $ chef gem install kitchen-docker
    ```

## Tutorial

### 1. Apply the Conjur policy

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
You will use this token in Step 3.

### 2. Add values to your secrets

Our policy defined the names of secrets and permissions to them, but did not give them an initial value.
That's why we can check our policy into source control, it contains no sensitive information.

Let's view our secrets with the Conjur CLI:

```sh-session
$ conjur variable list -i
"dustinops:variable:demo/tomcat_policy/database_password"
"dustinops:variable:demo/tomcat_policy/api_key"
```

We applied the policy with the collection 'demo', so that is our namespace.

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

Log into the host and view the property file. It now contains the values you entered
for the variables defined in your policy.

```sh-session
$ kitchen login  # use 'kitchen' as the password if prompted
$ cat /etc/myapp.xml
<Context docBase="${basedir}/src/main/webapp" reloadable="true">
  <!-- http://tomcat.apache.org/tomcat-7.0-doc/config/context.html -->
  <Parameter name="database_password" value="dy9hA6glyd8Tann5yEj5"/>
  <Environment name="app.devel.api" value="nUp3Ji4op1Hu6flEc3oj" type="java.lang.String" override="true"/>
</Context>
```


