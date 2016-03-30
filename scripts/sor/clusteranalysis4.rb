#! /usr/bin/ruby
#0) config file name (V2)

load ENV["AGILE"] + "/scripts/sor/sorpaths.rb"

filenameconf = ARGV[0];
root = PATH_RES

index = 0;
typeanalysis = ""
filter = ""
tstart = ""
tstop = ""
timetype = ""
l = ""
b = ""
proj = ""
galcoeff = ""
isocoeff = ""
mapparam = ""
hypothesisgen1 = ""
hypothesisgen2 = ""
radmerger = ""
multiparam = ""
tsmapparam = ""
iddisp = ""
user = ""
mail = ""
analysisname = ""
ds91 = ""
ds92 = ""
ds93 = ""
ds94 = ""
tbd1 = ""
tbd2 = ""
comments = ""
reg = ""

queue = nil

File.open(filenameconf).each_line do | line |
	line = line.chomp
	if index.to_i == 0
		typeanalysis = line
	end
	if typeanalysis != "single"
		#exit
	end
	if index.to_i == 1
		filter = line
	end
	if index.to_i == 2
		tstart = line
	end
	if index.to_i == 3
		tstop = line
	end
	if index.to_i == 4
		timetype = line
	end
	if index.to_i == 5
		l = line
	end
	if index.to_i == 6
		b = line
	end
	if index.to_i == 7
		proj = line
	end
	if index.to_i == 8
		galcoeff = line
	end
	if index.to_i == 9
		isocoeff = line
	end
	if index.to_i == 10
		mapparam = line
	end
	if index.to_i == 11
        hypothesisgen1 = line
    end
    if index.to_i == 12
        hypothesisgen2 = line
    end
    if index.to_i == 13
        radmerger = line
    end
	if index.to_i == 14
		multiparam = line
	end
	if index.to_i == 15
		tsmapparam = line
	end
	if index.to_i == 16
		ds91 = line
	end
	if index.to_i == 17
		ds92 = line
	end
	if index.to_i == 18
		ds93 = line
	end
	if index.to_i == 19
		ds94 = line
	end
	if index.to_i == 20
		tbd1 = line
	end
	if index.to_i == 21
		tbd2 = line
	end
	if index.to_i == 22
		iddisp = line
	end
	if index.to_i == 23
		user_and_queue = line
		user = user_and_queue.split(",")[0]
		if user_and_queue.split(",").size == 2
			queue = user_and_queue.split(",")[1]
		end
	end
	if index.to_i == 24
        mail = line
    end
	if index.to_i == 25
		analysisname =  line
		if proj.to_s == "AIT"
			analysisname = "AIT_" + analysisname.to_s;
		end
		if proj.to_s == "ARC"
			analysisname = "ARC_" + analysisname.to_s
		end
	end
	if index.to_i == 26
		comments =  line
	end
	if index.to_i == 27
		reg =  line
	end
	index = index.to_i + 1
end



rootbase = root

basedir = root + "/" + user + "/" + analysisname

if basedir == rootbase + "//"
	puts "error in config file name"
	exit
end

mleindex = 0;
if File.exists?(basedir)
	ml = Dir[basedir+"/MLE????"].sort
	puts basedir + " with index " + ml.size().to_s
	if ml.size() > 0
		mleindex = ml[ml.size()-1].split("MLE")[1].to_i;
		mleindex = mleindex.to_i + 1
	else
		cmd = "rm -rf " + basedir
		puts cmd
		system(cmd)
	end
end

mle = "MLE" + format("%04d", mleindex)
puts mle

cmd = "mkdir -p " + basedir;
puts cmd
system(cmd);

#copy the .conf
cmd = "cp " + ARGV[0] + " " + basedir + "/" + mle + ".conf"
puts cmd
system(cmd)

newcmd = basedir + "/" + mle + ".ll"

cmd = "cp " + ENV["AGILE"] + "/scripts/sor/run5.ll " + newcmd
puts cmd
system(cmd)

f = File.open(newcmd, "a")
if queue != nil
	f.write("\#\@ class    = " + queue + "\n")
else
	f.write("\#\@ class    = large\n")
end
f.write("\#\@ job_name = sor4_" + analysisname + "\n")

#enable/disable send mail when the task is finished
#f.write("\#\@ notify_user = " + mail + "\n")

f.write("\#\@ queue\n")

f.write("date\n")
f.write("module load agile-B23\n")
f.write("analysis4.rb " + mle + ".conf" + "\n")
f.close()

puts basedir

Dir.chdir(basedir)
cmd = "cd " + basedir + "; " + EXECCOM + " " + newcmd;
puts cmd
system(cmd)
