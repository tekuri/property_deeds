class Navigation < Netzke::Base

  js_base_class "Ext.tree.TreePanel"

  def configuration
    s = super
    s.merge(
        border: false,
        item_id: "navigation_container",
        split: true,
        tools: [:refresh],
        header: true,
        collapsible: true,
        title: navigation_title,
        layout: :fit,
        frame: true,
        width: 220,
        height: 150,
        margin: 0,
        root_visible: false,
        root: tree_nodes,
    )
  end

  js_method :init_component, <<-JS
    function() {
      this.callParent();
      this.loadHomePageComponent({}, function(component){
        this.loadNetzkeComponent({name: component, container: this.up().up().down("#main_panel")});
      }, this);
      this.getView().on('itemclick', function(e,r,i){
        if (r.raw.component) {
          this.loadNetzkeComponent({name: r.raw.component, container: this.up().up().down("#main_panel"),
            params: {component_params: r.raw.params}});
        }
      }, this);
    }
  JS

  js_method :after_render, <<-JS
    function() {
      this.callParent();
      var tree = this;
      this.onRefresh = function() {
        tree.refreshTree({}, function(nodes) {
          this.setRootNode(nodes);
        });
      }
    }
  JS

  endpoint :refresh_tree do |params|
    {set_result: tree_nodes}
  end

  endpoint :load_home_page_component do |params|
    if session[:home_page_component]
      sign_in_count = User.current.sign_in_count
      {set_result: (sign_in_count == 1)? "manage_profile" : session[:home_page_component].camelize}
    else
      {}
    end
  end

  def navigation_title
    user_role = User.current.role.role_name
    case user_role
      when 'Super Admin'
        "Admin Manager"
      when 'Sales Person'
        "#{User.current.full_name}, #{User.current.marketing_company_name}"
      else
        User.current.full_name
    end
  end

  def tree_nodes
    user_role = User.current.role.role_name.underscore.split(" ").join("_")
    settings = YAML::load(File.open("#{Rails.root}/config/navigations/#{user_role}_pages.yml"))
    session[:home_page_component] = settings['default']
    pages = settings['pages']
    {text: "Navigation", expanded: true,
     children: process_pages(pages)
    }
  end

  def process_pages(pages)
    pages.collect do |page|
      page["icon"] = get_icon_path(page)
      if page_has_children?(page)
        page["expanded"] = true
        page["children"] = process_pages(page["children"])
      else
        page["leaf"] = true
      end
      page
    end
    pages
  end

  def page_has_children?(page)
    page.include?("children")
  end

  def get_icon_path(page)
    uri_to_icon(page["icon"])
  end

  #component :orders_list, lazy_loading: true

=begin
  component :users_list do
    {
        class_name: "UsersList",
        lazy_loading: true,
        bbar: [:add_in_form.action, :edit_in_form.action] + (User.current.super_admin? ? [:del.action] : []),
        context_menu: [:add_in_form.action, :edit_in_form.action] + (User.current.super_admin? ? [:del.action] : [])
    }
  end

  component :company_users_explorer, lazy_loading: true

  component :companies_list, lazy_loading: true

  component :advertiser_companies_list, lazy_loading: true

  component :marketing_companies_list do
    {
        class_name: "MarketingCompaniesList",
        bbar: [:add_in_form.action, :edit_in_form.action, :del.action],
        context_menu: [:add_in_form.action, :edit_in_form.action, :del.action],
        lazy_loading: true
    }
  end

  component :marketing_company_advertisers_explorer, lazy_loading: true

  component :site_type_explorer, lazy_loading: true

  component :manage_profile, lazy_loading: true

  component :advertisers_explorer, lazy_loading: true
=end

end
