require('pg')
require_relative('../db/sql_runner')

class Film
  attr_accessor :title, :price
  attr_reader :id

  def initialize(options)
    @id = options["id"].to_i if options["id"]
    @title = options["title"]
    @price = options["price"].to_i
  end

  def save()
    sql = "INSERT INTO films
    (title, price)
    VALUES
    ($1, $2)
    RETURNING id"
    values = [@title, @price]
    @id = SqlRunner.run(sql, values)[0]["id"].to_i
  end

  def update()
    sql = "UPDATE films SET
    (title, price)
    = ($1, $2)
    WHERE id = $3"
    values = [@title, @price, @id]
    SqlRunner.run(sql, values)
  end

  def delete()
    sql = "DELETE FROM films WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def customers()
    sql = "SELECT customers.* FROM customers
    INNER JOIN tickets
    ON customers.id = tickets.customer_id
    WHERE film_id = $1"
    values = [@id]
    customers = SqlRunner.run(sql, values)
    return customers.map {|customer| Customer.new(customer)}
  end

  def number_of_customers()
    return self.customers.count()
  end

  def showtimes()
    sql = "SELECT screenings.film_time FROM screenings WHERE film_id = $1"
    values = [@id]
    results = SqlRunner.run(sql, values)
    return results.map {|result| result["film_time"]}
  end

  def screenings()
    sql = "SELECT * FROM screenings where film_id = $1"
    values = [@id]
    screenings = SqlRunner.run(sql, values)
    return screenings.map {|screening| Screening.new(screening)}
  end

  def most_popular_time()
    showtime_tickets = Hash.new(0)
    self.screenings().each do |screening|
      showtime_tickets[screening.film_time] += screening.number_of_tickets()
    end
    return showtime_tickets.max_by {|time, num_tickets| num_tickets}[0]
  end

  def self.all
    sql = "SELECT * FROM films"
    films = SqlRunner.run(sql)
    return films.map {|film| Film.new(film)}
  end

  def self.delete_all
    sql = "DELETE FROM films"
    SqlRunner.run(sql)
  end

  def self.display_schedule
    for film in self.all()
      screening_times = ''
      for screening in film.screenings()
        screening_times += screening.film_time + ' '
      end
      p "#{film.title}: #{screening_times.strip}"
    end
  end
end
