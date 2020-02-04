require('pg')
require_relative('../db/sql_runner')

class Screen
  attr_accessor :capacity
  attr_reader :id

  def initialize(options)
    @id = options["id"].to_i if options["id"]
    @capacity = options["capacity"].to_i
  end

  def save()
    sql = "INSERT INTO screens
    (capacity)
    VALUES
    ($1)
    RETURNING id"
    values = [@capacity]
    @id = SqlRunner.run(sql, values)[0]["id"].to_i
  end

  def update()
    sql = "UPDATE screens SET
    (capacity)
    = ($1)
    WHERE id = $2"
    values = [@capacity, @id]
    SqlRunner.run(sql, values)
  end

  def delete()
    sql = "DELETE FROM screens WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM screens WHERE id = $1"
    values = [id]
    return Screen.new(SqlRunner.run(sql, values)[0])
  end

  def self.all
    sql = "SELECT * FROM screens"
    screens = SqlRunner.run(sql)
    return screens.map {|screen| Screen.new(screen)}
  end

  def self.delete_all
    sql = "DELETE FROM screens"
    SqlRunner.run(sql)
  end
end
