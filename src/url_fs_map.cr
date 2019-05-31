module URLFileSystemMap
  class UF
    getter url_root : String
    getter fs_root : String

    def initialize(@url_root, @fs_root)
    end

    def get_fs_path(url) : String
      url_rel = url[@url_root.size..]
      rv = @fs_root + url_rel
      if rv == ""
        return "."
      end
      rv
    end
  end

  #  not used
  def self.join_paths(*args)
    (args.size - 1).downto(1) do |i|
      if args[i].starts_with?(File::SEPARATOR)
        return File.join(args.to_a[i..-1])
      end
    end
    File.join(args)
  end
end
