require 'date'
require 'csv'

if ARGV.length != 1
  puts "Usage: Type Name of csv file with movies data"
  puts "Example : ruby movie_scheduler.rb movies.csv "
  exit 0
end

file_name = ARGV[0]

# Add minutes method to Numeric class.
class Numeric
  def minutes; self/1440.0 end
  alias :minute :minutes
end

now_date = DateTime.now
# There are 4 minutes of gap before end of day operation (end_time).
operation = [
  {
    name: 'Weekday',
    start_time: DateTime.new(now_date.year, now_date.month, now_date.day, 11),
    end_time: DateTime.new(now_date.year, now_date.month, now_date.day, 22, 56)
  },
  {
    name: 'Weekend',
    start_time: DateTime.new(now_date.year, now_date.month, now_date.day, 10, 30),
    end_time: DateTime.new(now_date.year, now_date.month, now_date.day, 23, 56)
  }
]

def scheduler(schedule, movie_minutes, start_time, end_time)
  after = 20

  # Condition for the first iteration.
  movie_end =  schedule.any? ? end_time - after.minutes + 1.minute : end_time
  movie_start = movie_end - movie_minutes.minutes

  # cinema requires 15 minutes after opening before first movie is shown
  if movie_start > (start_time + 15.minutes)

    schedule << {
      movie_start: movie_start,
      movie_end: movie_end
    }
    end_time = movie_start - after.minutes
    scheduler(schedule, movie_minutes, start_time, end_time)
  else
    schedule.reverse
  end
end

def schedule_printer(operation_name, schedule)
  puts "#{operation_name} \n"
  puts schedule.map {|s| "#{s[:movie_start].strftime("%I:%M %p")} - #{s[:movie_end].strftime("%I:%M %p")} \n"}
  puts "\n"
end

CSV.foreach(file_name, :headers => true) do |row|
  puts "=================================================\n"
  puts "#{row['name']} \n\n"
  operation.each do |op|
    movie_schedule  = scheduler([], row['minutes'].to_i, op[:start_time], op[:end_time])
    schedule_printer(op[:name], movie_schedule)
  end
end
