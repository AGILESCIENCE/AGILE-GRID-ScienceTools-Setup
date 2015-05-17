#! /usr/bin/ruby
#1) file name input
#2) file name output (optional): if specified, generate a multi file

load ENV["AGILE"] + "/scripts/conf.rb"

filename = ARGV[0]

datautils = DataUtils.new

if ARGV[0].to_s == "help" || ARGV[0] == nil || ARGV[0] == "h"
	system("head -3 " + $0 );
	exit;
end


File.open(ARGV[0]).each do | line1 |

	File.open(ARGV[0]).each do | line2 |
		if line1 != line2
				lll1 = line1.split(" ")
				lll2 = line2.split(" ")
 			 	l1 = lll1[2]
			 	b1 = lll1[3]
			 	l2 = lll2[2]
			 	b2 = lll2[3]
				d = datautils.distance(l1, b1, l2, b2)
				if(d.to_f < 1)
					puts line1.chomp + " - " +  line2 + "\n"
				end
				if lll1[0] == lll2[0]
					puts "Found duplicated: \n" + line1.chomp + "\n" +  line2 + "\n"
				end
		end
	end
end


if ARGV[1] != nil
	fout = File.new(ARGV[1], "w")
	File.open(ARGV[0]).each do | line1 |
		lll1 = line1.split(" ")
		name = lll1[0]
		flux = lll1[6]
		fixflag = "0"
		dist = "0.0"
		l1 = lll1[2]
		b1 = lll1[3]
		
		fout.write(flux + " " + l1 + " " + b1 + " 2.1 0 2 " + name + " 0.0\n")
	end
	fout.close()
	
end

