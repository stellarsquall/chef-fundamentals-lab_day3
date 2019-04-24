# Roles Lab Exercise
## Chef Fundamentals

This exercise will give a general understand of using Roles to manage custom runlists for various types of nodes. In this example, we define two roles for our different webservers.

## Managing runlists with Roles

* This exercise should be completed on your local workstation, within the ~/chef-repo directory.
  * Ask the instructor for setup instructions if needed.

1. [Roles](docs.chef.io/roles.html) allow us to define job functions for a specific type of node, and allow for bulk configurations.
   * Roles consist of:
     * A runlist
     * Zero or more attributes
   * Nodes can have zero or more roles assigned to them
   * Roles can be created locally on the chef workstation, and then uploaded to the Chef Server, or directly on the Chef Server itself with the `knife role create` and `knife role edit` commands. The first option is preferable, as these roles can then be managed with source control.
     * Note: you can also create roles with the Chef Manage interface, but since this interface is not maintained this is not recommended. 

2. Role formats
   * Roles can be formatted in two ways: JSON, or a Ruby DSL
     * The DSL for Role files must contain these directives:
       * name
       * description
       * run_list
     * And can optionally include:
       * default_attributes
       * override_attributes
       * env_run_lists
   * Here's the content of the roles/starter.rb file that came with the starter kit:
   ```
   name "starter"
   description "An example Chef role"
   run_list "recipe[starter]"
   override_attributes({
   "starter_name" => "Your Name",
   })
   ```
   * These are the common options you'll set inside of your role files.

3. Let's create a role!
   * There is no generator for roles, or environments.
   * Create a new file inside of roles/ called apache.rb
   * Populate the roles/apache.rb file with:
     * A name of 'apache'. It's important that this matches the name of the file.
     * A description, something like 'role for apache webservers'
     * A run_list of `'recipe[mychef_client]','recipe[apache]'`
   * This is all that's required for the role, but you may wish to add some override attributes for fun.
     * Overwrite the `node['apache']['company_name']` attribute you created in the apache cookbook. Something like:
     ```
     override_attributes 'apache' => {
     'company_name' => 'Apache Inc.'
     }
     ```
     
4. Upload the role to the Chef Server
   * The `knife role` command is used to manage roles.
   * Upload the role:
     * `cd ~/chef-repo`
     * `knife role from file roles/apache.rb`
   * Check your work with `knife role list` and `knife role show apache`

5. Assign the role to the apache_web node
   * Runlists are managed with the `knife node run_list` command, as you've seen already.
   * Before, you assigned the apache cookbook to a node with:
     * `knife node run_list set apache_web 'recipe[apache]'`
   * Similarly, a role can be assigned with:
     * `knife node run_list set apache_web 'role[apache]'`
       * Note: runlists are not checked against the Chef Server, so be careful here, it's easy to make a typo
   * Check your work again with `knife node show apache_web`, you should see the role assigned under run_list
     * Note that the "roles" section is still empty

6. Execute the chef-client on apache_web
   * Once the chef-client has been run, verify your work again with `knife node show`
   * You should now see the role has been applied
   * How else can you check your work?
     * If you created default or override attributes, you can check the apache.company_name attribute and see if it's been overwritten
     * `knife node show apache_web -a apache.company_name`
     * Or simply check the output on your Hello, world page

7. Now create, assign, and apply another role for the iis_web node
   * Follow the same process for creating another role called `iis`
   * You can use the same structure for your role, but make sure the runlist is set to:
     * `'recipe[mychef_client]','recipe[myiis]'`
   * Upload the role to the Chef Server
   * Assign the role to iis_web
   * Run the chef-client on the node
     * Note: you RDP into the node or do this with the `knife winrm` command, but the structure is a little different from `knife ssh`
     * `knife winrm IIS_WEB_IP -m -x Administrator -P PASSWORD 'chef-client' -a cloud.ipv4`
       * This command utilizes the --attribute (-a) option to supply the public IP address for winrm. Unlike `knife ssh`, by default, `knife winrm` attempts to use the internal IP to connect.