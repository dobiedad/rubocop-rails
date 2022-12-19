# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      class SchemaNoDefaults < Base
        include ActiveRecordMigrationsHelper

        RESTRICT_ON_SEND = %i[add_column create_table].freeze
        MESSAGE = 'Please dont default in the database, if you are using a default to migrate old data please call change_column_default afterwards to remove the default.'
        CREATE_TABLE_COLUMN_METHODS = Set[
          *(
            RAILS_ABSTRACT_SCHEMA_DEFINITIONS |
            RAILS_ABSTRACT_SCHEMA_DEFINITIONS_HELPERS |
            POSTGRES_SCHEMA_DEFINITIONS |
            MYSQL_SCHEMA_DEFINITIONS
          )
        ].freeze

        # @!method default_present?(node)
        def_node_matcher :default_present?, <<~PATTERN
          (hash <(pair {(sym :default) (str "default")} (_ [present?])) ...>)
        PATTERN

        # @!method create_table?(node)
        def_node_matcher :create_table?, <<~PATTERN
          (send nil? :create_table _table _?)
        PATTERN

        # @!method t_column_with_default?(node)
        def_node_matcher :t_column_with_default?, <<~PATTERN
          (send _var CREATE_TABLE_COLUMN_METHODS _column _type? #default_present?)
        PATTERN

        def on_send(node)
          add_offense(node.parent.body, message: MESSAGE) if table_includes_default?(node)
        end

        private

        def table_includes_default?(node)
          create_table?(node) && t_column_with_default?(node.parent.body)
        end
      end
    end
  end
end
