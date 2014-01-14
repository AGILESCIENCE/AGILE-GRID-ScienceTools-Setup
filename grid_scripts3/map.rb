#! /usr/bin/ruby
#script compatible with BUILD22
#0) filter DIR (es: FT3ab_2_I0007, FM3.119_2c, F4_2c_I0010)
#1) output file name prefix
#2) contact or time start
#3) contact or time end
#4) l (map center)
#5) b (map center)
# Optional
#6) emin: energy min
#7) emax: energy max
#8) fovradmax: fov rad max (60)
#9) mapsize: map size (diameter of the map in degree)
#10) binsize: bin size (default 0.3)
#11) albedorad: albedorad (default 80, optional)
#12) proj: projection (default ARC, AIT, optional)
#13) expstep: step size of exp map gen (default 4, optional)
#14) spectralindex: spectral index of exp map (optional, default 2.1)
#15) fovradmin: fov rad min (optional, default 0)
#18) fovbinnumber: Optional, default 1 - number of bins between fovradmin and fovradmax. Dim = (fovradmax-fovradmin)/fovbinnumber
#19) phasecode: optional, default 2. If -1 => automatic determination ==>  if (time end  >= 195205161.302375 && phasecode == -1) then phasecode = 2 else 	phasecode = 18
#20) timebinsize: optional, default 999999999
#21) makelc: optional, defaul 0
#22) lpointing: optinal, default -999
#23) bpointing: optional, default -999
#24) galcoeff     - gal coefficient (default -999) - for multi2/3/4
#25) isocoeff     - iso coefficient (default -999) - for multi2/3/4
#26) gasmapversion: optional, default 2, values: 1 (old), 2 (new)
#26) skymapL: sky map low resolution
#27) skymapH: sky map high resolution
#28) timestep: LOG file step size, default 160
#29) energybin: (default 0, 
#	=1 activate [00030-00050] [00050-00100], [00100-00400], [00400-01000], [01000-03000], [03000, 500000])
#	=2 activate [00030-00050] [00050-00100], [00100-00200], [00200-00400], [00400-01000], [01000-03000], [03000, 500000])
#	=3 activate [00100-00200], [00200-00400], [00400-01000], [01000-03000])
#	=4 activate [00100-00200], [00200-00400], [00400-01000])
#	=5 activate [00050-00100], [00100-00200], [00200-00400], [00400-01000], [01000-03000])
#	=6 activate [00100-00200], [00200-00400], [00400-01000], [01000-03000], [03000, 500000])
#	=7 activate [00050-00100], [00100-00200], [00200-00400], [00400-01000], [01000-03000], [03000, 500000])
#This script work both with BUILD19 and BUILD20, BUILD21, BUILD22
#Crea le mappe mancanti, e se ne crea almeno uno aggiunge la corrispondente riga nel .maplitsX. Attenzione quindi alle duplicazioni
#30) timelist: a file with a list of tstart/stop

load "~/grid_scripts3/conf.rb"

datautils = DataUtils.new
parameters = Parameters.new

if ARGV[0].to_s == "help" || ARGV[0] == nil || ARGV[0] == "h"
	system("head -42 " + $0 );
	exit;
end

filter = ARGV[0];
name = ARGV[1];

contact0 = ARGV[2];
contact1 = ARGV[3];
l = ARGV[4];
b = ARGV[5];



datautils.extractFilterDir(filter)
filterdir = datautils.filterdir
filterall = filterdir;

filterbase2 = filter.split("_")[0] + "_" + filter.split("_")[1];

##



#for i in 6...ARGV.size
#	if ARGV[i] == nil
#		break;
#	else
#		parameters.processLine(ARGV[i]);
#	end
#
#end

#parameters.initparam();



parameters.processInput(6, ARGV)

emin1 = parameters.emin;
emax1 = parameters.emax;
datautils.getSkyMatrix(filter, emin1, emax1)
skymap =  datautils.skymatrix;
skymapL = parameters.skymapL;
skymapH = parameters.skymapH;
indexlog = datautils.logindex(filterbase2)
indexfilter = datautils.evtindex(filterbase2)
puts "indexfilter: " + indexfilter.to_s
puts "Sky map: " + skymap.to_s;
eminarr = Array.new
emaxarr = Array.new
puts "parameters.energybin " + parameters.energybin.to_s

if parameters.energybin.to_i == 1
	eminarr = [30, 50, 100, 400, 1000, 3000, 10000]
	emaxarr = [50, 100, 400, 1000, 3000, 10000, 50000]
	energybinnumber = 7
end

if parameters.energybin.to_i == 2
	eminarr = [30,  50, 100, 200,  400, 1000,  3000, 10000]
	emaxarr = [50, 100, 200, 400, 1000, 3000, 10000, 50000]
	energybinnumber = 8
end

if parameters.energybin.to_i == 3
	eminarr = [100, 200,  400, 1000]
	emaxarr = [200, 400, 1000, 3000]
	energybinnumber = 4
end

if parameters.energybin.to_i == 4
	eminarr = [100, 200,  400]
	emaxarr = [200, 400, 1000]
	energybinnumber = 3
end

if parameters.energybin.to_i == 5
	eminarr = [50,  100, 200,  400, 1000,  3000]
	emaxarr = [100, 200, 400, 1000, 3000, 10000]
	energybinnumber = 6
end

if parameters.energybin.to_i == 6
	eminarr = [100, 200,  400, 1000,  3000, 10000]
	emaxarr = [200, 400, 1000, 3000, 10000, 50000]
	energybinnumber = 6
end

if parameters.energybin.to_i == 7
	eminarr = [50,  100, 200,  400, 1000,  3000, 10000]
	emaxarr = [100, 200, 400, 1000, 3000, 10000, 50000]
	energybinnumber = 7
end

if parameters.energybin.to_i == 8
        eminarr = [100, 400,  1000,  100,  100]
        emaxarr = [400, 1000, 50000, 1000, 50000]
        energybinnumber = 5
end

	datautils = DataUtils.new;
	index_name_cor = BASEDIR_ARCHIVE.to_s + "/DATA/INDEX/3901.cor.index"
	puts "index name cor: " + index_name_cor;	
	#estrazione dei tempi min e max dal corfileindex
	if contact0.to_f < 1000000
		datautils.extractTimeMinMaxForContact(index_name_cor, contact0);
		tstart = datautils.tmin;
	else
		tstart = contact0
	end
	if contact1.to_f < 100000
		datautils.extractTimeMinMaxForContact(index_name_cor, contact1);
		tstop = datautils.tmax;
	else
		tstop = contact1
	end
	
	puts "TMIN: " + tstart.to_s;
	puts "TMAX: " + tstop.to_s;

	if tstart.to_f == 0
		puts "Error in TMIN, exit"
		exit(1)
	end
	if tstop.to_f == 0
		puts "Error in TMAX, exit"
		exit(1)
	end


#phasecode

parameters.setPhaseCode(tstop)
puts parameters.energybin
if parameters.energybin.to_i == 0
	energybinnumber = 1;
end

#determination of BUILD
fff = filterdir.split("_")[1];
archivebuild = fff.split("2")[1];
archiveid = ARCHIVE_ID;
if(archivebuild == nil)
	archiveid = ARCHIVE_ID; #BUILD15 o 16
else
	if(archivebuild == "a" || archivebuild == "b")
		archiveid = 1; #BUILD15 o 16
	end
	if(archivebuild == "c")
		archiveid = 0; #BUILD17
	end
end

#selezione della sar matrix
filterbase = filter.split("_")[0]
datautils.getResponseMatrix(filter);

sarmatrix = datautils.sarmatrix;
edpmatrix = datautils.edpmatrix;

#determina la versione installata < BUILD20 o >= BUILD20
nlinects = 17;
begin
	nlinects = File.readlines(ENV['HOME'] + "/ADC/PFILES/AG_ctsmapgen.par").size;
rescue SystemCallError
	nlinects = 17;
end
nlinegas = 3;
begin
	nlinegas = File.readlines(ENV['HOME'] + "/ADC/PFILES/AG_gasmapgen.par").size;
rescue SystemCallError
	nlinegas = 3;
end
nameori = name

flc = nil
if parameters.makelc != nil
	flc = File.new(parameters.makelc, "w")
end

time = tstart
index = 0;
puts time
puts tstop
while time.to_f < tstop.to_f
	t0 = time.to_f
	t1 = time.to_f + parameters.timebinsize.to_f
	if t1.to_f > tstop.to_f
		t1 = tstop
	end
	puts index.to_s + " " + t0.to_s + " " + t1.to_s;

	time = t1;
	index = index + 1;

	if index.to_i == 1 && t1 == tstop
		name = nameori
	else
		name = format("%04d", index) + "_" + nameori.to_s;
	end
	cts = name + ".cts.gz";
	exp = name + ".exp.gz";
	gas = name + ".gas.gz";
	int = name + ".int.gz";
	the = name + ".the.gz";
	conffile = name + ".maplist3";
	conffile4 = name + ".maplist4";
	
	prefix = name

	if File.exists?(conffile) == false
		fconf = File.new(conffile, "w")
	else
		fconf = File.new(conffile, "a")
	end
	if File.exists?(conffile4) == false
		fconf4 = File.new(conffile4, "w")
	else
		fconf4 = File.new(conffile4, "a")
	end
	
	puts "energybinnumber=" + energybinnumber.to_s

coeffindex=0

for stepi in 1..parameters.fovbinnumber.to_i

	for stepe in 1..energybinnumber.to_i
		emin = parameters.emin;
		emax = parameters.emax; 
		prefixi = ""
		if energybinnumber != 1
			emin = eminarr[stepe-1]
			emax = emaxarr[stepe-1]
			prefixi = format("EMIN%05d", emin.to_i) + "_EMAX" + format("%05d", emax.to_i) + "_"
		end
		datautils.getSkyMatrix(filter, emin, emax)
		skymap =  datautils.skymatrix;
		if skymapL == ""
			skymapL =  datautils.skymatrixL;
		end
		if skymapH == ""
			skymapH =  datautils.skymatrixH;
		end
		puts "skymap: " + skymap.to_s
		puts "skymap LOW res: " + skymapL.to_s
		puts "skymap HIGH res: " + skymapH.to_s
		
		if parameters.fovbinnumber.to_i == 1
			
			fovmin = parameters.fovradmin
			fovmax = parameters.fovradmax
			bincenter = 30
			if parameters.lpointing.to_i != -999
				bincenter = datautils.distance(l, b, parameters.lpointing, parameters.bpointing);
			end
		else
			bincenter = ( ((parameters.fovradmax.to_f-parameters.fovradmin.to_f) / parameters.fovbinnumber.to_f) * stepi.to_f ) - ((parameters.fovradmax.to_f-parameters.fovradmin.to_f) / parameters.fovbinnumber.to_f) / 2.0
			fovmin = bincenter.to_f - ((parameters.fovradmax.to_f-parameters.fovradmin.to_f) / parameters.fovbinnumber.to_f) / 2.0
			fovmax = bincenter.to_f + ((parameters.fovradmax.to_f-parameters.fovradmin.to_f) / parameters.fovbinnumber.to_f) / 2.0
			prefixi = prefixi.to_s + format("%02d", stepi.to_i) + "_"
		end
		puts "Map generation for " + stepi.to_s + " fovmin " + fovmin.to_s + " and fovmax " + fovmax.to_s + " with center " + bincenter.to_s

		cts2 = prefixi.to_s  + cts.to_s
		exp2 = prefixi.to_s  + exp.to_s
		gas2 = prefixi.to_s  + gas.to_s
		int2 = prefixi.to_s  + int.to_s
		the2 = prefixi.to_s  + the.to_s
		
		#if File.exists?(cts2) == true
		#	next
		#end
		createdmap = false
		if nlinects.to_i == 17
			#>=BUILD20
			if parameters.timelist.to_s != ""
				ctsexe = "AG_ctsmapgen0"
				expexe = "AG_expmapgen0"
			else
				ctsexe = "AG_ctsmapgen"
				expexe = "AG_expmapgen"
			end
			if File.exists?(cts2) == false
				cmd = "~/ADC/scientific_analysis/bin/" + ctsexe.to_s + " " + indexfilter.to_s  + "  " + cts2.to_s + " " + parameters.mapsize.to_s + " " + parameters.binsize.to_s + " "  + l.to_s + " " + b.to_s + " " + t0.to_s + " " + t1.to_s + " " + emin.to_s + " " + emax.to_s + " " + fovmax.to_s + " " + fovmin.to_s + " " + parameters.albedorad.to_s + " 180.0 " + parameters.phasecode.to_s + " 5 " + parameters.proj.to_s + " " + parameters.timelist.to_s;
				datautils.execute(prefix, cmd);
				createdmap = true
			end
			if File.exists?(exp2) == false
				#campionamento ogni 0.1 sec del file di LOG
				cmd = "~/ADC/scientific_analysis/bin/" + expexe.to_s +  " @" + indexlog.to_s + " " + exp2.to_s + " ~/ADC/scientific_analysis/data/" + sarmatrix.to_s + " " + parameters.mapsize.to_s + " " + parameters.binsize.to_s  + " " + l.to_s + " " + b.to_s + " 180.0 " + t0.to_s + " " + t1.to_s + " " + emin.to_s + " " + emax.to_s +  " " + parameters.spectralindex.to_s + " " + fovmax.to_s + " " + fovmin.to_s + " " + parameters.albedorad.to_s +  " 0.5 360.0 5.0 no " + parameters.phasecode.to_s + " " + parameters.proj.to_s + " " + parameters.expstep.to_s + " " + parameters.timestep.to_s + " " + parameters.timelist.to_s;
				datautils.execute(prefix, cmd);
				createdmap = true
			end

		else
			#BUILD19
			if File.exists?(cts2) == false
				cmd = "~/ADC/scientific_analysis/bin/AG_ctsmapgen  " + indexfilter.to_s  + "  " + cts2.to_s + " " + parameters.mapsize.to_s + " " + parameters.binsize.to_s + " "  + l.to_s + " " + b.to_s + " " + t0.to_s + " " + t1.to_s + " " + emin.to_s + " " + emax.to_s + " " + parameters.fovradmax.to_s + " " + parameters.albedorad.to_s + " 180.0 " + parameters.phasecode.to_s + " 5 " + parameters.proj.to_s;
				datautils.execute(prefix, cmd);
				createdmap = true
			end
			if File.exists?(exp2) == false	
				cmd = "~/ADC/scientific_analysis/bin/AG_expmapgen @" + indexlog.to_s + " " + exp2.to_s + " ~/ADC/scientific_analysis/data/" + sarmatrix.to_s + " " + parameters.mapsize.to_s + " " + parameters.binsize.to_s  + " " + l.to_s + " " + b.to_s + " 180.0 " + t0.to_s + " " + t1.to_s + " " + emin.to_s + " " + emax.to_s +  " " + parameters.spectralindex.to_s + " " + parameters.fovradmax.to_s + " " + parameters.albedorad.to_s +  " 0.5 360.0 5.0 no " + parameters.phasecode.to_s + " " + parameters.proj.to_s + " " + parameters.expstep.to_s + " " + archiveid.to_s + " ~/ADC/scientific_analysis/data/" + edpmatrix.to_s;
				datautils.execute(prefix, cmd);
				createdmap = true
			end
		end

		#cmd = "~/ADC/scientific_analysis/bin/AG_thetamapgen " + indexfilter.to_s + " " + the2.to_s + " " + parameters.mapsize.to_s + " " + parameters.binsize.to_s + " "  + l.to_s + " " + b.to_s + " " + t0.to_s + " " + t1.to_s + " " + emin.to_s + " " + emax.to_s + " " + parameters.fovradmax.to_s + " " + parameters.albedorad.to_s + " 180.0 " + parameters.phasecode.to_s + " 5 " + parameters.proj.to_s;
		#datautils.execute(prefix, cmd);
		
		if parameters.gasmapversion.to_i == 1
			if File.exists?(gas2) == false
				cmd = "~/ADC/scientific_analysis/bin/AG_gasmapgen " + exp2.to_s + " " + gas2.to_s + " " + skymap.to_s;
				datautils.execute(prefix, cmd);
				createdmap = true
			end
		end
		if parameters.gasmapversion.to_i == 2
			if File.exists?(gas2) == false
				cmd = "~/ADC/scientific_analysis/bin/AG_gasmapgen2 " + exp2.to_s + " " + gas2.to_s + " " + skymapL.to_s + " " + skymapH.to_s;
				datautils.execute(prefix, cmd);
				createdmap = true
			end
		end
		
		if File.exists?(int2) == false
			cmd = "~/ADC/scientific_analysis/bin/AG_intmapgen " + exp2.to_s + " " + int2.to_s + " " + cts2.to_s;
			datautils.execute(prefix, cmd);
		end
		
		if createdmap == true
			fconf.write(cts2.to_s + " " + exp2.to_s + " " + gas2.to_s + " " + bincenter.to_s + "\n")
		end
		
		puts "###"
		puts stepi-1
		
		if parameters.galcoeff == -999 or parameters.galcoeff.split(",").size() == 1
			coeffindex = 0
			galc = parameters.galcoeff
			isoc = parameters.isocoeff
		else
			if energybinnumber.to_i > 1
				coeffindex = stepe-1
			end
			if parameters.fovbinnumber.to_i > 1
				coeffindex = stepi-1
			end
			#non è previsto il caso di suddivisione in bin ed energia (per ora)  TODO
			galc = parameters.galcoeff.split(",")[coeffindex]
			isoc = parameters.isocoeff.split(",")[coeffindex]
		end
		
		
	
		if galc.to_i == -999
			galc = -1
		end
		if isoc.to_i == -999
			isoc = -1
		end
		
		if createdmap == true
			fconf4.write(cts2.to_s + " " + exp2.to_s + " " + gas2.to_s + " " + bincenter.to_s + " " + galc.to_s + " " + isoc.to_s + " \n")
		end
		
		if parameters.makelc != nil
			datautils.extractlc(flc, prefixi.to_s + prefix.to_s, l, b, t0, t1)
			system("rm " + prefixi.to_s + prefix.to_s + "*")
		end
	end
		
end

fconf.close()
fconf4.close()

end

if parameters.makelc != nil
	flc.close()
end
