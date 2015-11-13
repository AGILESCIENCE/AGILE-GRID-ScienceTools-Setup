#! /usr/bin/ruby
#Analysis of a single source for each healpix ring. Procedure
#A. select a source from the list
#B. select the right ring
#C. analysis of the source with that ring
#D. collection of results
#E. maybe, update of the soure list (it depends by parameters)

#0) source list
#1) maplist (thas must be present in any dir)
#2) filter
#3) dir output
#4) fixflag of analysis of the main source
#5) (optional) distanceToFixFlag0 - for analysis of neighbors. Defaul 360. See next parameters
#6) (optional) fixflagneighbour - if the source of the list is < distanceToFixFlag0 put its fixflag=fixflagneighbour. Default 1
#7) (optional) additionalcmd - additional commands to multi5.rb (optional), e.g. " param=value "
#8) (optional) fixisogalstep0 - 0 none, 1 apply - evaluate gal/iso values. Default 1
#9) (optional) updateres - update results for each step (0, 1). Default 1
#10) (optional) galcoeff - (apply this galcoeff for source with | b | > galcoeffthres_b). Default -1 - Be carefull. One for each map.
#11) (optional) galcoeffthres_b - (see above). Default 6
#11) (optional) maxdistancefromcenter - Default 360. Use fixflag=1 if the calculated source position is maxdistancefromcenter of the map

#NB: tutte le sorgenti sono messe con fixflag=0 di default prima di inziare l'analisi
#Modificatori:
#_ Le sorgenti che hanno il nome che inizia con _ non sono analizzate, ma lasciate nel fondo
## Per le sorgenti che hanno il nome che inizia con # si mette fixflag=3

load ENV["AGILE"] + "/scripts/conf.rb"

def savesourcelist(listfile, sources2)
	fo = File.new(listfile, "w")
	#scrivi il file delle sorgenti
	sources2.each { |s2|
		out = s2.output
		s2.print
		fo.write(out + "\n")
	}
	fo.close()
end

def processInput(startindex, s)
	for i in startindex...s.size
		if s[i] == nil
			break;
		else
			processLine(s[i]);
		end
	end
end


def processLine(argv)
	keyw = argv.split("=")[0];
	value = argv.split("=")[1];
	puts keyw.to_s + " " + value.to_s
	case keyw
		when "updateres"
			updateres = value;
		when "galcoeff"
			galcoeff = value;
		when "galcoeffthres_b"
			galcoeffthres_b = value;
		when "maxdistancefromcenter"
			maxdistancefromcenter = value;
		when "additionalcmd"
			additionalcmd = value;
		when "fixisogalstep0"
			fixisogalstep0 = value;
		when "distanceToFixFlag0"
			distanceToFixFlag0 = value;
		when "fixflagneighbour"
			fixflagneighbour = value;
		else
			puts "Keyword " + argv.to_s + " error."
	end
end

class Source < 
	Struct.new(:flux, :l, :b, :si, :fixflag, :minsqrtts, :name, :rmax)
	 	
	def print
 		puts flux.to_s + " " + l.to_s + " " + b.to_s + " " + si.to_s + " " + fixflag.to_s + " " + minsqrtts.to_s + " " + name.to_s + " " + rmax.to_s
	end

	def output
		@output = flux.to_s + " " + l.to_s + " " + b.to_s + " " + si.to_s + " " + fixflag.to_s + " " + minsqrtts.to_s + " " + name.to_s + " " + rmax.to_s  
	end
end

#0) sources2
#1) l center
#2) b center
#3) outfile
#4) 0) d0 distance from (l,b)
#5) 0) fixflag for source with dist <= d0
def extract_catalog(sources2, l, b, out, dist0)
	datautils = DataUtils.new
	outfile = File.new(out, "w");
	
	sources2.each { |s|
		
		d = datautils.distance(s.l, s.b, l, b);
		
		if d.to_f <= dist0.to_f
			outline = s.output
			outline += "\n";
			puts outline
			outfile.write(outline.to_s);
			puts outline;
		end	
	}
	outfile.close()
end

begin 
	if ARGV[0].to_s == "help" || ARGV[0] == nil || ARGV[0] == "h"
		system("head -25 " + $0 );
		exit;
	end

	datautils = DataUtils.new

	sourcelist = ARGV[0]
	maplist = ARGV[1]
	puts "maplist="+maplist
	filter = ARGV[2]
	puts "filter=" + filter
	diroutput = ARGV[3]
	multilist = diroutput
	fixflaganalysis=ARGV[4]

	distanceToFixFlag0 = 360
	fixflagneighbour = 0
	additionalcmd=nil
	fixisogalstep0 = 0
	updateres = 1
	galcoeff = "-1"
	maxdistancefromcenter = 360.0
	galcoeffthres_b  = 6;
	
	processInput(5, ARGV);
	
	
	outlog = diroutput + ".log"

	cmd = "mkdir " + diroutput
	datautils.execute(outlog, cmd)

	resfilename = diroutput.to_s + ".res"

	sources = Array.new

	fsourcesinput = File.open(sourcelist, "r")

	fsourcesinput.each_line do | line |
		 words = line.split(" ")
		 s = Source.new
		 s.flux = words[0].to_f
		 s.l = words[1].to_f
		 s.b = words[2].to_f
		 s.si = words[3].to_f
		 s.fixflag = words[4].to_i
		 s.minsqrtts = words[5].to_f
		 s.name = words[6].to_s
		 s.rmax = words[7].to_f
		 sources.push(s)
		#   s.print
	end
	
	fsourcesinput.close();

	sources2 = sources.sort_by { |a| [ -a.flux ] }

	sources2.each { |s|
		#s.print
		s.fixflag=0
		#s.rmax = 2.0
		#s.print
	}

	index = 0
	ffinal = diroutput.to_s + ".resfinal"
	ffinalfull = diroutput.to_s + ".resfinalfull"
	ffmulti = diroutput.to_s + ".res.multi"

	fout1 = File.new(ffinal, "w")
	fout2 = File.new(ffinalfull, "w")
	fout3 = File.new(ffmulti, "w")
	
	#create the dir with the results
	system(" mkdir " + diroutput);

	sources2.each { |s|

		namesource = s.name
		puts "############## Analysis of source " + s.name
		
		#salta quelle che iniziano con _
		if namesource[0] == "_" or namesource[0] == 95
			next
		end
		
		puts namesource
	
		#change fixflag for sources too near
		if distanceToFixFlag0.to_f > 0
			sources2.each { |s1|
				d = datautils.distance(s1.l, s1.b, s.l, s.b)
				if d.to_f > distanceToFixFlag0.to_f
					s1.fixflag=0
				else
					s1.fixflag=fixflagneighbour
				end
			}
		end
	
		#metti la sorgente da analizzare con fixflag passato da input
		s.fixflag = fixflaganalysis
		#se le sorgenti iniziano con # mett fixflag=3
		if (namesource[0] == "#" or namesource[0] == 35) and s.fixflag.to_i == 7
			s.fixflag = 3;
		end
	
		#prepare additional commands for multi5.rb
		addcmd = ""
		if additionalcmd != nil
			addcmd = additionalcmd
		end
	
		if fixisogalstep0.to_i == 1
			addcmd = addcmd + " fixisogalstep0=" + namesource.to_s + " "
		end
	
		if s.b >= galcoeffthres_b.to_f or s.b <= -galcoeffthres_b.to_f
			addcmd += " galcoeff=";
			addcmd += galcoeff.to_s;
			addcmd += " "
		else
			ss = galcoeff.split(",").size
			addcmd += " galcoeff=";
			for i in 0...ss.to_i-1
				addcmd += "-1,"
			end	
			addcmd += "-1"
			addcmd += " "
		end
		
		#Select the right ring
		dir1 = Dir["[0-9]*.*"].sort
		mind = 1000
		ringmin = ""
		dir1.each do | dir |
			lc = dir.split(".")[0].to_f
			bc = dir.split(".")[1].to_f
			d = datautils.distance(lc, bc, s.l, s.b)
			if d.to_f < mind.to_f
				mind = d
				ringmin = dir
			end
		end
		Dir.chdir(ringmin);
		system(" mkdir " + diroutput);
		
		cts=""
		File.open(maplist).each_line do | line |
			cts = line.split(" ")[0]
		end
		fits = Fits.new
		fits.readFitsHeader(cts);

		
		#Generate the listfile source list
		extractradius = (fits.mapsize.to_f / 2) * 0.95
		
		#-------------------------------------------------------------------------------
		#Analysis ----------------------------------------------------------------------
		#----------
		resfilename = diroutput.to_s + "_" + format("%03d", index) + ".res"
		listfile = multilist.to_s + "_" + format("%03d", index) + ".multi"
		extract_catalog(sources2, fits.lcenter, fits.bcenter, listfile, extractradius)
		cmd = "ruby " + ENV["AGILE"] + "/scripts/multi5.rb " + maplist.to_s + " " + listfile.to_s + " " + resfilename.to_s + " filter=" + filter  + " " + addcmd.to_s
		datautils.execute(outlog, cmd)
		#--------
	
		#modifico ora i dati della sorgente che e' stata calcolata
		sout = MultiOutput.new
		sout.readDataSingleSource(resfilename.to_s + "_" + namesource.to_s);
	
		#se la significativita' con fixflag=7 e' troppo bassa, metti fixflag=3 e ripeti l'analisi
		#e crea i file che finiscono con .ff3.res
		postfix=""
		if sout.sqrtTS.to_f < 4.0 and s.fixflag.to_i == 7
	
			s.fixflag = 3;
		
			#----------
			resfilename = diroutput.to_s + "_" + format("%03d", index) + ".ff3.res"
			listfile = multilist.to_s + "_" + format("%03d", index) + ".ff3.multi"
			postfix += "_ff3"
			extract_catalog(sources2, fits.lcenter, fits.bcenter, listfile, extractradius)
			cmd = "ruby " + ENV["AGILE"] + "/scripts/multi5.rb " + maplist.to_s + " " + listfile.to_s + " " + resfilename.to_s + " filter=" + filter  + " " + addcmd.to_s
			datautils.execute(outlog, cmd)
			#----------
		
			sout.readDataSingleSource(resfilename.to_s + "_" + namesource.to_s);
	
		end	
		
		#verifica la distanza della sorgente calcolata
		d1 =  datautils.distance(sout.l_peak, sout.b_peak, fits.lcenter, fits.bcenter)
		if d1.to_f > maxdistancefromcenter.to_f
			s.fixflag = 1;
		
			#----------
			resfilename = diroutput.to_s + "_" + format("%03d", index) + ".ff1.res"
			listfile = multilist.to_s + "_" + format("%03d", index) + ".ff1.multi"
			postfix += "_ff1"
			extract_catalog(sources2, fits.lcenter, fits.bcenter, listfile, extractradius)
			cmd = "ruby " + ENV["AGILE"] + "/scripts/multi5.rb " + maplist.to_s + " " + listfile.to_s + " " + resfilename.to_s + " filter=" + filter  + " " + addcmd.to_s
			datautils.execute(outlog, cmd)
			#----------
		
			sout.readDataSingleSource(resfilename.to_s + "_" + namesource.to_s);
		end
	
		d = datautils.distance(sout.l_peak, sout.b_peak, s.l, s.b)
		d1 =  datautils.distance(sout.l_peak, sout.b_peak, fits.lcenter, fits.bcenter)
		
		#eseguita la alike, copio i risulati
		cmd = "cp " + resfilename.to_s + "_" + namesource.to_s + "* " + diroutput
		datautils.execute(outlog, cmd)
		cmd = "cp " + resfilename.to_s + " " + diroutput + "/" + namesource.to_s + ".res"
		datautils.execute(outlog, cmd)

		fout1.write(format("%04d ", index) + sout.multiOutputLine + "\n")
		fout2.write(format("%04d ", index) + sout.multiOutputLineFull4(diroutput + postfix,  ringmin, d1) + "\n")

		#aggiorna i valori
		if updateres.to_i == 1
			s.flux = sout.flux
			s.l = sout.l_peak
			s.b = sout.b_peak
			s.si = sout.sicalc
		end
		
		#alla fine rimettilo a 0
		sources2.each { |s|
			s.fixflag=0
			#s.print
		}

		fout3.write(sout.flux.to_s + " " + sout.l_peak.to_s + " " + sout.b_peak.to_s + " " + sout.sicalc.to_s + " " + " 0 2 " + namesource.to_s + "\n")
		
		index = index + 1
		
		system("cp " + diroutput + "/* " + " ../" + diroutput);
		
		Dir.chdir("..");
	}
	puts index
	fout1.close()
	fout2.close()
	fout3.close()

	cmd = "cp " + ffinal.to_s + " " + diroutput.to_s + "/" + diroutput.to_s + ".res"
	datautils.execute(outlog, cmd)

	cmd = "cp " + ffinalfull.to_s + " " + diroutput.to_s
	datautils.execute(outlog, cmd)

	cmd = "cp " + ffmulti.to_s + " " + diroutput.to_s
	datautils.execute(outlog, cmd)

end
