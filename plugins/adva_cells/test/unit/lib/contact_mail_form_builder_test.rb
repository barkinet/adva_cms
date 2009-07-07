require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ContactMailFormBuilderTest < ActiveSupport::TestCase

  def setup
    super
    @cm_builder = ContactMailFormBuilder.new
  end
    
  # add_field
  
    test "adds text field to the fields" do
      @cm_builder.add_field(text_field)
      assert @cm_builder.fields.first.is_a?(Tags::TextField)
    end
      
    test "adds text area to the fields" do
      @cm_builder.add_field(text_area)
      assert @cm_builder.fields.first.is_a?(Tags::TextArea)
    end
      
    test "adds radio button to the fields" do
      @cm_builder.add_field(radio_button)
      assert @cm_builder.fields.first.is_a?(Tags::RadioButton)
    end
      
    test "adds check box to the fields" do
      @cm_builder.add_field(check_box)
      assert @cm_builder.fields.first.is_a?(Tags::CheckBox)
    end
      
    test "adds select field to the fields" do
      @cm_builder.add_field(select)
      assert @cm_builder.fields.first.is_a?(Tags::Select)
    end
  
  # render_fields
  
    test "properly renders a text field" do
      expected = "<p>\n" + text_field_output + "</p>\n"
      @cm_builder.add_field(text_field)
      assert_equal expected, @cm_builder.render_fields
    end
  
    test "properly renders a text area" do
      expected = "<p>\n" + text_area_output + "</p>\n"
      @cm_builder.add_field(text_area)
      assert_equal expected, @cm_builder.render_fields
    end
  
    test "properly renders a radio button" do
      expected = "<p>\n" + radio_button_output + "</p>\n"
      @cm_builder.add_field(radio_button)
      assert_equal expected, @cm_builder.render_fields
    end
  
    test "properly renders a check box" do
      expected = "<p>\n" + check_box_output + "</p>\n"
      @cm_builder.add_field(check_box)
      assert_equal expected, @cm_builder.render_fields
    end
  
    test "properly renders a select field" do
      expected = "<p>\n" + select_output + "</p>\n"
      @cm_builder.add_field(select)
      assert_equal expected, @cm_builder.render_fields
    end
    
    test "does not render invalid fields" do
      @cm_builder.add_field(:type => 'text_field')
      assert_equal "", @cm_builder.render_fields
    end
  
  # Tags::TextField
    
    test "Tags::TextField creates a text field tag with a label" do
      text_field_tag = Tags::TextField.new(:name => 'subject', :value => 'default subject').render
      assert_equal text_field_output, text_field_tag
    end
    
    test "Tags::TextField is not valid without a name" do
      text_field = Tags::TextField.new()
      assert !text_field.valid?
    end

  # Tags::TextArea
    
    test "Tags::TextArea creates a text area tag with a label" do
      text_area_tag = Tags::TextArea.new(:name => 'body').render
      assert_equal text_area_output, text_area_tag
    end
    
    test "Tags::TextArea is not valid without a name" do
      text_area = Tags::TextArea.new()
      assert !text_area.valid?
    end

  # Tags::RadioButton
  
    test "Tags::RadioButton creates a radio button tag with a label" do
      radio_button_tag = Tags::RadioButton.new(:name => 'radio button', :checked => 'true', :value => '100').render
      assert_equal radio_button_output, radio_button_tag
    end
    
    test "Tags::RadioButton is not valid without a name" do
      radio_button = Tags::RadioButton.new(:value => '100')
      assert !radio_button.valid?
    end
    
    test "Tags::RadioButton is not valid without a value" do
      radio_button = Tags::RadioButton.new(:name => 'radio button')
      assert !radio_button.valid?
    end

  # Tags::CheckBox
  
    test "Tags::CheckBox creates a check box tag with a label" do
      check_box_tag = Tags::CheckBox.new(:name => 'check box', :label => 'Checkbox', :checked => 'true', :value => '100').render
      assert_equal check_box_output, check_box_tag
    end
    
    test "Tags::CheckBox is not valid without a name" do
      check_box = Tags::CheckBox.new(:value => '100')
      assert !check_box.valid?
    end
  
  # Tags::Select
  
    test "Tags::Select creates a select tag with a label" do
      options = { :option_tags => { "option" => [ { "value" => "1", "label" => "Good" },
                                                  { "value" => "2", "label" => "Bad"} ] } }
      select_tag = Tags::Select.new(options.merge(:name => "rating", :label => "Rate us!")).render
      assert_equal select_output, select_tag
    end
  
    test "Tags::Select creates a select tag with a label - also if option tags are inside of options and not on option_tags" do
      options = { :options => { "option" => [ { "value" => "1", "label" => "Good" },
                                              { "value" => "2", "label" => "Bad"} ] } }
      select_tag = Tags::Select.new(options.merge(:name => "rating", :label => "Rate us!")).render
      assert_equal select_output, select_tag
    end
    
    test "Tags::Select is not valid without a name" do
      select = Tags::Select.new(:option_tags => { "option" => [ { "value" => "1", "label" => "Good" },
                                                                { "value" => "2", "label" => "Bad"} ] })
      assert !select.valid?
    end
    
    test "Tags::Select is not valid without options" do
      select = Tags::Select.new(:name => "select")
      assert !select.valid?
    end

  def text_field
    { :name => "subject", :label => "Subject", :type => "text_field", :value => "default subject" }
  end
  
  def text_area
    { :name => "body", :label => "Body", :type => "text_area" }
  end
  
  def radio_button
    { :name => "radio button", :label => "Radio button", :type => "radio_button", :checked => "true", :value => '100' }
  end
  
  def check_box
    { :name => "check box", :label => "Checkbox", :type => "check_box", :checked => "true", :value => '100' }
  end
  
  def select
    { :type => "select", :name => "rating", :label=>"Rate us!",
      :options => { "option" => [ { "value" => "1", "label" => "Good" },
                                  { "value" => "2", "label" => "Bad"} ] }
    }
  end
  
  def label_output
    "\t<label for='contact_mail_subject'>Subject</label>\n"
  end
  
  def text_field_output
    label_output + "\t<input id=\"contact_mail_subject\" name=\"contact_mail[subject]\" type=\"text\" value=\"default subject\" />\n"
  end
  
  def text_area_output
    "\t<label for='contact_mail_body'>Body</label>\n\t<textarea id=\"contact_mail_body\" name=\"contact_mail[body]\"></textarea>\n"
  end
  
  def radio_button_output
    "\t<label for='contact_mail_radio_button'>Radio button</label>\n\t<input checked=\"checked\" id=\"contact_mail_radio_button_100\" name=\"contact_mail[radio_button]\" type=\"radio\" value=\"100\" />\n"
  end
  
  def check_box_output
    "\t<label for='contact_mail_checkbox'>Checkbox</label>\n\t<input checked=\"checked\" id=\"contact_mail_check_box\" name=\"contact_mail[check_box]\" type=\"checkbox\" value=\"100\" />\n"
  end
  
  def select_output
    "\t<label for='contact_mail_rate_us'>Rate us!</label>\n\t<select id=\"contact_mail_rating\" name=\"contact_mail[rating]\"><option value=\"1\">Good</option>\n<option value=\"2\">Bad</option></select>\n"
  end
end