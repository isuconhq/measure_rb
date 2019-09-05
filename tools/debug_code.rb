raws      = File.readlines(ENV["INPUT_FILE"])
end_block = nil

raws.each.with_index(1) do |raw, i|
  if md = raw.match(/^(?<nest>[[:space:]]*)def (?<key>.+?)(\(.*\))*$/)
    raws.insert(i, "  #{md[:nest]}measure(key: \"#{md[:key]}\") do\n")
    end_block = "#{md[:nest]}end\n"
    next
  elsif md = raw.match(/^(?<nest>[[:space:]]*)(?<method>get|post|delete) \'(?<key>.+?)\'.*? do.*$/)
    raws.insert(i, "  #{md[:nest]}measure(key: \"#{md[:method].upcase} #{md[:key]}\") do\n")
    end_block = "#{md[:nest]}end\n"
    next
  end

  if !end_block.nil? && raw == end_block
    raws.insert(i - 1, "  #{end_block}")
    end_block = nil
    next
  end
end

`cp "#{ENV["INPUT_FILE"]}" "#{ENV["INPUT_FILE"]}.bak"`
File.write(ENV["INPUT_FILE"], raws.join)
