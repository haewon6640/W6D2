require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
    filler = params.keys.map {|val| "#{val} = ?"}.join(" AND ")
    
    data = DBConnection.execute(<<-SQL,*params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{filler}
    SQL
    self.parse_all(data)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
