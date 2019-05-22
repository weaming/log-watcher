module Helper::FileIO
  extend self

  def read_stdin : String
    File.read "/dev/stdin"
  end

  def write_file(path : String, data : Bytes)
    File.open(path, mode = "w", encoding = "utf-8") do |f|
      f.write data
    end
  end
end

module Helper::CLI
  extend self

  def argv_n(n : Int32, msg : String) : String
    if ARGV.size < n || ARGV[n - 1] == ""
      puts msg
      exit 1
    end
    first = ARGV[n - 1]
  end

  def argv_first(msg : String) : String
    argv_n 1, msg
  end

  def argv_n?(n : Int32, default : String = "") : String
    if ARGV.size < n || ARGV[n - 1] == ""
      return default
    end
    ARGV[n - 1]
  end
end
