# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SchemaNoDefaults, :config do
  context 'when send add_column' do
    it 'registers an offense when column has a default' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.integer :column, default: 1
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please dont default in the database, if you are using a default to migrate old data please call change_column_default afterwards to remove the default.
        end
      RUBY
    end
  end
end
