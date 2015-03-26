#0) config file name

filenameconf = ARGV[0];

index = 0;
filter = ""
tstart = ""
tstop = ""
l = ""
b = ""
timetype = ""
galcoeff = ""
isocoeff = ""
mapparam = ""
multiparam = ""
iddisp = ""
user = ""
analysisname = ""

File.open(filenameconf).each_line do | line |
	line = line.chomp
	if index.to_i == 0
		filter = line
	end
	if index.to_i == 1
		tstart = line
	end
	if index.to_i == 2
		tstop = line
	end
	
	if index.to_i == 3
		timetype = line
	end
	if index.to_i == 4
		l = line
	end
	if index.to_i == 5
		b = line
	end
	if index.to_i == 6
		galcoeff = line
	end
	if index.to_i == 7
		isocoeff = line
	end
	if index.to_i == 8
		mapparam = line
	end
	if index.to_i == 9
		multiparam = line
	end
	if index.to_i == 10
		iddisp = line
	end
	if index.to_i == 11
		user = line
	end
	if index.to_i == 12
		analysisname = line
	end


	index = index.to_i + 1
end

root = "/AGILE_PROC3/ANALYSIS3/"

basedir = root + "/" + user + "/" + analysisname

#TODO
#far funzionare il caso in cui ci siano già le mappe

mleindex = 0;
if File.exists?(basedir)
	ml = Dir[basedir+"/MLE???"].sort
	mleindex = ml[ml.size()-1].split("MLE")[1].to_i;
	mleindex = mleindex.to_i + 1
end

cmd = "mkdir -p " + basedir;
puts cmd
system(cmd);



l = l.to_f + 0.0001
l = l.to_s
 
if(mleindex.to_i == 0)
	cmd = "cd " + basedir + "; map.rb " + filter + " MAP " + tstart + " " + tstop + " " + l + " " + b + " timetype=" + timetype + " " + mapparam;
	puts cmd
	system(cmd)
end

#MAP.maplist4 hypothesis.multi MLE$10 galcoeff=$8 isocoeff=$9 $11
mle = "MLE" + format("%03d", mleindex)

cmd = "cp hypothesis.multi " + basedir + "/" + mle + "hypothesis.multi "
puts cmd
system(cmd)

cmd = "cd " + basedir + "; multi5.rb " + " MAP.maplist4 " + mle + "hypothesis.multi " + mle + " galcoeff=" + galcoeff + " isocoeff=" + isocoeff + " " + multiparam
puts cmd
system(cmd)

cmd = "cd " + basedir + "; convertMultiResToReg.rb " + mle + " white 0.1"
puts cmd
system(cmd)

cmd = "cd " + basedir + "; ds9.rb MAP.cts.gz " + mle  + ".ctsall 2 -1 3 B all jpg 1500x1500 " + mle + ".reg " +  mle + ".multi.reg "
puts cmd
system(cmd)
