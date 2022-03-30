require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    return @col unless @col.nil?
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT 1
    SQL
    @col = data[0].map {|val| val.to_sym}
  end

  def self.finalize!
    self.columns.each do |name|
      define_method(name) {
        self.attributes[name]
      }
      define_method("#{name}=") {|val|
        self.attributes[name] = val
      }
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.to_s.tableize
    @table_name 
  end

  def self.all
    # ...
    data = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    self.parse_all(data)
  end

  def self.parse_all(results)
    # ...
    results.map { |row|
      self.new(row)
    }
  end

  def self.find(id)
    # ...
    data = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = #{id}
    SQL
    data = self.parse_all(data)[0]
  end

  def initialize(params = {})
    # ...
    params.each do |k,v|
      unless self.class.columns.include?(k.to_sym)
        raise "unknown attribute '#{k}'"
      end
      self.send("#{k}=",v)
    end
  end

  def attributes
    # ...
    @attributes ||= Hash.new()
    @attributes
  end

  def attribute_values
    # ...
    self.class.columns.map {|key|
      self.send(key.to_sym)
    }
  end

  def insert
    # ...
    col_names = self.class.columns.join(",")
    filler = "(#{(["?"]*(self.class.columns.length)).join(",")})" 
    DBConnection.execute(<<-SQL,*self.attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      #{filler}
    SQL
    attributes[:id] = DBConnection.last_insert_row_id

  end

  def update
    # ...
    filler = self.class.columns.map {|val| "#{val} = ?"}.join(",")
    DBConnection.execute(<<-SQL,*self.attribute_values, self.attributes[:id])
    UPDATE
      #{self.class.table_name}
    SET
      #{filler}
    WHERE
      id = ?
    SQL

  end

  def save
    # ...
    if self.attributes[:id]
      update
    else
      insert
    end
  end
end
