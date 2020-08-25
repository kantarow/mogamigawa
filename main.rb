require_relative "lib/mogamigawa"

mogamigawa = Mogamigawa.new "五月雨をあつめて早し最上川"

puts mogamigawa.consume(5).join
puts mogamigawa.consume(7).join
puts mogamigawa.consume(5).join
