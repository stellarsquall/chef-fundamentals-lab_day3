# Environments Lab Exercise
## Chef Fundamentals

Here we create a couple of environments, upload them to the Chef Server, and apply them to our nodes to separate out cookbook versions.

## Separating out cookbook versions with environments

* This exercise should be completed on your local workstation, within the ~/chef-repo directory.
  * Ask the instructor for setup instructions if needed.

1. [Chef environments](https://docs.chef.io/environments.html) are a method for determining what versions of cookbooks should be deployed.
   * Structurally, an environment is very similar to a role, and is managed in the same way.
   * If no environment is assigned to a node, it is placed in the _default environment, which is unrestricted and cannot be modified or deleted.
   * Like roles, environments can contain default and override attributes
   * Environments consist of:
     * Zero or more cookbook version restrictions
     * Zero or more attributes
   * A node can only belong to one environment at a time.
   * Environments can be managed with `knife environment create` and `knife environment edit` commands, but like roles the best ways to manage them are with files to allow for source control.

2. Environment formats
   * Environments can be formatted with JSON or a Ruby DSL
     * The DSL for Environment files only need these directives:
       * name
       * description
     * And can optionally include:
       * cookbook
       * cookbook_versions 
       * default_attributes
       * override_attributes
   * Here's the content of the _default environment:
   ```
    name "_default"
    description "The default Chef environment"
   ```
   * If an environment has no restrictions, then any cookbook version can run within it.

3. Create a dev environment
   * This process is almost the same as managing roles.
   * We don't have an environments directory, so create one:
     * `cd ~/chef-repo`
     * `mkdir environments`
   * Now create a new file within environments called dev.rb
   * Populate environments/dev.rb with:
   ```
    name 'dev'
    description 'where code is tested'
   ```
   * Notice that there are no restrictions in this file. If a cookbook is not listed, its version is unrestricted, and the latest version available on the Chef Server will run in that environment. This is essentialls the same as the _default environment.

4. Upload the environment
   * This process is the same is roles, except you use the `knife environment` command.
     * `cd ~/chef-repo`
     * `knife environment from file environments/dev.rb`
   * Check your work with `knife environment list` and `knife environment show dev`

5. Assign it to the iis_web node
   * `knife node environment set iis_web dev`
   * Run the chef-client on the iis_web node
   * Verify your work:
     * `knife node show iis_web`
     * `knife node show iis_web -a environment`
   * No changes should be made, as the latest version of the cookbook should still be applied.

6. Now that you understand the process, create a production environment that restricts the version of the apache cookbook.
   * Create a new environment called production.rb
   * Restrict the cookbook for apache to the _previous_ version of the cookbook you uploaded to the chef server. If you're not sure what versions are available, run:
     * `knife cookbook show apache`
   * My previous version is `0.2.1`. If you don't have a new version just yet, then make a simple change to your Hello, world page and upload it to the Chef Server at a new version, like `0.3.0`. Remember, in the production environment it should be restricted to the _previous_ version.
   * Upload the environment to the Chef Server.
   * Assign it to the apache_web node
   * Run the chef-client on apache_web

7. Verify your work:
   * `knife node show apache_web`
   * `knife node show apache_web -a environment`
   * Ideally, you should check your work directly on the Hello, world page. The old version of the cookbook should have been applied.
   * You can also check the cookbooks attribute on the node:
     * `knife node show apache_web -a cookbooks`