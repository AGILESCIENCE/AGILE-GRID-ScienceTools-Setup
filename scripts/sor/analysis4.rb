#! /usr/bin/ruby
#0) config file name

#The config file name has the following configuration
#single (single analysis) - spot6 - single,result_dir,minSqrt(TS),sourcename (0)
#filter_archive_matrix (1)
#tstart (2)
#tstop (3)
#UTC, MJD, TT, CONTACT (4)
#l (5)
#b (6)
#proj: AIT, ARC (7)
#gal or -1 (8)
#iso or -1 (9)
#OP: map params (10)
#OP: hypothesisgen_lowpriority = spotfinder | cat | nop params (11)
#OP: hypothesisgen_mediumpriority = spotfinder | cat | nop params (12)
#radius selection merger or 0 (13) 
#OP: multi params (14)
#OP: ts map mode (15) - nop or op (op=execute TS map generator)
#ds9 = default, none, additional parameters (16) - ARC/AIT = cts
#ds9 = default, none, additional parameters (17) - ARC/AIT = int
#ds9 = default, none, additional parameters (18) - ARC/AIT = exp
#ds9 = default, none, additional parameters (19) - ARC = cts2
#reg file name (to be added to ds9 map generation)
#detGIF (21) - the name of the source used to determina gal and iso parameter fixed (use [tstart-7days, tstart]) 
#iddisp - for push notifications (22)
#dir_run_output,queue (23) - diroutput = where the results are saved (under (ANALYSSI3)), queue (the queue of the cluster) is optional
#email or none (24): the send e-mails with results
#dir_analysis_output (25) (under diroutput): the name of the analysis. The analysis is saved in /ANALYSIS3/dir_run_output/proj_dir_analysis_output
#comments or none (26)
#use reg/con section: yes or no (27) or nop/reg/con (27). NB: yes=reg
#----- (28)
#multi list to be analyzed
#-----
#reg/con section
#
#Example
# spotfinder 0 2 10 0.7 1 50 {1}
# NB: l'ultimo parametro e' l'indice del file nel MAP.maplist4 usato per fare la ricerca degli spot.
# Gli altri parametri sono quelli passato direttamente a spotfinder
# cat cat2b_4.multi 15 0 20 0 30 0 0
#NB: copy the catalogs (in .multi format) in ENV["AGILE"] + "/share/catalogs/"
#
#Save results
#result_dir,minSqrt(TS),sourcename --> save results in result_dir (.source) with sqrt(TS) >= minSqrt(TS) and of a source named 'sourcename' or 'all'

load ENV["AGILE"] + "/scripts/conf.rb"
load ENV["AGILE"] + "/scripts/sor/sorpaths.rb"

def extractcat(hypothesisgen, l, b, outfile)
	h = hypothesisgen.split(" ")
	cmd = "extract_catalog.rb " + PATH_RES + "/catalogs/" + h[1].to_s + " " + l.to_s + " " + b.to_s + " " + outfile + " " + h[2].to_s + " " + h[3].to_s + " " + h[4].to_s + " " + h[5].to_s + " " + h[6].to_s + " " + h[7].to_s + " " + h[8].to_s
	puts cmd
	system cmd

end

def spotfinder(hypothesisgen, outfile, eb, mapsize)
	h = hypothesisgen.split(" ")
	
	prefix = "MAP"

	if eb.to_i != 0
		prefix = "MAP"
		index = 1
		if h.size() == 8
			index = h[7].to_i
		end
		indexfile = 1
		File.open("MAP.maplist4").each_line do | line |
			if index.to_i == indexfile.to_i
				prefix = line.split(" ")[0].split(".cts.gz")[0]
			end
			indexfile = indexfile.to_i + 1
		end
	end
	
	map = ""
	if h[1].to_i == 0
		map = prefix + ".cts.gz"
	else	
		map = prefix + ".int.gz"
	end
	
	cmd = "spotfinder.rb " + outfile + " " + map + " " + h[1].to_s + " " + h[2].to_s + " " + h[3].to_s + " " + h[4].to_s + " " + h[5].to_s + " " + h[6].to_s + " " + mapsize.to_s + " " + prefix + ".exp.gz"
	puts cmd
	system cmd
end

def existsFile(filename)
	if File.exists?(filename)
		return filename
	else
		return ""
	end
end

def plotjpgcts1(ds91, mle, smooth, regfile, reg, fndisplayreg)
	if File.exists?(mle + ".multi.reg") 
		Dir["*.cts.gz"].each do | file |
			if ds91 != "none"
				fname = file.split(".cts.gz")[0]
				if ds91 == "default"
					cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".ctsall 1 -1 " + smooth.to_s + " B all png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
				else
					cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".ctsall " + ds91.to_s +  " png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
				end
				if reg == "yes" or reg == "reg" or reg == "con"
					cmd += " "
					cmd += existsFile(fndisplayreg)
				end
				puts cmd
				system(cmd)
			end
		end
	end
end

def plotjpgint(ds92, mle, smooth, regfile, reg, fndisplayreg)
	if File.exists?(mle + ".multi.reg") 
		Dir["*.int.gz"].each do | file |
			if ds92 != "none"
				fname = file.split(".int.gz")[0]
				if ds92 == "default"
					cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".intall 1 -1 " + smooth.to_s + " B all png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
				else
					cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".intall " + ds92.to_s +  " png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
				end
				if reg == "yes" or reg == "reg" or reg == "con"
					cmd += " "
					cmd += existsFile(fndisplayreg)
				end
				puts cmd
				system(cmd)
			end
		end
	end
end

def plotjpgexp(ds93, mle, regfile, reg, fndisplayreg)
	if File.exists?(mle + ".multi.reg") 
		Dir["*.exp.gz"].each do | file |
			if ds93 != "none"
				fname = file.split(".exp.gz")[0]
				if ds93 == "default"
					cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".expall 1 -1 1 B all png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
				else
					cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".expall " + ds93.to_s +  " png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
				end
				if reg == "yes" or reg == "reg" or reg == "con"
					cmd += " "
					cmd += existsFile(fndisplayreg)
				end
				puts cmd
				system(cmd)
			end
		end
	end
end

def plotjpgcts2(ds94, mle, smooth, regfile, reg, fndisplayreg)
	if File.exists?(mle + ".multi.reg") 
		Dir["*.cts.gz"].each do | file |
			if ds94 != "none"
				fname = file.split(".cts.gz")[0]
				if ds94 == "default"
					#cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".cts2   2 -1 " + smooth.to_s + " B 16 jpg 1800x1800 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
					#if reg == "yes" or reg == "reg" or reg == "con"
					#	cmd += " "
					#	cmd += existsFile(fndisplayreg)
					#end
					#puts cmd
					#system(cmd)
					cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".cts2   2 -1 " + smooth.to_s + " B 16 png 1800x1800 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
					if reg == "yes" or reg == "reg" or reg == "con"
						cmd += " "
						cmd += existsFile(fndisplayreg)
					end
					puts cmd
					system(cmd)
				else
					cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".cts2   " + ds94.to_s +  " png 1800x1800 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
					if reg == "yes" or reg == "reg" or reg == "con"
						cmd += " "
						cmd += existsFile(fndisplayreg)
					end
					puts cmd
					system(cmd)
				end
			
			end
		end
	end
end

datautils = DataUtils.new
alikeutils = AlikeUtils.new
parameters = Parameters.new

filenameconf = ARGV[0];

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
dir_run_output = ""
mail = ""
analysisname = ""
ds91 = "" #default, none, 1 -1 3 B 2
ds92 = "" #default, none, 1 -1 3 B 2
ds93 = "" #default, none, 1 -1 3 B 2
ds94 = "" #default, none, 1 -1 3 B 2
regfile = ""
detGIF = ""
comments = ""
reg = "" #yes/no or nop/con/reg
binsize = 0.3

queue = nil
result_dir = nil
result_dir_minSqrtTS = 0
result_dir_sourcename = "all"

mleindex = 0;
ml = Dir["MLE????"].sort
puts "index: " + ml.size().to_s
if ml.size() > 0
	mleindex = ml[ml.size()-1].split("MLE")[1].to_i;
	mleindex = mleindex.to_i + 1
else
	cmd = "cp MLE0000.conf tmp.conf"
	puts cmd
	#system(cmd)
	cmd = "rm MAP* MLE*"
	puts cmd
	#system(cmd)
	cmd = "mv tmp.conf MLE0000.conf"
	puts cmd
	#system(cmd)
end

mle = "MLE" + format("%04d", mleindex)

filenameconfext = filenameconf
filenameconf = mle + ".conf"

if File.exists?(filenameconf) == false
	cmd = "cp " + filenameconfext  + " " + mle + ".conf "
	puts cmd
	system(cmd)
end

#estrazione lista sorgenti
fndisplayreg = mle + "display"

fnhyp0 = mle+"hypothesis0.multi"
fnhyp = mle+"hypothesis.multi"

f = File.new(fnhyp0 , "w")
fr = nil;

extractmulti = true

File.open(filenameconf).each_line do | line |
	line = line.chomp
	if index.to_i == 0
		typeanalysis_and_result_dir = line
		typeanalysis = typeanalysis_and_result_dir.split(",")[0]
		if typeanalysis_and_result_dir.split(",").size >= 2
			result_dir = typeanalysis_and_result_dir.split(",")[1]
		end
		if typeanalysis_and_result_dir.split(",").size >= 3
			result_dir_minSqrtTS = typeanalysis_and_result_dir.split(",")[2]
		end
		if typeanalysis_and_result_dir.split(",").size >= 4
			result_dir_sourcename = typeanalysis_and_result_dir.split(",")[3]
		end
	end
	#if not (typeanalysis == "single" or typeanalysis == "spot6")
	#	exit
	#end
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
		if mapparam.split("binsize").size() > 1
			binsize  = mapparam.split("binsize")[1].split("=")[1].split(" ")[0]
		else
			binsize = 0.3
		end
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
		regfile = line
		if regfile == "none"
			regfile = ""
		else
			regfile = PATH_RES + "/regs/" + regfile
		end
	end
	if index.to_i == 21
		detGIF = line
	end
	if index.to_i == 22
		iddisp = line
	end
	if index.to_i == 23
		user_and_queue = line
		dir_run_output = user_and_queue.split(",")[0]
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
		if reg == "yes" or reg == "reg"
			fndisplayreg += ".reg"
		end
		if reg == "con"
			fndisplayreg += ".con"
		end
		fr = File.new(fndisplayreg , "w")
	end
	if index.to_i >= 28
		if index.to_i > 28
			if line.to_s == "-----"
				extractmulti = false
				next
			end
			
			if extractmulti == true
				if line.size() > 2
					f.write(line + "\n")
				end
			else
				if line.size() > 2
					fr.write(line + "\n")
				end
			end
		end
	end
	index = index.to_i + 1
end

f.close()
fr.close()


l = l.to_f + 0.0001
l = l.to_s

if proj.to_s == "AIT"
	l = 0.to_s;
	b = 0.to_s;
	mapparam = mapparam.to_s + " proj=AIT mapsize=360 ";
end

mapsize = parameters.mapsize 

if mapparam.split("mapsize").size() > 1
	mapsize  = mapparam.split("mapsize")[1].split("=")[1].split(" ")[0]
end

eb = parameters.energybin

if mapparam.split("eb").size() > 1
	eb  = mapparam.split("eb")[1].split("=")[1].split(" ")[0]
end

puts mleindex
 
if(mleindex.to_i == 0)
	cmd = "map.rb " + filter.to_s + " MAP " + tstart.to_s + " " + tstop.to_s + " " + l.to_s + " " + b.to_s + " timetype=" + timetype.to_s + " " + mapparam.to_s;
	puts cmd
	system(cmd)
end

#MAP.maplist4 hypothesis.multi MLE$10 galcoeff=$8 isocoeff=$9 $11

#TODO hypothesis1.multi
op = hypothesisgen1.split(" ")[0]

fnh1 = mle + "hypothesis1.multi"
system("touch " + fnh1)
if op != "nop"
	if op == "cat"
		extractcat(hypothesisgen1, l, b, fnh1);
	end
	if op == "spotfinder"
		spotfinder(hypothesisgen1, fnh1, eb, mapsize);
	end
end

#TODO hypothesis2.multi
op = hypothesisgen2.split(" ")[0]

fnh2 = mle + "hypothesis2.multi"
system("touch " + fnh2)
if op != "nop"
	if op == "cat"
		extractcat(hypothesisgen2, l, b, fnh2);
	end
	if op == "spotfinder"
		spotfinder(hypothesisgen2, fnh2, eb, mapsize);
	end
end


alikeutils.appendMulti(fnh2, fnh1, mle+"hypothesisM1.multi", radmerger );
alikeutils.appendMulti(mle+"hypothesisM1.multi", fnhyp0, mle+"hypothesisM0.multi", radmerger );

#copy input files
cmd = "mv " + mle + "hypothesisM0.multi " + fnhyp
puts cmd
system(cmd)

if detGIF != "" and detGIF != "tbd" and detGIF != "nop"
	if proj.to_s == "ARC"
		if Dir["*GIFMAP.cts.gz"].size() == 0
			deltatime = 0;
			if timetype.to_s == "MJD"
				deltatime = 7
			end
			if timetype.to_s == "TT"
				deltatime = 7 * 86400
			end
			if timetype.to_s == "CONTACT"
				deltatime = 7 * 14
			end
			cmd = "map.rb " + filter.to_s + " GIFMAP " + (tstart.to_f - deltatime.to_f).to_s + " " + tstart.to_s + " " + l.to_s + " " + b.to_s + " timetype=" + timetype.to_s + " " + mapparam.to_s;
			puts cmd
			system(cmd)
		end
		cmd = "multi5.rb " + filter + " GIFMAP.maplist4 " + fnhyp + " GIF" + mle
		if galcoeff != "-1"
			cmd = cmd + " galcoeff=" + galcoeff
		end
		if isocoeff != "-1"
			cmd = cmd + " isocoeff=" + isocoeff
		end
		cmd = cmd + " " + multiparam
		puts cmd
		system(cmd)
		giffot = "GIF" + mle + "_" + detGIF 
		mo = MultiOutput.new
		mo.readDataSingleSource(giffot);
		if galcoeff == "-1"
			galcoeff = mo.galcoeff
		end
		if isocoeff == "-1"
			isocoeff = mo.isocoeff
		end
	end
end

if not (multiparam.to_s == "nop" || proj.to_s == "AIT")
	cmd = "multi5.rb " + filter + " MAP.maplist4 " + fnhyp + " " + mle + " galcoeff=" + galcoeff + " isocoeff=" + isocoeff  + " " + multiparam
	puts cmd
	system(cmd)
	
	#cmd = "convertMultiResToReg.rb " + mle + " white 0.1"
	#puts cmd
	#system(cmd)
end

if not (tsmapparam.to_s == "nop" || proj.to_s == "AIT")
	cmd = "iterative5.rb " + filter + " MAP.maplist4 outfile=TSMAP_" + mle;
	puts cmd
	system (cmd)
end

#TODO TSMAP

#send mail
puts mail
cmd = "mail -s \"end RUN\" " + mail.to_s + " < " +  mle
puts cmd
system(cmd)
#cat T1.sh | mutt -a T.res.html  bulgarelli@iasfbo.inaf.it -s 'res'

#TODO send notification


#generate .jpg

if proj.to_s == "ARC" and File.exists?(mle + ".reg") and File.exists?(mle + ".multi.reg")
	smooth = 3	
	if binsize.to_f == 0.05
			smooth = 20;
	end
	if binsize.to_f == 0.1
			smooth = 10;
	end
	if binsize.to_f == 0.2
			smooth = 5;
	end
	if binsize.to_f == 0.25
			smooth = 4;
	end
	if binsize.to_f == 0.3
			smooth = 3;
	end
	if binsize.to_f == 0.5
			smooth = 3;
	end
	
	plotjpgcts1(ds91, mle, smooth, regfile, reg, fndisplayreg)
	
	plotjpgint(ds92, mle, smooth, regfile, reg, fndisplayreg)
	
	plotjpgexp(ds93, mle, regfile, reg, fndisplayreg)
	
	plotjpgcts2(ds94, mle, smooth, regfile, reg, fndisplayreg)
	
	plotjpgcts2(ds94, mle + ".step0", smooth, regfile, reg, fndisplayreg)
	plotjpgcts2(ds94, mle + ".step1", smooth, regfile, reg, fndisplayreg)
	
	if result_dir != nil
		begin
			#copia i risultati in result_dir
			pathres = PATH_RES + "/" + result_dir + "/"
			system("mkdir -p " + pathres);
			cmd = "cp " + mle + ".conf " + pathres + "/" + analysisname + "_" + mle + ".conf"
			puts cmd
			system cmd
			cmd = "cp " + mle + ".ll " + pathres + "/" + analysisname + "_" + mle + ".ll"
			puts cmd
			system cmd
			#copy the results of .source
			
			if result_dir_sourcename == "all"
				sourceexpr = mle + "_*.source"
			else
				sourceexpr = mle + "_" + result_dir_sourcename + ".source"
			end
					
			Dir[sourceexpr].each do | file |
					mo = MultiOutput.new
					mo.readDataSingleSource(file)
					if mo.sqrtTS.to_f >= result_dir_minSqrtTS
						system("cp " + file.to_s + " " + pathres + "/" + analysisname + "_" + file);
					end	
			end
			Dir[mle + "*.cts2.png"].each do | file |
				system("cp " + file.to_s + " " + pathres + "/" + analysisname + "_" + file);
			end
			Dir[mle + "*.ctsall.png"].each do | file |
				system("cp " + file.to_s + " " + pathres + "/" + analysisname + "_" + file);
			end
			
		rescue
			puts "error result_dir copy results"
		end		
	end
	
	if typeanalysis == "spot6"
		begin
			
			rttype = analysisname.split("_")[3]
			pathalerts = PATH_RES + "/alerts/" + rttype + "_" + tstart.to_i.to_s + "_" + tstop.to_i.to_s;
			#copy .conf
			system("mkdir -p " + pathalerts);
			cmd = "cp MLE0000.conf " + pathalerts + "/" + analysisname + "_MLE0000.conf"
			puts cmd
			system cmd
			cmd = "cp MLE0000.ll " + pathalerts + "/" + analysisname + "_MLE0000.ll"
			puts cmd
			system cmd
			warningthrmin = 4
			alertthrmin_gal = 4.1
			alertthrmin_egal = 5
			Dir["MLE0000_*.source"].each do | file |
				#rttype = file.split("_")[3]
				mo = MultiOutput.new
				mo.readDataSingleSource(file)
				pref = "_="
				if mo.sqrtTS.to_f > 3
					#create a dir with the time
				   	if mo.sqrtTS.to_f < warningthrmin.to_f 
						pref = "_-"
					end
					if mo.b_peak.to_f > 5 or mo.b_peak.to_f < -5
						if mo.sqrtTS.to_f > alertthrmin_egal.to_f
							pref = "_+"
						end
					end
					if mo.b_peak.to_f <= 5 and mo.b_peak.to_f >= -5
						if mo.sqrtTS.to_f > alertthrmin_gal.to_f
							pref = "_+"
						end
					end
					
					puts "prefix: " + pref + " " + mo.b_peak.to_s + " " + mo.sqrtTS.to_s
					
					#system("mkdir -p " + pathalerts);
					
					if Dir[pathalerts + "/*.source"].size() == 0
						system("cp " + file.to_s + " " + pathalerts + "/" + pref + analysisname + "_" + file);
					else
						snear = false
						
						puts "copy results"
						Dir[pathalerts + "/*.source"].each do | fsource |
							
							mo2 = MultiOutput.new
							mo2.readDataSingleSource(fsource)
							if datautils.distance(mo2.l_peak, mo2.b_peak, mo.l_peak, mo.b_peak).to_f < 1 
								snear = true
								if  mo.sqrtTS.to_f > mo2.sqrtTS.to_f
									#copy .source in the dir, appending the name of this dir
									system("cp " + file.to_s + " " + pathalerts + "/" + pref + analysisname + "_" + file);
									system("rm " + fsource);
									break
								end
							end
						end
						if snear == false
							system("cp " + file.to_s + " " + pathalerts + "/" + pref + analysisname + "_" + file);
						end
					end
				end
			end			
			
		rescue
			puts "error SPOT6 results"
		end
	end
end


if proj.to_s == "AIT"
	smooth = 7
	if binsize.to_f == 1
		smooth = 3
	end
	if binsize.to_f == 0.5
		smooth = 7
	end
    if binsize.to_f == 0.3
    	smooth = 10
    end
    if binsize.to_f == 0.2
    	smooth = 12
    end
    if binsize.to_f == 0.1
    	smooth = 15
    end
	#cmd = "export DISPLAY=localhost:3.0; ds9.rb MAP.cts.gz " + mle  + ".ctsall 2 -1 " + smooth.to_s + " B 2 jpg 1500x1000 " +  regcat.to_s;
	if File.exists?("MAP.cts.gz") and ds91 != "none"
		if ds91 == "default"
			cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb MAP.cts.gz " + mle  + ".ctsall 1 -1 " + smooth.to_s + " B 2 png 1400x1000 ";
		else
			cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb MAP.cts.gz " + mle  + ".ctsall " + ds91.to_s + " png 1400x1000 ";
		end
		if reg == "yes" or reg == "reg"
			cmd += " "
			cmd += fndisplayreg
		end
		puts cmd
		system(cmd)
	end
	if File.exists?("MAP.int.gz") and ds92 != "none"
		if ds92 == "default"
			cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb MAP.int.gz " + mle  + ".intall 0 0.0010 " + smooth.to_s + " B 2 png 1400x1000 ";
		else
			cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb MAP.int.gz " + mle  + ".intall " + ds92.to_s + " png 1400x1000 ";
		end
		if reg == "yes" or reg == "reg"
			cmd += " "
			cmd += fndisplayreg
		end
        puts cmd
        system(cmd)
	end
	if File.exists?("MAP.exp.gz") and ds93 != "none"
		if ds93 == "default"
			cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb MAP.exp.gz " + mle  + ".expall 1 -1 1 B 2 png 1400x1000 ";
		else
			cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb MAP.exp.gz " + mle  + ".expall " + ds93.to_s +  " png 1400x1000 ";
		end
		if reg == "yes" or reg == "reg"
			cmd += " "
			cmd += fndisplayreg
		end
		puts cmd
		system(cmd)
	end
end

#generate auxiliary file orbit
#mjd_mjd
#tstart utc
#tstop utc
tstarttt = 0
tstartutc = 0
tstartmjd = 0
tstoptt = 0
tstoputc = 0
tstoptmjd = 0
if timetype == "TT"
	tstarttt = tstart
	tstoptt = tstop
	tstartutc = datautils.time_tt_to_utc(tstart)
	tstoputc = datautils.time_tt_to_utc(tstop)
	tstartmjd = datautils.time_tt_to_mjd(tstart)
	tstopmjd = datautils.time_tt_to_mjd(tstop)
end
if timetype == "UTC"
	tstarttt = datautils.time_utc_to_tt(tstart)
	tstoptt = datautils.time_utc_to_tt(tstop)
	tstartutc = tstart
	tstoputc = tstop
	tstartmjd = datautils.time_utc_to_mjd(tstartutc)
	tstopmjd = datautils.time_utc_to_mjd(tstoputc)
end
if timetype == "MJD"
	tstarttt = datautils.time_mjd_to_tt(tstart)
	tstoptt = datautils.time_mjd_to_tt(tstop)
	tstartutc = datautils.time_mjd_to_utc(tstart)
	tstoputc = datautils.time_mjd_to_utc(tstop)
	tstartmjd = tstart
	tstopmjd = tstop
end

forbit = File.new("orbit", "w")
forbit.write(format("%.2f", tstartmjd) + "_" + format("%.2f", tstopmjd) + "\n")
forbit.write(tstartutc.to_s + "\n")
forbit.write(tstoputc.to_s + "\n")
forbit.write(tstarttt.to_s + "\n")
forbit.write(tstoptt.to_s + "\n")
forbit.close()



