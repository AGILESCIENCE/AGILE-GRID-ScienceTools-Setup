#! /usr/bin/ruby
#script compatible with BUILD20
#0) filter type (F4, FT3ab, FT3)
#1) prefix (if specify a prefix, use only 1 map, if -999 use all the maps in the directory) - disabled with parameter maplist
#2) file name of the list (in alike multi format - example 73.0e-08 80.27227 0.73223 2.1 1 2 3EGJ2033+4118)

#Parameters

#3) outfile - output file name
#4) offaxis - off axix pointing for multi3 (default 30)
#5) ranal   - radius of analysis (default 10)
#6) galcoeff     - gal coefficient (default -999) - for multi2 and multi3
#7) isocoeff     - iso coefficient (default -999) - for multi2 and multi3
#6) galmode     - gal mode (default 1) - for multi4
#7) isomode     - iso mode (default 1) - for multi4
#8) ulcl    - upper limit confidence level (default 2),  espressed as sqrt(TS)
#9) loccl   - source location contour confidence level (default 95 (%)confidence level) Vales: 99, 95, 68, 50
#11) lpointing - l pointing for multi2 (default -999)
#12) bpointing - b pointing for multi2 (default -999)
#13) maplist - (default use prefix)
#14) token (enabled if host,token with token >= 1)
#15) findermultimode - (default 0. Use the finder mode of alike multi)
#16) fixisogal2steps - default 0, don't fix

load "~/grid_scripts3/conf.rb"
datautils = DataUtils.new

if ARGV[0].to_s == "help" || ARGV[0].to_s == "h" || ARGV[0] == nil
	system("head -25 " + $0 );
	exit;
end

filter = ARGV[0]

if filter == "-1"
	filter = "FM3.119_ASDCd_I0007"
end

prefix = ARGV[1]
if prefix != -999 then
	cts = prefix.to_s + ".cts.gz";
	exp = prefix.to_s + ".exp.gz";
	gas = prefix.to_s + ".gas.gz";
end
listsource = ARGV[2];
listsourceori = ARGV[2];

p = Parameters.new
p.processInput(3, ARGV)
alikeutils = AlikeUtils.new
multioutput = MultiOutput.new

stepi=1
prefixi = ""
ulcl = p.ulcl
loccl = p.loccl
if p.findermultimode != nil
	stepi=2
	prefixi = "step1."
	ulcl = 0
	loccl = 0
end


lastoutfile = ""

for i in 1..stepi

if p.findermultimode != nil && i.to_i == 2
	prefixi = "step2."
	ulcl = p.ulcl
	loccl = p.loccl
end

#outfile
outfile = prefixi.to_s + p.outfile
outfile2 = prefixi.to_s + p.outfile2

if outfile == ""
	if prefix.to_i != -999
		outfile2 = prefixi.to_s + prefix.to_s + "_" + listsource.to_s 
	else
		outfile2 = prefixi.to_s + "LIST_" + listsource.to_s 
	end
	if p.galcoeff.to_f != -999
		outfile2 += "_gal"
		outfile2 += p.galcoeff.to_s;
	end
	if p.isocoeff.to_f != -999
		outfile2 += "_iso"
		outfile2 += p.isocoeff.to_s;
	end
	outfile = outfile2;
	outfile += ".res"
end

#selezione delle calibration matrix
filterbase = filter.split("_")[0];
datautils.getResponseMatrix(filter);
matrixconf = datautils.getResponseMatrixString(filter);

#maplist
if prefix.to_i != -999 && p.maplist == nil 
	inputfilemaps = outfile2.to_s + ".maplist4"
	fout = File.new(inputfilemaps, "w")
			galc = p.galcoeff
			isoc = p.isocoeff
	
			if p.galcoeff.to_i == -999
				galc = -1
			end
			if p.isocoeff.to_i == -999
				isoc = -1
			end
			fout.write(cts.to_s + " " + exp.to_s + " " + gas.to_s + " " + p.offaxis.to_s + " " + galc.to_s + " " + isoc.to_s + " \n")
	fout.close();
end

if prefix.to_i == -999 && p.maplist == nil 
	inputfilemaps = outfile2.to_s + ".maplist4";
	fout = File.new(inputfilemaps, "w")
	cts = Dir["*.cts.gz"].sort
	exp = Dir["*.exp.gz"].sort
	gas = Dir["*.gas.gz"].sort
	index = 0
	cts.each do | ctsm |
		expm = exp[index]
		gasm = gas[index]
			galc = p.galcoeff
			isoc = p.isocoeff
	
			if p.galcoeff.to_i == -999
				galc = -1
			end
			if p.isocoeff.to_i == -999
				isoc = -1
			end
			fout.write(ctsm.to_s + " " + expm.to_s + " " + gasm.to_s + " " + p.offaxis.to_s + " " + galc.to_s + " " + isoc.to_s + " \n")
		index = index + 1
	end
	fout.close();
end

if p.maplist != nil
	inputfilemaps = prefixi.to_s + p.maplist.to_s
	if p.findermultimode != nil
		system("cp " + p.maplist.to_s + " " + inputfilemaps.to_s)
	end
end

File.open(inputfilemaps).each_line do | line |
	cts = line.split(" ")[0]
	puts "cts " + cts.to_s
	break
end

#list source
listsourcemulti = prefixi.to_s + listsource.to_s 
if p.findermultimode != nil && i.to_i == 1
	system("cp " + listsource.to_s + " " + listsourcemulti.to_s)
end
if p.findermultimode != nil && i.to_i == 2
	#elaborazione della source list QUI QUI QUI QUI QUI QUI QUI
	
	multioutput.readDataSingleSource(lastoutfile, p.findermultimode.split(",")[0])
	
	alikeutils.rewriteMultiInputWithNewCoordinatesSource(listsource, listsourcemulti, p.findermultimode.split(",")[0], multioutput.l_peak, multioutput.b_peak);
	
end


	if p.fixisogal2steps.to_i == 0
		cmd = "~/ADC/scientific_analysis/bin/AG_multi5 " + inputfilemaps.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + listsourcemulti.to_s + "  " + outfile.to_s + " " + ulcl.to_s + " " + loccl.to_s;
	end
	if p.fixisogal2steps.to_i == 1
		outfile22 = outfile.to_s + ".gifree"
		cmd = "~/ADC/scientific_analysis/bin/AG_multi5 " + inputfilemaps.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + listsourcemulti.to_s + "  " + outfile22.to_s + " " + ulcl.to_s + " " + loccl.to_s;
		
		datautils.execute(outfile2, cmd)
		multioutput.readGalIso(outfile22);
		inputfilemaps22 = inputfilemaps.to_s + ".gifixed"
		ffmaps = File.new(inputfilemaps22, "w");
		indexmaps = 0
		File.open( inputfilemaps).each_line do | line |
			ll = line.split(" ")
			outline = ll[0].to_s + " " + ll[1].to_s + " " + ll[2].to_s + " " + ll[3].to_s + " " + multioutput.galcoeff.split(",")[indexmaps.to_i].to_s + " " + multioutput.isocoeff.split(",")[indexmaps.to_i].to_s + "\n"
			indexmaps = indexmaps.to_i + 1
			ffmaps.write(outline)
		end
		ffmaps.close()
		cmd = "~/ADC/scientific_analysis/bin/AG_multi5 " + inputfilemaps22.to_s + " " + matrixconf.to_s + " "  + p.ranal.to_s + " " + p.galmode.to_s + " " + p.isomode.to_s +  " " + listsourcemulti.to_s + "  " + outfile.to_s + " " + ulcl.to_s + " " + loccl.to_s;
	
	end


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

cmd = "ruby ~/grid_scripts3/convertMultiResToReg.rb " + outfile.to_s + " white";
datautils.execute(outfile2, cmd)

cmd = "ruby ~/grid_scripts3/convertMultiInputToReg.rb " + listsourcemulti.to_s + " blue";
datautils.execute(outfile2, cmd)


datautils.extractFITSKeyword(cts.to_s, "DATE-OBS");
cmd = "echo \"" + datautils.fitskeyword.to_s + "\" >> " + outfile.to_s;
datautils.execute(outfile2, cmd)

datautils.extractFITSKeyword(cts.to_s, "DATE-END");
cmd = "echo \"" + datautils.fitskeyword.to_s + "\" >> " + outfile.to_s;
datautils.execute(outfile2, cmd)

#cmd = "ruby ~/grid_scripts3/convertMultiResToRegData.rb " + outfile.to_s;
#datautils.execute(outfile2, cmd)

if PARALLEL_OR_ITERATIVE.to_i == 1
	#cmd = "ruby ~/grid_scripts3/convertMultiResToHTML.rb " + outfile.to_s;
	#datautils.execute(outfile2, cmd)
end

system("cat " + outfile.to_s)

lastoutfile = outfile

end
