#! /usr/bin/ruby
#script for BUILD22
################ Mandatory and ordered parameters:
#00) maplist - Note that the extension .maplist4 is mandatory. See below for more details.
#01) listsource - extension .multi - file name of the list (in alike multi format - example 73.0e-08 80.27227 0.73223 2.1 1 2 3EGJ2033+4118). See below for more details.
#02) outfile - output file name
################ Optional parameters
#03) prefix (if specify a prefix, use only 1 map, if -999 use all the maps in the directory) - disabled with parameter maplist
#04) offaxis - off axix pointing (default 30) - set into .maplist4
#05) ranal   - radius of analysis (default 10)
#06) galcoeff     - gal coefficient (default -1) - set into .maplist4
#07) isocoeff     - iso coefficient (default -1) - set into .maplist4
#08) galmode     - gal mode, default 1 - See below for more details.
#09) isomode     - iso mode, default 1 - See below for more details.
#10) ulcl    - upper limit confidence level (default 2),  espressed as sqrt(TS)
#11) loccl   - source location contour confidence level (default 95 (%)confidence level) Vales: 99, 95, 68, 50
#12) flag    - a flag of the analysis (that is written in the final file)
#13) token (enabled if host,token with token >= 1)
#14) fixisogalstep0 - default 0 = do not calculate, otherwise specify the name of the source to calculate the gal and iso (if not specified by galcoeff or isocoeff parameters, otherwise use these values also in this step): calculate gal and iso setting fixflag=1 for the source under analysis
#15) findermultimode - default 0 = do not use, or the name of the source to be found. Analysis in 2 steps:
#	(1) ulcl=0, loccl=0, fixflag=3 to perform the first search
#	(2) use standard ulcl and loccl but with the new position of the source found in step (1)

#MAPLIST
#Each line contains a set of maps:
#	<countsMap> <exposureMap> <gasMap> <offAxisAngle> <galCoeff> <isoCoeff>
#	where:
#	offAxisAngle is in degrees;
#	galcoeff and isocoeff are the coefficients for the galactic and isotropic diffuse components. 
#	If positive they will be considered fixed (but see galmode and isomode below).
#	The file names are separated by a space, so their name should not contain one.

#SOURCE LIST
#Each source is described by a line containing space separated values, in the following order:
# <flux> <l> <b> <spectral index> <fixFlag> <minSqrt(TS)> <name> [location limitation]
# The first 4 values, flux in cm^-2 s^-1, galactic longitude and latitude in degrees, and spectral index of each source, represent the initial estimates of the values for that source. According to the fixflag some or all of those values will be optimized by being allowed to vary.
#The flux estimates are relevant in the fitting process, as the sources are considered one by one starting with the one with the brightest initial flux value, regardless of the order they are given in the source file.
#The fixflag is a bit mask, each bit indicating whether the corresponding value is to be allowed to vary. 1 indicates the flux, 2 the position and 4 the spectral index. The user may combine these values, but the flux will always be allowed to vary if at least one of the other values are.
#Examples:
#fixFlag = 0: everything is fixed. This is for known sources which must be included in order to search for other nearby sources.
#fixFlag = 1: flux variable, position fixed
#fixFlag = 3: flux and position variable, index fixed
#fixFlag = 5: flux and index variable, position fixed
#fixFlag = 7: flux, position and index variable and also
#fixFlag = 2: only the position is variable, but AG_multi will let the flux vary too, so this is equivalent to 3.
#minSqrt(TS) is the minimum acceptable value for the square root of TS: if the optimized significance of a source lies below this value, the source is considered undetected and will be ignored (set to flux = 0) when considering the other sources.
#The name of the source cannot contain any space. It is used to refer to this source in all the output files, and as part of the name of the source-specific output file.

#GALMODE e ISOMODE
#   galmode and isomode are an integer value saying how the corresponding coefficients galcoeff or 
#   isoCoeff found in all the lines of the maplist are to be used:
#		0: all the coefficients are fixed.
#		1: all the coefficients are fixed if positive, variable if negative (the absolte value is the 
#		initial value). This is the default behaviour.
#		2: all the coefficients are variable, regardless of their sign.
#		3: all the coefficients are proportionally variable, that is the relative weight of their absolute value is kept.

load ENV["AGILE"] + "/scripts/conf.rb"
datautils = DataUtils.new

if ARGV[0].to_s == "help" || ARGV[0].to_s == "h" || ARGV[0] == nil
	system("head -58 " + $0 );
	exit;
end

p = Parameters.new
p.processInput(3, ARGV)
alikeutils = AlikeUtils.new
multioutput = MultiOutput.new

prefix = p.prefix
cts = ""
if prefix != -1 then
	cts = prefix.to_s + ".cts.gz";
	exp = prefix.to_s + ".exp.gz";
	gas = prefix.to_s + ".gas.gz";
end

inputmaplist = ARGV[0];
listsource = ARGV[1];
baseoutfile = ARGV[2];
baseoutfile2 = ARGV[2];

File.open(inputmaplist).each_line do | line |
	cts = line.split(" ")[0];
	exp = line.split(" ")[1];
	gas = line.split(" ")[2];
end

stepi=1
prefixi = ""
ulcl = p.ulcl
loccl = p.loccl
if p.findermultimode != nil
	stepi=2
	prefixi = ".step1"
	ulcl = 0
	loccl = 0
end

lastoutfile = ""

for i in 1..stepi
	#outfile
	outfile = baseoutfile
	outfile2 = baseoutfile2

	#selezione delle calibration matrix
	filterbase = p.filter.split("_")[0];
	datautils.getResponseMatrix(p.filter);
	matrixconf = datautils.getResponseMatrixString(p.filter);
	
	#per prima cosa, se richiesto, si cerca il valore di gal e iso
	inputfilemaps = inputmaplist
	if p.fixisogalstep0 != nil
		outfile22 = outfile.to_s + ".step0"
		inputfilemaps22 = outfile.to_s + ".step0" + ".maplist4"
		alikeutils.rewriteMaplist(inputfilemaps, inputfilemaps22, p.galcoeff, p.isocoeff)
		
		#aggiorna il .multi mettendo a fixflag=1 solo la sorgente specificata in p.fixisogalstep0
		newlistsource = outfile.to_s + ".step0" + ".multi"
		alikeutils.rewriteMultiInputWithSingleSourceToAnalyze(listsource, newlistsource, p.fixisogalstep0, "1");
		
		cmd = PATH + "bin/AG_multi5 " + inputfilemaps22.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + newlistsource.to_s + "  " + outfile22.to_s + " " + ulcl.to_s + " " + loccl.to_s;	
		datautils.execute(outfile2, cmd)
		
		#step0b: prendi il valore di gal e iso calcolati e genera il maplist4 per le analisi successive
		multioutput.readDataSingleSource2(outfile22, p.fixisogalstep0);
		maplist = outfile22 + ".tmpmaplist4"
		
		alikeutils.rewriteMaplist(inputfilemaps, maplist, multioutput.galcoeff, multioutput.isocoeff)
		
	end
	
	if p.fixisogalstep0 == nil
		#copy the .maplist4 in .maplist
		maplist = outfile.to_s + ".maplist4"
		alikeutils.rewriteMaplist(inputmaplist, maplist, p.galcoeff, p.isocoeff);
	end
	
	#si esce dai due step precedenti con il maplist corretto

	if p.findermultimode != nil && i.to_i == 2
		prefixi = ""
		ulcl = p.ulcl
		loccl = p.loccl
	end

	if maplist != nil
		inputfilemaps = outfile.to_s + prefixi.to_s + ".maplist4"
		#if p.findermultimode != nil
			datautils.execute(outfile2, "cp " + maplist.to_s + " " + inputfilemaps.to_s)
		#end
		maplist = inputfilemaps
	end
	
	##....

	#list source
	newlistsource = outfile.to_s + prefixi.to_s + ".multi" 
	#if p.findermultimode != nil && i.to_i == 1
		datautils.execute(outfile2, "cp " + listsource.to_s + " " + newlistsource.to_s)
	#end
	if p.findermultimode != nil && i.to_i == 2
		#elaborazione della source list
	
		multioutput.readDataSingleSource2(lastoutfile, p.findermultimode.split(",")[0])
	
		alikeutils.rewriteMultiInputWithNewCoordinatesSource(listsource, newlistsource, p.findermultimode.split(",")[0], multioutput.l_peak, multioutput.b_peak);
	
	end

	newoutfile = outfile.to_s + prefixi.to_s
	
	cmd = PATH + "bin/AG_multi5 " + inputfilemaps.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + newlistsource.to_s + "  " + newoutfile + " " + ulcl.to_s + " " + loccl.to_s;

	#ablitazione del token
	cmd2 = "";
	cmd3 = "";
	host = ""
	tokennum = -1;
	host = p.token.split(",")[0].strip;
	tokennum = p.token.split(",")[1].strip;
	if tokennum.to_i == 0 
		cmd2 = "ssh " + host.to_s + " \"cd " + Dir.pwd().to_s + "; "
		cmd3 = "\"";
	end
	cdir= Dir.pwd().strip.to_s;
	if tokennum.to_i >= 1
	
		cmd = "ssh " + host.to_s + " mkdir ~/" + tokennum.to_s;
		puts cmd
		system(cmd)
		cmd = "rsync -avz --delete " + cdir.to_s + "/ " + host.to_s + ":~/" + tokennum.to_s + "/";
		puts cmd
		system cmd

		cmd2 = "ssh " + host.to_s + " \"cd ~/" + tokennum.to_s + "; "
		cmd3 = "\"";
	end

	cmd = cmd2 + cmd;

	datautils.execute(outfile2, cmd)
	
	if tokennum.to_i >= 1
		cmd = "rsync -avz  " + host.to_s + ":~/" + tokennum.to_s + "/ " + cdir.to_s + "/"
		puts cmd
		system cmd
	end

	#cmd = "ruby ~/grid_scripts3/convertMultiResToReg.rb " + outfile.to_s + " white";
	#datautils.execute(outfile2, cmd)
	
	mout = MultiOutputList.new
	mout.readSources(newoutfile, newlistsource, p.flag);

	cmd = "ruby " + ENV["AGILE"] + "/scripts/convertMultiInputToReg.rb " + newlistsource.to_s + " blue";
	datautils.execute(outfile2, cmd)

	
	datautils.readFitsHeader(cts.to_s);
	cmd = "echo \"" + datautils.header["DATE-OBS"] + "\" >> " + newoutfile.to_s;
	datautils.execute(outfile2, cmd)

	cmd = "echo \"" + datautils.header["DATE-END"] + "\" >> " + newoutfile.to_s;
	datautils.execute(outfile2, cmd)

	#cmd = "ruby ~/grid_scripts3/convertMultiResToRegData.rb " + outfile.to_s;
	#datautils.execute(outfile2, cmd)

	if PARALLEL_OR_ITERATIVE.to_i == 1
		#cmd = "ruby ~/grid_scripts3/convertMultiResToHTML.rb " + outfile.to_s;
		#datautils.execute(outfile2, cmd)
	end

	system("cat " + newoutfile.to_s)

	lastoutfile = newoutfile

end
