#! /usr/bin/ruby
#1) file name input
#2) file name output (optional): if specified, check the fixflag and rewrite the file

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
 			 	l1 = lll1[1]
			 	b1 = lll1[2]
			 	l2 = lll2[1]
			 	b2 = lll2[2]
				d = datautils.distance(l1, b1, l2, b2)
				if(d.to_f < 1)
					puts line1.chomp + " - " +  line2
				end
				if lll1[6] == lll2[6]
					puts "Found duplicated" + line1.chomp + " - " +  line2
				end
		end
	end
end


if ARGV[1] != nil
	fout = File.new(ARGV[1], "w")
	File.open(ARGV[0]).each do | line1 |
		lll1 = line1.split(" ")
		name = lll1[6]
		fixflag = lll1[4]
		dist = "0.0"
		if lll1.size() == 8
			dist = lll1[7]
		end
		if name[0] == "_"
			fixflag = "0"
		end
		fout.write(lll1[0] + " " + lll1[1] + " " + lll1[2] + " " + lll1[3] + " " + fixflag + " " + lll1[5] + " " + lll1[6] + " " + dist + "\n")
	end
	fout.close()
	
end

