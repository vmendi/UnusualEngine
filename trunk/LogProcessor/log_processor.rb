#!/usr/bin/env ruby

class Log_processor

  def run input_filename, output_path

    puts 'Reading file ' + input_filename

    # aFile is an IO object
    all_lines = IO.readlines input_filename
    puts all_lines.length.to_s + ' lines read'

    # Matches with any error
    matches = []

    # A good regular expression tester: http://www.rubular.com/
    all_lines.each { |line|
      # Exceptions in the server
      match_data = line.match(/TargetInvocationException:.*Match: (\d+)/)

      # UNSYNCS
      if match_data == nil
        match_data = line.match(/>{9} (\d+)/)
      end

      # Exceptions in the client
      if match_data == nil
        match_data = line.match(/CLIENT_ERROR.*MatchID: (\d+)/)
      end

      if match_data != nil
        # We always the num_match into the first group
        num_match = match_data[1]
        matches.push num_match
      end
    }

    matches.uniq!

    puts 'Dumping ' + matches.length.to_s + ' matches'

    # We generate a file for each match with error
    matches.each { |num_match|
      File.open(output_path + num_match + '.txt', 'w') { |io|
        get_lines_for_match(all_lines, num_match).each { |line| io.puts line }
      }
    }
  end

  # Returns only  the lines for 'num_match'
  def get_lines_for_match (global_lines, num_match)
    ret = []
    global_lines.each { |line|
      unless line.index(num_match) == nil
        ret.push line
      end
    }
    ret
  end

end

def look_for_recent_log
  newest_time = nil
  newest_file = nil

  Dir.foreach('./') { |dirEntry|
    if !File.directory?(dirEntry) && File.extname(dirEntry) == '.log'
      if (newest_time == nil ||
          (File.mtime(dirEntry) <=> newest_time) > 0)
          newest_time = File.mtime(dirEntry)
          newest_file = dirEntry
      end
    end
  }

  newest_file
end

input = ARGV[0]

if input == nil || !File.exists?(input)
  input = look_for_recent_log
  if (input == nil)
    puts 'File not found'
    exit
  end
end

output = './log_processor/'

unless ARGV[1] == nil
  output = ARGV[1]
end

unless output.end_with?('/') || output.end_with?('\\')
output += '/'
end

unless File.directory? output
  Dir::mkdir output
end

the_processor = Log_processor.new
the_processor.run(input, output)

puts 'done'