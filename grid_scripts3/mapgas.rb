#! /usr/bin/ruby
#script compatible with BUILD20
#0) filter DIR (es: FT3ab_2_I0007, FM3.119_2c, F4_2c_I0010)
#1) output file name prefix
#2) exp map
#optional
#emin
#emax

load "~/grid_scripts3/conf.rb"

datautils = DataUtils.new
parameters = Parameters.new

if ARGV[0].to_s == "help" || ARGV[0] == nil || ARGV[0] == "h"
	system("head -9 " + $0 );
	exit;
end

filter = ARGV[0];
gas = ARGV[1];

exp = ARGV[2];



datautils.extractFilterDir(filter)
filterdir = datautils.filterdir
filterall = filterdir;

filterbase2 = filter.split("_")[0] + "_" + filter.split("_")[1];




parameters.processInput(3, ARGV)

emin1 = parameters.emin;
emax1 = parameters.emax;
datautils.getSkyMatrix(filter, emin1, emax1)
skymap =  datautils.skymatrix;
skymapH = datautils.skymatrixH;
skymapL = datautils.skymatrixL;
puts "Sky map H: " + skymapH.to_s;
puts "Sky map L: " + skymapL.to_s;






cmd = "~/ADC/scientific_analysis/bin/AG_gasmapgen2 " + exp.to_s + " " + gas.to_s + " " + skymapL.to_s + " " + skymapH.to_s;
datautils.execute("", cmd);
		
				


