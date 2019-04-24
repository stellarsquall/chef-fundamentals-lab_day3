# chef-client cookbook Lab Exercise
## Chef Fundamentals

Here we create a wrapper for the chef-client community cookbook.

## Best practices: Wrapper Cookbooks

_This exercise will be guided by your instructor. Check out the blog post [Writing Wrapper Cookbooks](https://blog.chef.io/2017/02/14/writing-wrapper-cookbooks/) to learn more about best practices._

* This exercise should be completed on your local workstation, within the ~/chef-repo directory.
  * Ask the instructor for setup instructions if needed.

1. This exercise will include creating a wrapper cookbook for the [chef-client](https://supermarket.chef.io/cookbooks/chef-client) community cookbook. Check out the readme to learn about what the recipes for the cookbook do.
   * First, generate a new cookbook called mychef_client:
     * `cd ~/chef-repo`
     * `chef generate cookbook cookbooks/mychef_client`
   * This is your "wrapper" cookbook, which you will setup with a dependency on the community cookbook.

2. Add a dependency on chef-client
   * [Dependencies](https://docs.chef.io/recipes.html#assign-dependencies) are managed within the metadata.rb file of a cookbook.
   * Open the mychef_client/metadata.rb file, and add this line below chef_version:
     * `depends 'chef-client'`
       * This statement allows us to resolve the latest version of the chef-client dependency that will be available on your Chef Server. There are many other restrictions on [cookbook versions](https://docs.chef.io/cookbook_versioning.html) you can use, such as:
         * `depends 'chef-client', '= 11.1.3'`
         * `depends 'chef-client', '>= 11'`
         * `depends 'chef-client', '~> 11.1'` (The _pessimistic operator_ shown here is very common)
   * Save the metadata file, and you've added a dependency! We will resolve it later with berks.

3. Now that the dependency has been added, we can begin coding as if we have access to it.
   * Adding a dependency give you access to its:
     * attributes
     * recipes
     * resources
     * libraries
   * Essentially, you can use any dependency content within the wrapper cookbook.

4. Wrapping dependency attributes
   * Wrapper cookbooks automatically take precedence over the dependency's default attributes.
   * This means you can add an attributes to your wrapper cookbook, and begin defining your own custom values to use within the recipes.
     * To understand why this works, you might check the loading order for cookbooks in Noah Kantrowitz's great blog post [Chef's Two-Pass Model](https://coderanger.net/two-pass/)
   * Take a look at the first two attributes on the [chef-client](https://supermarket.chef.io/cookbooks/chef-client) cookbook's readme:
     * `node['chef_client']['interval']` - Sets Chef::Config[:interval] via command-line option for number of seconds between chef-client daemon runs. Default 1800.
     * `node['chef_client']['splay']` - Sets Chef::Config[:splay] via command-line option for a random amount of seconds to add to interval. Default 300.
   * These values are used to determine how often the chef-client service should run (in seconds), and an offset for this interval.
     * Discussion: why is an offset (called the "splay") important, especially at a scale of hundreds or thousands of nodes?
   * These attributes can be defined in our wrapper cookbook to overwrite the default values listed above. 

5. Add the attributes file, define the interval and splay
   * Generate an attributes file:
     * `chef generate attribute cookbooks/mychef_client default`
   * Define the interval and splay attributes within attributes/default.rb:
   ```
   default['chef_client']['interval'] = '300'
   default['chef_client']['splay'] = '300'
   ```

6. Call the default recipe from the dependency
   * Now that we've customized our wrapper, we can execute the dependency's default functionality.
   * Open the mychef_client default recipe, and include chef-client::default
   ```
   include_recipe 'chef-client::default'
   ```
   * That's it! We've successfully wrapped the chef-client community cookbook, and provided it with our own custom values.

7. Upload the new cookbook to the Chef Server with berks:
   * `cd ~/chef-repo/cookbooks/mychef_client`
   * `berks install`
   * `berks upload`
   * `knife cookbook list` to check that it worked. Remember, berks upload will fail if you have any obvious syntax issues or misspell the names of methods like "depends" in the metadata.rb

8. Let's deploy the new cookbook to the apache_web node:
   * Add the cookbook to apache_web's runlist
     * Set the runlist for the node with:
       * `knife node run_list set apache_web 'recipe[mychef_client],recipe[apache]'`
         * Discussion: why are we setting the mychef_client cookbook to run first?
     * Check your work:
       * `knife node show apache_web`
   * Run the chef-client on apache_web
     * `knife ssh APACHE_WEB_IP -m -x chef -P PASSWORD 'sudo chef-client'`

9. Check your work
   * Discussion: how can we verify the changes?
     * Check the node object for the new attributes
     * You can do this with knife:
       * `knife node show apache_web --attribute chef_client`
     * Run this command on apache_web:
       * `ps awux | grep chef-client`
       * You can do this with knife ssh:
         * `knife ssh APACHE_WEB_IP -m -x chef -P PASSWORD "ps awux | grep chef-client"`