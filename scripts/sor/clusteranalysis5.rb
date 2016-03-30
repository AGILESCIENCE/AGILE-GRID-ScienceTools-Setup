#! /usr/bin/ruby
#0) config file name (V2)

load ENV["AGILE"] + "/scripts/sor/sorpaths.rb"
load ENV["AGILE"] + "/scripts/sor/Conf.rb"

filenameconf = ARGV[0];
root = PATH_RES

index = 0;

conffile = Conf.new

conffile.process(filenameconf, nil, nil)
rootbase = root

basedir = root + "/" + conffile.dir_run_output + "/" + conffile.analysisname

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
if conffile.queue != nil
	f.write("\#\@ class    = " + conffile.queue + "\n")
else
	f.write("\#\@ class    = large\n")
end
f.write("\#\@ job_name = sor4_" + conffile.analysisname + "\n")

#enable/disable send mail when the task is finished
#f.write("\#\@ notify_user = " + conffile.mail + "\n")

f.write("\#\@ queue\n")

f.write("date\n")
f.write("module load agile-B23\n")
f.write("analysis5.rb " + mle + ".conf" + "\n")
f.close()

puts basedir

Dir.chdir(basedir)
cmd = "cd " + basedir + "; " + EXECCOM + " " + newcmd;
puts cmd
system(cmd)
