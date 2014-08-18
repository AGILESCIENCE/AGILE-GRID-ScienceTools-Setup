#0) pattern (OB*.res)
#1) output file name
#2) source name
#3) min sqrt(TS) (optional, default 0)
#4) l starting source (optional, default -999)
#5) b starting source (optional, default -999)
#quelli di seguito sono parametri opzionali, quindi da impostare tipo parametro=valore
#6) radius: max distance from starting source (optional, default -999)
#7) maxR: remove source if outside contour level (optional, default -999 none) - if >= 0 enable this option and use this number as systematic error
#8) clean: clean archive
#9) t0: for calc phase
#10) period: for calc phase

#generate a LC list reading the files with the pattern contained in prefix

load ENV["AGILE"] + "scripts/conf.rb"
load ENV["AGILE"] + "scripts/MultiOutput.rb"

datautils = DataUtils.new
agilefov = AgileFOV.new

if ARGV[0].to_s == "help" || ARGV[0].to_s == "h" || ARGV[0] == nil
	system("head -14 " + $0 );
	exit;
end


a = Dir[ARGV[0]]
a.sort!
ndim = a.size();
output = ARGV[1];
sourcename = ARGV[2]

minsqrtTS = ARGV[3]
l = ARGV[4]
b = ARGV[5]

radius = -999;
maxR = -999;
t0 = 0;
period = 0;

clean=0
for i in 6...ARGV.size
	if ARGV[i] == nil
		break;
	else
		keyw = ARGV[i].split("=")[0];
		value = ARGV[i].split("=")[1];
		puts keyw.to_s + " " + value.to_s
		case keyw
			when "radius"
				radius = value;
			when "maxR"
				maxR = value;
			when "t0"
				t0 = value;
			when "period"
				period = value;
			when "clean"
				clean = value;
		end
	end

end

out = File.new(output, "w");
out1file = output.to_s + ".lc"
out2 = File.new(out1file, "w");
out2file = output.to_s + ".short"
out3 = File.new(out2file, "w");
out3file = output.to_s + ".ob"
out4 = File.new(out3file, "w");

startmjd = -1
endmjd = -1
a.each do | xx |
	index = 0;
	nrow = 0
	nowrite = false;
	
	#conta il numero di righe
	File.open(xx).each_line do | line |
		nrow = nrow + 1;
	end
	#preleva le date di inizio e di fine
	
	tstart = "";
	tstop = "";	
	index = 0;
	phase = 0;
	puts xx
	File.open(xx).each_line do | line |
		 
		if index.to_i == nrow - 2
			ee = line.split("'");
			if ee.size().to_i > 2
				tstart = ee[1];
			end
		end
		if index.to_i == nrow - 1
			ee = line.split("'");
			if ee.size().to_i > 2
				tstop = ee[1];
			end
		end
		index = index.to_i + 1;
	end
	puts tstart.to_s + " / " + tstop.to_s;
	if tstart.to_s == ""
		if clean.to_i == 1
			outcl = File.new("cleaned", "a");
			s1 = xx.split("_")[0]
			puts "rm " + s1 + "*"
			outcl.write(s1 + "\n")
			system("rm " + s1 + "*")
			outcl.close 
			next
		end
	end
	
	obname = xx.split("_")[0];# + "_D" + xx.split("_D")[1].split(".")[0];

	index = 0;

	mo = MultiOutput.new;
	
	mo.readDataSingleSource2(xx, sourcename);

	ul = 0.0;
	exp = 0.0;
	indexul = 0;
	dimf = 0
	
	rsearch = 360;
	parama = ""
	spectindex = 0
	scindex = 0
	scerror = 0
	
	dimr = " l b R A B PHI " 
	if mo.l != -1
		dimr = mo.fullellipseline
	end
	
	#identificazione dell'off-axis
	timestartobs = datautils.time_utc_to_tt(tstart);

	timestopobs = datautils.time_utc_to_tt(tstop);

	lobs = agilefov.longitudeFromPeriod2(timestartobs, timestopobs);
	bobs = agilefov.latitudeFromPeriod2(timestartobs, timestopobs);
				
	#analizza la singola sorgente
	if l.to_f != -999
		ll = l
	else
		ll = lobs;
	end
	if b.to_f != -999
		bl = b
	else
		bl = bobs;
	end	
	
	if maxR.to_f != -999 && mo.l != -1
		d4 = 0
		
		d4 = datautils.distance(ll, bl, mo.l, mo.b)
		if d4.to_f > rsearch.to_f
			next
		end
	end
	
	if maxR.to_f != -999 && mo.l == -1
		next
	end
	
	
	distfov = 0
	distfov = datautils.distance(lobs, bobs, mo.l_peak, mo.b_peak)
	#calcolo fase
	
	timestartmjd = datautils.time_tt_to_mjd(timestartobs);
	#puts timestartmjd
	timestopmjd = datautils.time_tt_to_mjd(timestopobs);
	#puts timestopmjd
	if(period.to_f != 0)
		timemjd = timestartmjd.to_f + (timestopmjd.to_f-timestartmjd.to_f)
		phase = (timemjd.to_f - t0.to_f) / period.to_f;
		phase = phase.to_f - phase.to_i;
	end
	
	ul = mo.flux_ul
	gascoeff = mo.galcoeff
	isocoeff = mo.isocoeff
	spectindex = mo.sicalc.to_s + "+/-" + mo.sicalc_error.to_s
	exp = mo.exposure
	
	
	d3 = 0
	d3 = datautils.distance(ll, bl, mo.l_peak, mo.b_peak)
				
	if radius.to_f != -999
		if d3.to_f > radius.to_f
				next
		end
	end
				
	if tstart.to_s != ""
		outstr = format("%3.2f", mo.l_peak) + "\t" + format("%3.2f", mo.b_peak) + "\t" + format("%3.2f", mo.counts.to_f) + "\t" + format("%3.2f", mo.counts_error.to_f) + "\t" + format("%3.2f", mo.sqrtTS.to_f) + "\t" +  format("%.2e", mo.flux.to_f) + "\t" +  format("%.2e", mo.flux_error.to_f) + "\t" +  format("%.2e", ul.to_f) + "\t" + format("%.2f", gascoeff.to_f) + "\t" + format("%.2f", isocoeff.to_f) + "\t" + format("%3.2f", d3.to_f) + "\t" + obname.to_s + "\t" + format("%.4f", phase.to_f) + "\t" + format("%.2f", timestartmjd) + "-" + format("%.2f", timestopmjd) + "\t" + format("%.2f",distfov);
		
		outstrb = tstart + "-" + tstop  + "\t"  + format("%.6f", timestartobs.to_f) + "\t" + format("%.6f", timestopobs.to_f) + "\t" + lobs.to_s + "\t" + bobs.to_s + "\t" + dimr.chomp.to_s + "\t" + parama.chomp.to_s + "\t" + spectindex.to_s + "\t" + exp.to_s + "\n"
		#timestartobs.to_s + "\t"
		if mo.sqrtTS.to_f >= minsqrtTS.to_f && ul.to_f != 0.0
			puts "OUT " + outstr.to_s + "\t" + outstrb.to_s
			out.write(outstr.chomp + "\t");
			out.write(outstrb.chomp + "\n");
			#out.write("\n")
		end
		outstr3 = format("%3.2f", mo.l_peak) + "\t" + format("%3.2f", mo.b_peak) + "\t" + "\t" + format("%3.2f", mo.sqrtTS.to_f) + "\t" +  format("%.2e", mo.flux.to_f) + "\t" +  format("%.2e", mo.flux_error.to_f) + "\t" +  format("%.2e", ul.to_f) + "\t"  + format("%3.2f", d3.to_f) + "\t" + obname.to_s + "\t" + format("%.4f", phase) + "\t" + format("%.2f", timestartmjd) + "-" + format("%.2f", timestopmjd) + "\t" + tstart + "-" + tstop  + "\t" + format("%.2f",distfov) + "\t" + spectindex.to_s + "\t" + exp.to_s + "\n"
		#timestartobs.to_s + "\t"
		if mo.sqrtTS.to_f >= minsqrtTS.to_f && ul.to_f != 0.0
			out3.write(outstr3);
# 						puts outstr3
		end
	else
		outstr = "      " + format("%3.2f", mo.l_peak) + "     " + format("%3.2f", mo.b_peak) + "    " + format("%3.2f", mo.counts.to_f) + "       " + format("%3.2f", mo.counts_error.to_f) + "   " + format("%3.2f", mo.sqrtTS.to_f) + "    " +  mo.flux.to_s + " " +  mo.flux_error.to_s + " "    + "\n";
		if mo.sqrtTS.to_f >= minsqrtTS.to_f
			out.write(outstr);
		end
	end

	outlc = ""
	mints1 = 0.0
	mints2 = 2.0
	outlc = ul.to_s + "\t0\t\t1\t"
	if mo.sqrtTS.to_f < mints1.to_f || mo.sqrtTS.to_s == "nan"
		outlc = "0\t0\t1\t"
	end
	if mo.sqrtTS.to_f > mints1.to_f and mo.sqrtTS.to_f < mints2.to_f and 
		outlc = ul.to_s + "\t0\t\t1\t"
		
	end
	if mo.sqrtTS.to_f >= mints2.to_f
		outlc = mo.flux.to_s + "\t" + mo.flux_error.to_s + "\t0\t";
	end
	if tstart.to_s != ""
		if startmjd == -1
			startmjd = timestartmjd;
		end
		endmjd = timestopmjd;
		outlc = outlc + format("%.2f", timestartmjd) + "\t" + format("%.2f", timestopmjd-timestartmjd) + "\t" + format("%.2f",distfov) + "\t" + obname.to_s + "\t" + format("%.2f",mo.sqrtTS) + "\t" + exp.to_s + "\t" +  format("%.2f", gascoeff.to_f) + "\t" + format("%.2f", isocoeff.to_f) + "\t" + format("%3.2f", d3.to_f) + "\t" + "( " + dimr.chomp.to_s + " ) \t" + scindex.to_s + "\t" + scerror.to_s + "\n";
	else
		outlc = outlc + "_\t" + format("%.2f",distfov) + "\t" + obname.to_s + "\n";
	end
	if mo.sqrtTS.to_f >= minsqrtTS.to_f && ul.to_f != 0.0  
		out2.write(outlc);
	end
			
	outlcob = "";
	outlcob = format("%.6f", timestartobs.to_f) + "\t" + format("%.6f", timestopobs.to_f) + "\t" + obname.to_s + "\t" + format("%.2f", gascoeff.to_f) + "\t" + format("%.2f", isocoeff.to_f) + "\t" + lobs.to_s + "\t" + bobs.to_s + "\t" + exp.to_s + "\n";
	if mo.sqrtTS.to_f >= minsqrtTS.to_f && ul.to_f != 0.0  
		out4.write(outlcob);
	end		
	
end
out.close();
out2.close();

cmd = "mv " + out1file.to_s + " " + out1file.to_s + ".tmp"
puts cmd
#system(cmd)
cmd = "echo \"" + startmjd.to_s + "\" > " + out1file.to_s
puts cmd
#system(cmd)
cmd = "echo \"" + endmjd.to_s + "\" >> " + out1file.to_s
puts cmd
#system(cmd)
cmd = "cat " + out1file.to_s + ".tmp >> " + out1file.to_s
puts cmd
#system(cmd);
cmd = "rm " + out1file.to_s + ".tmp"
puts cmd
#system(cmd);
