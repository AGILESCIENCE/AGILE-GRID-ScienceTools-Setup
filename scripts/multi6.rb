#! /usr/bin/ruby
#script for BUILD24
################ Mandatory and ordered parameters:
#00) filter (default FM3.119_2_I0025)
#01) maplist - Note that the extension .maplist4 is mandatory. See below for more details.
#02) listsource - extension .multi - file name of the list (in alike multi format - example 73.0e-08 80.27227 0.73223 2.1 1 2 3EGJ2033+4118). See below for more details.
#03) outfile - output file name
################ Optional parameters
#04) prefix (if specify a prefix, use only 1 map, if -999 use all the maps in the directory) - disabled with parameter maplist
#05) offaxis - off axix pointing (default 30) - set into .maplist4
#06) ranal   - radius of analysis (default 10)
#07) galcoeff     - gal coefficient (default -1) - set into .maplist4. If -2, use the same coeff of the input maplist4
#08) isocoeff     - iso coefficient (default -1) - set into .maplist4. If -2, use the same coeff of the input maplist4
#09) galmode     - gal mode, default 1 - See below for more details.
#10) isomode     - iso mode, default 1 - See below for more details.
#11) ulcl    - upper limit confidence level (default 2),  espressed as sqrt(TS)
#12) loccl   - source location contour confidence level (default 95 (%)confidence level) Vales: 99, 95, 68, 50
#13) flag    - a flag of the analysis (that is written in the final file)
#15) fixisogalstep0 - default 0 = do not calculate, otherwise specify the name of the source to calculate the gal and iso (if not specified by galcoeff or isocoeff parameters, otherwise use these values also in this step): calculate gal and iso setting fixflag=1 for the source under analysis
#16) findermultimode - default 0 = do not use, or the name of the source to be found. Analysis in 2 steps:
#	(1) ulcl=0, loccl=0, fixflag=3 to perform the first search
#	(2) use standard ulcl and loccl but with the new position of the source found in step (1)
#17) doublestep - default none = do not perform double step, otherwise doublestep=minsqrttsthr,secondstepfixflag,secondstepmaxradius (e.g. 3,3,0) and perform analysis in two steps (spot6 mode), where secondstepmaxradius is the last column of the .multi
#	(1) fixflag=1 for all the sources of the list
#	(2) generate a new list selecting the sources of the first list with sqrt(TS) > minsqrttsthr. The new list has fixflag = secondstepfixflag
#18) emin_sources, default 100: energy min of the input .multi
#19) emax_sources, default 50000: energy min of the input .multi
#20) listsourceextended
#21) checksourceposition - default 0 = do not use, or specify the name of the source. if fixflag > 1, check the position of the source. If the position of the source is too far, set fixflag=1 and recalculate the result. The parameters are the following:
#- name of the source
#- max distance wrt the initial position. If the ellipse is present, the radius is used instead of the user parameter
#22) galmode2
#23) galmode2fit
#24) isomode2
#25) isomode2fit
#26) minimizertype. Default Minuit
#27) minimizeralg. Default Migrad
#28) minimizerdefstrategy. Default 2 for Minuit
#29) mindefaulttolerance. Defaul 0.01
#30) edpcorrection, default 0 (no), 1 yes. EDP cleaning correction NOT IMPLEMENTED YET
#31) fluxcorrection, defaul 0 (no), 1 yes. Flux calculation correction for spectral shape
#32) scanmaplist - default 0. Calculate one TS for each map -> specify the name of the source and the prefix e.g. VELA,pl
# MAPLIST
#Each line contains a set of maps:
#	<countsMap> <exposureMap> <gasMap> <offAxisAngle> <galCoeff> <isoCoeff>
#	where:
#	offAxisAngle is in degrees;
#	galcoeff and isocoeff are the coefficients for the galactic and isotropic diffuse components. 
#	If positive they will be considered fixed (but see galmode and isomode below).
#	The file names are separated by a space, so their name should not contain one.

# SOURCE LIST
#Each source is described by a line containing space separated values, in the following order:
# <flux> <l> <b> <spectral index> <fixFlag> <minSqrt(TS)> <name> <location limitation> <funtype> <par2> <par3> <par2 limit min> <par2 limit max> <par3 limit min> <par3 limit max>
# The first 4 values, flux in cm^-2 s^-1, galactic longitude and latitude in degrees, and spectral index of each source, represent the initial estimates of the values for that source (a positive number). According to the fixflag some or all of those values will be optimized by being allowed to vary.
#The flux estimates are relevant in the fitting process, as the sources are considered one by one starting with the one with the brightest initial flux value, regardless of the order they are given in the source file.
#The fixflag is a bit mask, each bit indicating whether the corresponding value is to be allowed to vary:
# fixFlag = 1 indicates the flux,
# fixFlag = 2 the position
# fixFlag = 4 the spectral index
# fixFlag = 8 par2 variable (and flux variable)
# fixFlag = 16 par3 variable (and flux variable)
# fixFlag = 32 force position to be variable only in Loop2
#The user may combine these values, but the flux will always be allowed to vary if at least one of the other values are.
#Examples:
#fixFlag = 0: everything is fixed. This is for known sources which must be included in order to search for other nearby sources.
#fixFlag = 1: flux variable, position fixed
#fixFlag = 2: only the position is variable, but AG_multi will let the flux vary too, so this is equivalent to 3.
#fixFlag = 3: flux and position variable, index fixed
#fixFlag = 4: index variable (and flux variable)
#fixFlag = 5: flux and index variable, position fixed
#fixFlag = 7: flux, position and index variable and also
#fixFlag = 28: index, par2 and par3 variable (and flux variable)
#fixFlag = 30: position index, par2 and par3 variable (and flux variable)

#minSqrt(TS) is the minimum acceptable value for the square root of TS: if the optimized significance of a source lies below this value, the source is considered undetected and will be ignored (set to flux = 0) when considering the other sources.
#The name of the source cannot contain any space. It is used to refer to this source in all the output files, and as part of the name of the source-specific output file.

#typefun
#0) "PL", "x^(-[index])"
#1) "PLExpCutoff", "x^(-[index]) * e^(- x / [par2])"
#2) "PLSuperExpCutoff", "x^(-[index]) * e^(- pow(x / [par2], [par3]))"
#3) "LogParabola", "( x / [par2] ) ^ ( -( [index] + [par3] * log ( x / [par2] ) ) )"

#GALMODE e ISOMODE
#   galmode and isomode are an integer value saying how the corresponding coefficients galcoeff or 
#   isoCoeff found in all the lines of the maplist are to be used:
#		0: all the coefficients are fixed.
#		1: all the coefficients are fixed if positive, variable if negative (the absolte value is the 
#		initial value). This is the default behaviour.
#		2: all the coefficients are variable, regardless of their sign.
#		3: all the coefficients are proportionally variable, that is the relative weight of their absolute value is kept.

#GALMODE2
#0 none
#1 set gal0 for L0 and gal1 for L1
#2 set gal0 for L0 and L1
#3 set gal1 for L0 and L1

#GALMODE2FIT
#	0 do not fit
#	1 pol0 fit
#	2 powerlaw fit

#ISOMODE2
#0 none
#1 set gal0 for L0 and gal1 for L1
#2 set gal0 for L0 and L1
#3 set gal1 for L0 and L1

#ISOMODE2FIT
#	0 do not fit
#	1 pol0 fit
#	2 powerlaw fit


load ENV["AGILE"] + "/scripts/conf.rb"
load ENV["AGILE"] + "/scripts/MultiOutput6.rb"
datautils = DataUtils.new
fits = Fits.new

if ARGV[0].to_s == "help" || ARGV[0].to_s == "h" || ARGV[0] == nil
	system("head -116 " + $0 );
	exit;
end

filter = ARGV[0]
inputmaplist = ARGV[1];
listsource = ARGV[2];
baseoutfile = ARGV[3];
baseoutfile2 = ARGV[3];

p = Parameters.new
p.processInput(3, ARGV, filter)
alikeutils = AlikeUtils.new
multioutput = MultiOutput6.new

prefix = p.prefix
cts = ""
if prefix != -1 then
	cts = prefix.to_s + ".cts.gz";
	exp = prefix.to_s + ".exp.gz";
	gas = prefix.to_s + ".gas.gz";
end



#check energy range of input maps
emin_sin = 50000;
emax_sin = 0;
File.open(inputmaplist).each_line do | line |
	cts = line.split(" ")[0];
	fits.readFitsHeader(cts);
	if(emin_sin.to_f > fits.minenergy.to_f)
		emin_sin = fits.minenergy.to_f
	end
	if(emax_sin.to_f < fits.maxenergy.to_f)
		emax_sin = fits.maxenergy.to_f;
	end
	exp = line.split(" ")[1];
	gas = line.split(" ")[2];
end
puts "MAPS: emin " + emin_sin.to_s + " emax " + emax_sin.to_s

#if different from default energy range of input source list, generate a new sourcelist with the energy range of the input maps
if(emin_sin.to_f != p.emin_sources.to_f or emax_sin.to_f != p.emax_sources.to_f)
	puts "change the flux"
	listsourceold = listsource
	listsource = format("en_%05d_%05d_", emin_sin, emax_sin) + listsource 
	fouts = File.new(listsource, "w")
	File.open(listsourceold).each_line do | line |
        l = line.split(" ")
        gamma = l[3].to_f
        fl = l[0].to_f
		
		c = p.emin_sources.to_f
		d = p.emax_sources.to_f
		a = emin_sin.to_f
		b = emax_sin.to_f
        
        p1 = fl * (gamma-1) / ( c ** (1-gamma) - d ** (1-gamma) )
        
        f1 = (p1 / (gamma-1)) * ( a ** (1-gamma) - b ** (1-gamma) )
        
        fouts.write(f1.to_s)
        for ii in 1..l.size()
        	fouts.write(" " + l[ii].to_s)
        end
        fouts.write("\n")
	end
	fouts.close()
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

doublestep_thr = nil
doublestep_fixflag = nil
if p.doublestep != nil
	stepi=2
	prefixi = ".step1"
	begin
		doublestep_thr = "3.0";
		doublestep_fixflag = "1";
		doublestep_maxradius = "0.0";
		doublestep_thr = p.doublestep.split(",")[0]
		doublestep_fixflag = p.doublestep.split(",")[1]
		doublestep_maxradius = p.doublestep.split(",")[2]
	rescue
		puts "error in doublestep parameters"
	end
end

lastoutfile = ""
outfile2 = baseoutfile2

cmd = "cp " + PATH + "share/AG_multi5.par . "
datautils.execute(outfile2, cmd);
cmd = "cp " + PATH + "share/AG_multi5ext.par . "
datautils.execute(outfile2, cmd);

for i in 1..stepi
	#outfile
	outfile = baseoutfile
	

	#selezione delle calibration matrix
	filterbase = filter.split("_")[0];
	datautils.getResponseMatrix(filter);
	matrixconf = datautils.getResponseMatrixString(filter);
	
	#per prima cosa, se richiesto, si cerca il valore di gal e iso
	inputfilemaps = inputmaplist
	if p.fixisogalstep0 != nil
		outfile22 = outfile.to_s + ".step0"
		inputfilemaps22 = outfile.to_s + ".step0" + ".maplist4"
		alikeutils.rewriteMaplist(inputfilemaps, inputfilemaps22, p.galcoeff, p.isocoeff)
		
		#aggiorna il .multi mettendo a fixflag=1 solo la sorgente specificata in p.fixisogalstep0
		newlistsource = outfile.to_s + ".step0" + ".multi"
		alikeutils.rewriteMultiInputWithSingleSourceToAnalyze(listsource, newlistsource, p.fixisogalstep0, "1");
		
		if p.listsourceextended == "" 
			cmd = "export PFILES=.:$PFILES; " + PATH + "bin/AG_multi5 " + inputfilemaps22.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + newlistsource.to_s + " " + outfile22.to_s + " " + ulcl.to_s + " " + loccl.to_s + " " + p.galmode2.to_s + " " + p.galmode2fit.to_s + " " + p.isomode2.to_s + " " + p.isomode2fit.to_s + " " + p.edpcorrection.to_s + " " + p.fluxcorrection.to_s + " " + p.minimizertype.to_s +  " " + p.minimizeralg.to_s + " " + p.minimizerdefstrategy.to_s + " " + p.mindefaulttolerance.to_s;
			datautils.execute(outfile2, cmd)	
		else
			cmd = "export PFILES=.:$PFILES; " + PATH + "bin/AG_multi5ext " + inputfilemaps22.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + newlistsource.to_s + " " + p.listsourceextended + " " + outfile22.to_s + " " + ulcl.to_s + " " + loccl.to_s + " " + p.galmode2.to_s + " " + p.galmode2fit.to_s + " " + p.isomode2.to_s + " " + p.isomode2fit.to_s + " " + p.edpcorrection.to_s + " " + p.fluxcorrection.to_s + " " + p.minimizertype.to_s +  " " + p.minimizeralg.to_s + " " + p.minimizerdefstrategy.to_s + " " + p.mindefaulttolerance.to_s;
			datautils.execute(outfile2, cmd)
		end
		
		#step0b: prendi il valore di gal e iso calcolati e genera il maplist4 per le analisi successive
		multioutput.readDataSingleSource2(outfile22, p.fixisogalstep0);
		maplist = outfile22 + ".tmpmaplist4"
		
		alikeutils.rewriteMaplist(inputfilemaps, maplist, multioutput.galcoeff, multioutput.isocoeff)
		
	end
	
	if p.fixisogalstep0 == nil
		#copy the .maplist4 in .maplist
		maplist = outfile.to_s + ".maplist4"
		if p.galcoeff.to_f >= -1 and p.isocoeff.to_f >= -1
			alikeutils.rewriteMaplist(inputmaplist, maplist, p.galcoeff, p.isocoeff);
		else	
			system("cp " + inputmaplist + " " + maplist)
		end
	end
	
	#si esce dai due step precedenti con il maplist corretto

	if p.findermultimode != nil && i.to_i == 2
		prefixi = ""
		ulcl = p.ulcl
		loccl = p.loccl
	end
	
	if p.doublestep != nil && i.to_i == 2
		prefixi = ""
	end

	if maplist != nil
		inputfilemaps = outfile.to_s + prefixi.to_s + ".maplist4"
		#if p.findermultimode != nil
		if maplist != inputfilemaps
			if File.exists?(inputfilemaps) == false
				datautils.execute(outfile2, "cp " + maplist.to_s + " " + inputfilemaps.to_s)
			end
		end
		maplist = inputfilemaps
	end
	
	##....

	#list source
	newlistsource = outfile.to_s + prefixi.to_s + ".multi" 
	#if p.findermultimode != nil && i.to_i == 1
		if File.exists?(newlistsource) == false
			datautils.execute(outfile2, "cp " + listsource.to_s + " " + newlistsource.to_s)
		end
	#end
	if p.findermultimode != nil && i.to_i == 2
		#rewrite newlistsource
	
		multioutput.readDataSingleSource2(lastoutfile, p.findermultimode.split(",")[0])
	
		alikeutils.rewriteMultiInputWithNewCoordinatesSource(listsource, newlistsource, p.findermultimode.split(",")[0], multioutput.l_peak, multioutput.b_peak);
	
	end

	if p.doublestep != nil && i.to_i == 1
		#rewrite newlistsource with fixflag == 1 for all the sources except source names starting with _
		alikeutils.rewriteMultiListWithFixflag(listsource, newlistsource, 1)
	end
	
	if p.doublestep != nil && i.to_i == 2
		#rewrite newlistsource with fixflag = doublestep_fixflag, sqrt(TS) > doublestep_thr except for sources with source name starting with _
		cmd = "convertMultiResToInput.rb " + lastoutfile.to_s + " " + newlistsource.to_s + " " + doublestep_fixflag.to_s + " " + doublestep_thr.to_s + " " + doublestep_maxradius.to_s + " 90 1"
		puts cmd
		datautils.execute(outfile2, cmd)
	end

	newoutfile = outfile.to_s + prefixi.to_s
	
	if p.listsourceextended == ""
	
		cmd = "export PFILES=.:$PFILES; " + PATH + "bin/AG_multi5 " + inputfilemaps.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + newlistsource.to_s + "  " + newoutfile + " " + ulcl.to_s + " " + loccl.to_s + " " + p.galmode2.to_s + " " + p.galmode2fit.to_s + " " + p.isomode2.to_s + " " + p.isomode2fit.to_s + " " + p.edpcorrection.to_s + " " + p.fluxcorrection.to_s + " " + p.minimizertype.to_s +  " " + p.minimizeralg.to_s + " " + p.minimizerdefstrategy.to_s + " " + p.mindefaulttolerance.to_s;
		datautils.execute(outfile2, cmd)
	
	else
		
		cmd = "export PFILES=.:$PFILES; " + PATH + "bin/AG_multi5ext " + inputfilemaps.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + newlistsource.to_s + " " + p.listsourceextended.to_s + " " + newoutfile + " " + ulcl.to_s + " " + loccl.to_s + " " + p.galmode2.to_s + " " + p.galmode2fit.to_s + " " + p.isomode2.to_s + " " + p.isomode2fit.to_s + " " + p.edpcorrection.to_s + " " + p.fluxcorrection.to_s + " " + p.minimizertype.to_s +  " " + p.minimizeralg.to_s + " " + p.minimizerdefstrategy.to_s + " " + p.mindefaulttolerance.to_s;
		datautils.execute(outfile2, cmd)
		
	end
	
	
	
	if p.checksourceposition != nil
		checksource_name = p.checksourceposition.split(",")[0]
		checksource_maxR = p.checksourceposition.split(",")[1]
		multioutput.readDataSingleSource2(newoutfile, checksource_name);
		#usa r se e' presente l'ellisse
		if multioutput.r.to_f > 0
			checksource_maxR = multioutput.r.to_f
		end
		
		#check if ff>1 and check if too far
		if multioutput.fix.to_i > 1 and multioutput.dist.to_f > checksource_maxR.to_f
			#repeat analysis
			newlistsource2 = "far." + newlistsource.to_s
			alikeutils.rewriteMultiInputWithSingleSourcenewFixFlag(newlistsource, newlistsource2, checksource_name, "1");
			
			#clean results
			puts "rm " + newoutfile + ".res* *.source"
            system("rm " + newoutfile + ".res*")
            system("rm " + newoutfile + "*.source*")
			
			if p.listsourceextended == ""
	
				cmd = "export PFILES=.:$PFILES; " + PATH + "bin/AG_multi5 " + inputfilemaps.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + newlistsource2.to_s + "  " + newoutfile + " " + ulcl.to_s + " " + loccl.to_s + " " + p.galmode2.to_s + " " + p.galmode2fit.to_s + " " + p.isomode2.to_s + " " + p.isomode2fit.to_s + " " + p.edpcorrection.to_s + " " + p.fluxcorrection.to_s + " " + p.minimizertype.to_s +  " " + p.minimizeralg.to_s + " " + p.minimizerdefstrategy.to_s + " " + p.mindefaulttolerance.to_s;
				datautils.execute(outfile2, cmd)
				
			else
		
				cmd = "export PFILES=.:$PFILES; " + PATH + "bin/AG_multi5ext " + inputfilemaps.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + newlistsource2.to_s + " " + p.listsourceextended.to_s + " " + newoutfile + " " + ulcl.to_s + " " + loccl.to_s + " " + p.galmode2.to_s + " " + p.galmode2fit.to_s + " " + p.isomode2.to_s + " " + p.isomode2fit.to_s + " " + p.edpcorrection.to_s + " " + p.fluxcorrection.to_s + " " + p.minimizertype.to_s +  " " + p.minimizeralg.to_s + " " + p.minimizerdefstrategy.to_s + " " + p.mindefaulttolerance.to_s;
				datautils.execute(outfile2, cmd)
		
			end
		end
	end

	#cmd = "ruby ~/grid_scripts3/convertMultiResToReg.rb " + outfile.to_s + " white";
	#datautils.execute(outfile2, cmd)
	
	mout = MultiOutputList.new
	mout.readSources(newoutfile, newlistsource, p.flag);

	cmd = "ruby " + ENV["AGILE"] + "/scripts/convertMultiInputToReg.rb " + newlistsource.to_s + " green";
	datautils.execute(outfile2, cmd)

	
	fits.readFitsHeader(cts.to_s);
	cmd = "echo \"" + fits.utc_start + "\" >> " + newoutfile.to_s + "";
	datautils.execute(outfile2, cmd)

	cmd = "echo \"" + fits.utc_end + "\" >> " + newoutfile.to_s + "";
	datautils.execute(outfile2, cmd)
	
	cmd = "ruby " + ENV["AGILE"] + "/scripts/convertMultiResToInput.rb " + newoutfile.to_s + "  " + newoutfile.to_s + ".resfull.multi";
	datautils.execute(outfile2, cmd)
	
	cmd = "ruby " + ENV["AGILE"] + "/scripts/extractres2.rb " + newoutfile.to_s + ".resfull " + newoutfile.to_s + ".res2 none";
	datautils.execute(outfile2, cmd)

	#cmd = "ruby ~/grid_scripts3/convertMultiResToRegData.rb " + outfile.to_s;
	#datautils.execute(outfile2, cmd)

	if PARALLEL_OR_ITERATIVE.to_i == 1
		#cmd = "ruby ~/grid_scripts3/convertMultiResToHTML.rb " + outfile.to_s;
		#datautils.execute(outfile2, cmd)
	end

	system("cat " + newoutfile.to_s + "")

	lastoutfile = newoutfile
	
	if p.scanmaplist != 0
		sourcename = p.scanmaplist.split(",")[0]
		prefixscan = p.scanmaplist.split(",")[1]
		mouthe = MultiOutput6.new
		mouthe.readDataSingleSource(newoutfile + "_"+sourcename+".source")
		puts mouthe.sicalc
		puts mouthe.galcoeff
		puts mouthe.isocoeff
		
		newoutfile2 = prefixscan + "_" + newoutfile;
		
		fheso = File.new(newoutfile2 + "_1.multi", "w")
		File.open(newoutfile + ".multi").each_line do | line |
			ll = line.split(" ")
			if ll[6] == sourcename
				fheso.write(ll[0].to_s + " " + ll[1].to_s + " " + ll[2].to_s + " " + mouthe.sicalc + " 1 " + ll[5].to_s + " " + ll[6].to_s + " " + ll[7].to_s + " " + mouthe.typefun + " " + mouthe.par2 + " " + mouthe.par3 + "\n")
			else
				fheso.write(line)
			end
		end
		fheso.close()
		
		cmd = $0 + " " +  filter + " " + newoutfile + ".maplist4 " + newoutfile2 + "_1.multi " + newoutfile2 + "_1 galcoeff=" + mouthe.galcoeff + " isocoeff=" + mouthe.isocoeff + " fluxcorrection=" + p.fluxcorrection.to_s + " edpcorrection=" + p.edpcorrection.to_s
		puts cmd
		system cmd
		
		
		indexmapl = 0;
		fres = File.new(prefixscan + "_1.spe", "w")
		puts "open " + newoutfile + ".maplist4"
		File.open(newoutfile + ".maplist4").each_line do | line |
			lname = prefixscan + "_" + line.split(" ")[0].split(".cts.gz")[0]
			fml = File.new(lname + "_1.maplist4", "w")
			fml.write(line)
			fml.close()
			cmd = $0 + " " +  filter + " " + lname + "_1.maplist4 " + newoutfile2 + "_1.multi " + lname + " galcoeff=" + mouthe.galcoeff.split(",")[indexmapl] + " isocoeff=" + mouthe.isocoeff.split(",")[indexmapl] + " fluxcorrection=" + p.fluxcorrection.to_s + " edpcorrection=" + p.edpcorrection.to_s
			puts cmd
			system cmd
			
			mouthe2 = MultiOutput6.new
			mouthe2.readDataSingleSource(lname + "_"+sourcename+".source")
			#(0)sqrtts (1)flux[ph/cm2/s] (2)flux_err (3)erg[erg/cm2/s] (4)Erg_err (5)Emin (6)Emax (7)E_log_center (8)exp (9)flux_ul (10)spectral_index (11)spectral_index_err (12)id_detection or expcorfactor
			alpha = -mouthe2.sicalc.to_f;
			e_min = mouthe2.energyrange.split("..")[0].to_f
			e_max = mouthe2.energyrange.split("..")[1].to_f
			ec = 0
			if alpha != -2
				ec = ( 1 / (alpha+2) ) *  (( e_max ** (alpha+2))  -  (e_min ** (alpha+2)) )  /  ( ( 1 / (alpha+1) ) * ( e_max ** (alpha+1))  -  e_min ** (alpha+1));
			else
				ec = Math.log(e_max/e_min) / ( ( ( e_max ** (alpha+1))  -  (e_min ** (alpha+1))) / (alpha + 1 ) );
			end
			
			ec = format("%.3f", e_min - ec)
			
			fres.write(mouthe2.sqrtTS.to_s + " " + mouthe2.flux.to_s + " " + mouthe2.flux_error.to_s + " " + " 0.0 " + " 0.0 " + e_min.to_s + " " + + e_max.to_s + " " + ec.to_s + " " + mouthe2.expspectracorfactor.to_s + " " + mouthe2.flux_ul.to_s + " " + mouthe2.sicalc.to_s + " " + mouthe2.sicalc_error.to_s + " " + mouthe2.likelihood1.to_s + "\n")
			indexmapl = indexmapl.to_i + 1
		end
		fres.close()
		
		
		

	end

end

cmd = "rm ./AG_multi5.par"
#datautils.execute(outfile2, cmd);

exit(0)
