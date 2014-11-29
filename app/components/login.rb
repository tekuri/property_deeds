# The Login component
# Lets user type in their credentials, so they can authenticate themselves
class Login < Netzke::Basepack::Grid

  # Set the EXT JS class
  #js_base_class "Ext.Window"

  # Configure the component
  #
  # @return [Hash]


  def configure(c)
    super
    c.model = "User"
  end


=begin
  def configuration(c)
    puts Netzke::Core.controller.new_user_session_path(:format => :json)
    super.merge(
        :title => "Welcome to Propert Deeds Login",
        :layout => 'fit',
        :hidden => false,
        :width => 350,
        :padding => 20,
        :y => 100,
        :auto_height => true,
        :closable => false,
        :resizable => false,
        :items => [{
                       :xtype => :form,
                       :frame => true,
                       :buttons => ["<a href= #{Netzke::Core.controller.reset_password_path}>Forgot Password?</a>", :create_user_session.action],
                       :url => Netzke::Core.controller.new_user_session_path(:format => :json),
                       :default_type => :textfield,
                       :defaults => {
                           :anchor => '100%',
                           :allowBlank => false,
                           :enable_key_events => true,
                           :listeners => {
                               :special_key => <<-JS.l
                               function(field, e)
                                             {
                                               // if user presses ENTER => call onSignIn()
                                               if(e.getKey() == Ext.EventObject.ENTER)
                                               {
                                                 field.up('window').onCreateUserSession();
                                               }
                                             }
                               JS
                           }
                       },
                       :items => [{
                                      :name => 'user[email]',
                                      :field_label => User.human_attribute_name(:login)
                                  },{
                                      :name => 'user[password]',
                                      :field_label => User.human_attribute_name(:password),
                                      :input_type => :password
                                  }]
                   }]
    )
  end

  # Sign in button
  action :create_user_session, :text => "Login", :tooltip => "Click here to login", :form_bind => true
  #:icon => '/images/icons/actions/create_user_session.png'

  # On sign in
  # Success: Redirect to the path that the server returns
  # Failuer: Show alert
  js_method :on_create_user_session, <<-JS
    function() {
      var form = this.query('form')[0].getForm();
      if (form.isValid()) {
				form.submit({success: function(form, action) {
					 console.log("Success:");
					 console.log(action);
					 window.location = action.result.redirect_to;
				},
				failure: function(form, action) {
				console.log(action.result);
				if(action.result && action.result.first_name != null) {
					console.log("Failure: if");
					console.log(action);
					window.location = "/";
				} else {
				  console.log("Failure: else");
					console.log(action);
					Ext.Msg.alert("Error", "Invalid Email or Password.\\nPlease try again.");
				}
						//Ext.Msg.alert(action.result.errors.message, action.result.errors.reason);
				}});
      }
    }
  JS

  # Submit form on enter and set focus on login
  js_method :init_component, <<-JS
    function() {
      // Call parent
      this.callParent();

      // Get the login textfield
      var textfield = this.query('textfield')[0];

      // set focus on login textfield
      textfield.on('afterrender', function(){this.focus();})
    }
  JS

=end
end

