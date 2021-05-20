require 'date'
require 'active_support/core_ext/numeric/time.rb'
#inputs

if ARGV.length != 2
  puts "Type Name of movie and duration minutes \n"
  puts "Example : 'Liar Liar' 86"
  exit 0
end


movie_title = ARGV[0]
movie_minutes = ARGV[1].to_i

operation = [
  {
    name: 'Weekday',
    start_time: DateTime.now.change({ hour: 11 }),
    end_time: DateTime.now.change({ hour: 23 })
  },
  {
    name: 'Weekend',
    start_time: DateTime.now.change({ hour: 10, min: 30, sec: 0 }),
    end_time: DateTime.now.change({ hour: 23, min: 59, sec: 59 })
  }
]

def scheduler(schedule, movie_minutes, start_time, end_time)
  preview_minutes = 15
  after_minutes = 20

  movie_start = start_time + preview_minutes.minutes
  movie_end  = movie_start + movie_minutes.minutes

  if movie_end < end_time

    schedule << {
      movie_start: movie_start,
      movie_end: movie_end
    }
    scheduler(schedule, movie_minutes, movie_end + after_minutes.minutes, end_time )
  else
    schedule
  end
end

def schedule_printer(operation_name, movie_title, schedule)
  puts "#{operation_name} \n"
  puts schedule.map {|s| "#{s[:movie_start].strftime("%I:%M %p")} - #{s[:movie_end].strftime("%I:%M %p")} \n"}
end

puts "#{movie_title} \n\n"

operation.each do |op|
  movie_schedule  = scheduler([], movie_minutes, op[:start_time], op[:end_time])
  schedule_printer(op[:name], movie_title, movie_schedule)
end

