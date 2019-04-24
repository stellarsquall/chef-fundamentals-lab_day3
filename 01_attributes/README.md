# User-Defined Attributes Lab Exercise
## Chef Fundamentals

In this exercise you will define a cookbook node attribute, and add it to your apache webserver.

## Defining Attributes

_Attributes are how cookbooks can be made data-driven, providing switches or "tunables" to be passed to recipe files._

* This exercise should be completed on your local workstation, within the ~/chef-repo directory.
  * Ask the instructor for setup instructions if needed.

1. So far, we've seen that node attributes are created during the chef-client run. These "automatic" attributes are provided by Ohai, and can be called within your recipe files.
   * These values can be utilized by calling the node object and referencing the attribute name:
     * `node['PARENT_ATTRIBUTE']['CHILD_ATTRIBUTE']`
     * `node['ipaddress']`
     * `node['memory']['total']`

2. We can also define our own node attributes, using policy like cookbooks.
   * Cookbook attributes are defined using [attributes files](https://docs.chef.io/attributes.html#use-attribute-files)
   * These files can be generated using the `chef generate attribute` command:
     * `chef generate attribute /path/to/cookbook NAME`
     * The NAME in this case is the name of the attributes file itself. It doesn't matter what you call this file, but you can separate file names by platform or functionality if desired. Most commonly this file is called "default". You can have as many attributes files as you like, and all attributes files are added to the node object.

3. Add an attributes file to the apache cookbook.
   * `cd ~/chef-repo/cookbooks/apache`
   * `chef generate attribute default`
   * Examine the files structure. You should see a new folder called attributes, with an empty default.rb inside.

4. The syntax for defining attributes is almost always:
   * `default['PARENT_ATTRIBUTE']['CHILD_ATTRIBUTE'] = 'ATTRIBUTE_VALUE'`
   * In general, it's best practice to name the parent attribute after the cookbook.
   * Here, default is the "precedence" of the attribute.
     * [Precedence](https://docs.chef.io/attributes.html#attribute-precedence) applies to the situation where an attribute with the same name is defined in multiple locations.
     * Attributes can be defined within:
       * Cookbook attributes files
       * Recipe
       * Roles
       * Environments
     * Because the same attribute can be defined in multiple locations, we need a method to determine which attribute "wins", and gets added to the node object.
     * The best way to understand this is to check the [Attributes Precedence Table](https://docs.chef.io/_images/overview_chef_attributes_table.png)
   * Precedence can be a confusing topic at first. For now, best practices are:
     * Define attributes within cookbooks, and if needed overwrite them from Roles or Environments.
     * Use `default` precedence levels unless you have a good reason not to. 
     * Name the parent attribute after the cookbook that creates it.

5. Define your first node attribute
   * To see this in action, open apache/attributes/default.rb
   * Add two default attributes, "company_name" and "company_user"
   * `default['apache']['company_name'] = 'MY_COMPANY_NAME'`
   * `default['apache']['user_name'] = 'MY_NAME'`
     * where you poulate MY_COMPANY_NAME and MY_NAME with your own values

6. Add these node attributes to your Hello, world page
   * You can now use these attributes in your recipes and templates
   * Open the templates/index.html.erb file, and add these attributes:
   ```
   <html>
     <body>
        <h1>Hello, world!</h1>
        <h2>Property of <%= node['apache']['company_user']%> from <%= node['apache']['user_name']%>
        <h2>platform: <%= node['platform'] %></h2>
        <h2>ipaddress: <%= node['ipaddress'] %></h2>
        <h2>memory: <%= node['memory']['total'] %></h2>
        <h2>cpu: <%= node['cpu']['0']['mhz'] %></h2>
     </body>
   </html>
   ```

7. Upload the cookbook, and deploy to the apache_web node
   * Use berks to upload the cookbook
     * First, update the version in the metadata.rb file to a new minor release.
     * Run `berks install` followed by `berks upload`
     * Check that the cookbook has been uploaded with `knife cookbook list`
   * Log into the apache_web cookbook and execute `sudo chef-client`
     * Alternatively, use the knife ssh commmand:
     * `knife ssh APACHE_WEB_IP -m -x chef -P PASSWORD 'sudo chef-client'`
       * Notes the --manual-list (-m) option is used to specify a list of IPs to run the command on, like 'IP1 IP2 IP3...'
   * Verify your results by checking your Hello, world page, or by using knife ssh to curl the localhost