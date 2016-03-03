#! /usr/bin/ruby
#0) config file name

load ENV["AGILE"] + "/scripts/conf.rb"
load ENV["AGILE"] + "/scripts/sor/sorpaths.rb"
load ENV["AGILE"] + "/scripts/sor/Conf.rb"

datautils = DataUtils.new
alikeutils = AlikeUtils.new
parameters = Parameters.new

filenameconf = ARGV[0];

mle = filenameconf.split(".conf")[0]

filenameconfext = filenameconf

#estrazione lista sorgenti
fndisplayreg = mle + "display"

fnhyp0 = mle+"hypothesis0.multi"
fnhyp = mle+"hypothesis.multi"

conffile = Conf.new

conffile.process(filenameconf, fnhyp0, fndisplayreg);

conf.detsmooth()
	
conf.plotjpgcts1(mle, conf.smooth, fndisplayreg)

conf.plotjpgint(mle, conf.smooth, fndisplayreg)

conf.plotjpgexp(mle, fndisplayreg)

conf.plotjpgcts2(mle, conf.smooth, fndisplayreg)

conf.plotjpgcts2(mle + ".step0", conf.smooth, fndisplayreg)

conf.plotjpgcts2(mle + ".step1", conf.smooth, fndisplayreg)



