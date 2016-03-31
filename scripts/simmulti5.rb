#! /usr/bin/ruby
#0) filter/archive/calibMatrix (FM3.119_ASDCe_I0023)
#1) maplist sim
#2) list of sources (in .multi format) for simulation
#3) maplist ana
#4) list of sources (in .multi format) for analysis
#5) outfile

#optional
#opmode	 Integer	 Operation Mode
#blocks	 Integer	 Block
#nruns	 Integer	 Number of runs
#seed	Integer	 Seed
#7) ranal
#8) galmode
#9) isomode
#10) ulcl
#11) loccl
#12) outputtype (defalt 0)

#Parametri di input del task
#Name	Type	Description
#opmode	 Integer	 Operation Mode
#block	 Integer	 Block
#nruns	 Integer	 Number of runs
#seed	Integer	 Seed
#sarfile	 String	 SAR file name
#edpfile	 String	 EDP file name
#psdfile	String	 PSD file name
#maplistsim	String	Simulation map list
#srclistsim	String	Simulation source list
#outfile	 String	 Output file name
#maplistanalysis	String	Analysis map list
#srclistanalysis	String	Analysis source list
#ranal	Real	Radius of analysis region
#galmode	Integer	 Diffuse emission mode
#isomode	Integer	 Isotropic emission mode
#ulcl	Real	 Upper limit confidence level
#loccl	 Real	 Source location contour confidence level

#opmode
#This program option is a bit mask with the following meaning:
#1 concise - Generate a single log file rather that a file for each source and each analysis
#2  skipanalysis -  Do the simulation only, skip any analysis
#4 doubleanalysis - Do the analysis in two steps, the second using the sources obtained from the first
#8 savemaps - Save to disk all the maps evaluated at run time and used for the analysis
#Please note the following:
#If the bit 1 is off the bits 0 and 2 are ignored.
#If the bit 1 is on and the bit 3 is off no output is generated
#If bit 1 is set, command line options 10 to 17 are optional and, if present, are ignored


#Istruzioni: devono essere presenti la exp e la gas map e la maplist4. VERSIONE: loccl to 95

load ENV["AGILE"] + "/scripts/conf.rb"
datautils = DataUtils.new

if ARGV[0].to_s == "help" || ARGV[0].to_s == "h" || ARGV[0] == nil
	system("head -54 " + $0 );
	exit;
end

filter = ARGV[0];
maplistsim = ARGV[1]
listsourcesim = ARGV[2];
maplistana = ARGV[3]
listsourceana = ARGV[4];
outfile = ARGV[5]
p = Parameters.new
p.processInput(6, ARGV, filter)

#selezione della matrix
filterbase = filter.split("_")[0];
datautils.getResponseMatrix(filter);
sarmatrix = datautils.sarmatrix
edpmatrix = datautils.edpmatrix
psdmatrix = datautils.psdmatrix
matrixconf = datautils.getResponseMatrixString(filter);

# outfile2 = prefix.to_s + "_" + listsourcesim.to_s + "_iso" + iso.to_s
logfile = outfile.to_s + ".log"


cmd = PATH + "bin/AG_multisim5 " + p.opmode.to_s + " " + p.blocks.to_s + " " + p.nruns.to_s + " " + p.seed.to_s + " "  + matrixconf.to_s + " " + maplistsim.to_s + " " + listsourcesim.to_s + " " + outfile.to_s + " " + maplistana.to_s + " " + listsourceana.to_s + " " + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s + " " + p.ulcl.to_s + " " + p.loccl.to_s;
datautils.execute(logfile, cmd);

