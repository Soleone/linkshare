# MigrationsConstraints
module ActiveRecord
  
  module ConnectionAdapters
    
    class ConstraintDefinition < Struct.new(:base, :type, :table, :column)
      attr_accessor :options
      
      def initialize(base, type, table, column, options = {})
        super(base, type, table, column)
        @options = options
      end
      
      def [](name)
        @options[name]
      end
      
      def to_sql
        base.construct_constraint_clause(type, table.name, [column.name], options)
      end
      
    end
    
    class TableDefinition
      attr_accessor :name
      attr_reader :constraints
      
      def initialize(base, name)
        @columns = []
        @constraints = []
        @base = base
        @name = name
      end
      
      def column(name, type, options = {})
        # Next 7 lines copied directly from ActiveRecord 1.15.3
        column = self[name] || ColumnDefinition.new(@base, name, type)
        column.limit = options[:limit] || native[type.to_sym][:limit] if options[:limit] or native[type.to_sym]
        column.precision = options[:precision]
        column.scale = options[:scale]
        column.default = options[:default]
        column.null = options[:null]
        @columns << column unless @columns.include? column
        
        # Add constraints to this column as specified
        constraint :unique, column if options[:unique]
        constraint :foreign_key, column, :references => options[:references] if options[:references]
        constraint :check, column, :check => options[:check] if options[:check]
        self
      end
      
      def constraint(type, column, options = {})
        if constraint = find_constraint_by_name(options[:name])     
          constraint.options.merge(options)
        else
          column = self[column] unless column.is_a?(ColumnDefinition)
          @constraints << ConstraintDefinition.new(@base, type, self, column, options) if column
        end
        
        self
      end
      
      def to_sql
       (@columns + @constraints.map(&:to_sql)) * ', '
      end
      
      protected
      
      def find_constraint_by_name(name)
        @constraints.find {|constraint| constraint[:name].to_s == name.to_s } if name
      end
    end
    
    class AbstractAdapter
      
      CONSTRAINT_SUFFIX_MAP = {:unique => 'uq', :foreign_key => 'fkey', :check => 'check'}
      
      def default_constraint_name(table_name, type, parts)
        parts = [parts] unless parts.is_a?(Array)
        "#{table_name}_#{parts.join('_')}_#{CONSTRAINT_SUFFIX_MAP[type]}"
      end
      
      def construct_constraint_clause(type, table_name, column_or_columns, options = {})
        columns = column_or_columns.is_a?(Array) ? column_or_columns : [column_or_columns]
        quoted_column_names = columns.map {|cn| quote_column_name(cn)}.join(', ')
        
        name = options[:name] || default_constraint_name(table_name, type, columns)
        case type
        when :unique
          definition = "UNIQUE (#{quoted_column_names})"
        when :foreign_key
          references = options[:references]
          if references.is_a?(Hash)
            definition = "FOREIGN KEY (#{quoted_column_names}) REFERENCES #{references[:table]} (#{quote_column_name(references[:column])})"
          else
            definition = "FOREIGN KEY (#{quoted_column_names}) REFERENCES #{references} (#{quote_column_name('id')})"
          end
        when :check
          if check = options[:check]
            definition = "CHECK (#{quote_column_name(columns[0])} #{check})"
          end
        else
          raise "DefaultAdapter: Unknown constraint type #{type}"
        end
        
        "CONSTRAINT #{quote_column_name(name)} #{definition}" if definition
      end
      
    end
    
    module SchemaStatements
      
      def create_table(name, options = {})
        table_definition = TableDefinition.new(self, name)
        table_definition.primary_key(options[:primary_key] || "id") unless options[:id] == false
        
        yield table_definition
        
        if options[:force]
          drop_table(name, options) rescue nil
        end
        
        create_sql = "CREATE#{' TEMPORARY' if options[:temporary]} TABLE "
        create_sql << "#{name} ("
        create_sql << table_definition.to_sql
        create_sql << ") #{options[:options]}"
        execute create_sql
      end
      
      def add_constraint(table_name, options = {})
        constraint_clause = case
        when columns = options[:unique]
          construct_constraint_clause(:unique, table_name, columns, options)
        when columns = options[:foreign_key]
          construct_constraint_clause(:foreign_key, table_name, columns, options)
        when check = options[:check]
          check = "(#{check})" unless check =~ /\A\(.+\)\Z/
          "CONSTRAINT #{quote_column_name(options[:name])} CHECK #{check}" if options[:name]
        end
        
        if constraint_clause
          execute "ALTER TABLE #{table_name} ADD #{constraint_clause}"
        else
          raise "Don't know how to create constraint for #{options.inspect}!"
        end
      end
      
      def drop_constraint(table_name, options = {})
        name = options[:name] || case
        when options[:unique]
          default_constraint_name(table_name, :unique, options[:unique])
        when options[:foreign_key]
          default_constraint_name(table_name, :foreign_key, options[:foreign_key])
        when options[:check]
          default_constraint_name(table_name, :check, options[:check])
        else
          raise "Unknown constraint type for #{options.inspect}!"
        end
        
        execute "ALTER TABLE #{table_name} DROP CONSTRAINT #{name}"
      end
    end
    
  end
  
end
