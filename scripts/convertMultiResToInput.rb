#! /usr/bin/ruby
#0) input file name
#1) output file name
#2) analysis type (optional, default 2)
#3) minsqrtTS to cut (optional, default 0)
#4) radious search for alike (optional, default 0)
#5) max off-axis (optional, if appliable ( column 9 is present), default 90)

load ENV["AGILE"] + "/scripts/conf.rb"

if ARGV[0].to_s == "help" || ARGV[0] == nil || ARGV[0] == "h"
	system("head -6 " + $0 );
	exit;
end

fileinp1 = ARGV[0]
fileout1 = ARGV[1]
if ARGV[2] != nil
	ant = ARGV[2]
else
	ant = 2
end
if ARGV[3] != nil
	mins = ARGV[3]
else
	mins = 0
end
if ARGV[4] != nil
	radiuossearch = ARGV[4]
else
	radiuossearch = 0
end
if ARGV[5] != nil
	maxoff = ARGV[5]
else
	maxoff = 90
end

alikeutils = AlikeUtils.new

alikeutils.convertMultiResToMulti(fileinp1, fileout1, ant, 2.0, mins, maxoff, radiuossearch);




