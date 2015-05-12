#! /usr/bin/ruby
load ENV["AGILE"] + "/scripts/conf.rb"

filename = ARGV[0]

datautils = DataUtils.new



File.open(ARGV[0]).each do | line1 |

	File.open(ARGV[0]).each do | line2 |
		if line1 != line2
			 	l1 = line1.split(" ")[1]
			 	b1 = line1.split(" ")[2]
			 	l2 = line2.split(" ")[1]
			 	b2 = line2.split(" ")[2]
				d = datautils.distance(l1, b1, l2, b2)
				if(d.to_f < 1)
					puts line1.chomp + " - " +  line2
				end
		end
	end
end
