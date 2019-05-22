div.directories.container
  div.columns
    div.column.col-3
    div.column.col-6
      h2 #{path}
      - dir.entries.each do |d|
        - if d != ".." && d != "."
          - node = File.join(path, d)
          - if !d.starts_with?('.')
            - if File.directory?(node)
              a.btn href="#{d}/" #{d}/
            - else
              a.btn.btn-link href="#{d}" #{d}
    div.column.col-3
