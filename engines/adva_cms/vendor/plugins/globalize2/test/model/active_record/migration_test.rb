require File.join( File.dirname(__FILE__), '..', '..', 'test_helper' )
require 'active_record'
require 'globalize/model/active_record'

# Hook up model translation
ActiveRecord::Base.send(:include, Globalize::Model::ActiveRecord::Translated)

# Load Post model
require File.join( File.dirname(__FILE__), '..', '..', 'data', 'models' )

class MigrationTest < ActiveSupport::TestCase
  def setup
    reset_db! File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'data', 'no_globalize_schema.rb'))
  end

  test 'globalize table added' do
    assert !Post.connection.table_exists?( :post_translations )
    assert !Post.connection.index_exists?( :post_translations, :post_id )
    Post.create_translation_table! :subject => :string, :content => :text
    assert Post.connection.table_exists?( :post_translations )
    assert Post.connection.index_exists?( :post_translations, :post_id )
    columns = Post.connection.columns( :post_translations )
    assert locale = columns.detect {|c| c.name == 'locale' }
    assert_equal :string, locale.type
    assert subject = columns.detect {|c| c.name == 'subject' }
    assert_equal :string, subject.type
    assert content = columns.detect {|c| c.name == 'content' }
    assert_equal :text, content.type
    assert post_id = columns.detect {|c| c.name == 'post_id' }
    assert_equal :integer, post_id.type
    assert created_at = columns.detect {|c| c.name == 'created_at' }
    assert_equal :datetime, created_at.type
    assert updated_at = columns.detect {|c| c.name == 'updated_at' }
    assert_equal :datetime, updated_at.type
  end

  test 'globalize table dropped' do
    assert !Post.connection.table_exists?( :post_translations )
    assert !Post.connection.index_exists?( :post_translations, :post_id )
    Post.create_translation_table! :subject => :string, :content => :text
    assert Post.connection.table_exists?( :post_translations )
    assert Post.connection.index_exists?( :post_translations, :post_id )
    Post.drop_translation_table!
    assert !Post.connection.table_exists?( :post_translations )
    assert !Post.connection.index_exists?( :post_translations, :post_id )
  end

  test 'exception on missing field inputs' do
    assert_raise Globalize::Model::MigrationMissingTranslatedField do
      Post.create_translation_table! :content => :text
    end
  end

  test 'exception on bad input type' do
    assert_raise Globalize::Model::BadMigrationFieldType do
      Post.create_translation_table! :subject => :string, :content => :integer
    end
  end

  test "exception on bad input type isn't raised for untranslated fields" do
    assert_nothing_raised do
      Post.create_translation_table! :subject => :string, :content => :string, :views_count => :integer
    end
  end

  test 'create_translation_table! should not be called on non-translated models' do
    assert_raise NoMethodError do
      Blog.create_translation_table! :name => :string
    end
  end

  test 'drop_translation_table! should not be called on non-translated models' do
    assert_raise NoMethodError do
      Blog.drop_translation_table!
    end
  end
  
  test "translation_index_name returns a readable index name when it's not longer than 50 characters" do
    assert_equal 'index_post_translations_on_post_id', Post.send(:translation_index_name)
  end
  
  test "translation_index_name returns a hashed index name when it's longer than 50 characters" do
    class UltraLongModelName1337Haxx0rWeirdShit < ActiveRecord::Base
      translates :foo
    end
    expected = 'index_7edb636852ae9af3dc2928a13ccb14f7f0df5a93'
    actual = UltraLongModelName1337Haxx0rWeirdShit.send(:translation_index_name)

    assert_equal expected, actual
  end

end