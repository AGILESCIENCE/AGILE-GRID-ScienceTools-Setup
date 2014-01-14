#0) filter type (F4, FT3ab, FT3)
#1) cts
#2) exp
#3) gas
#4) spectralindex
#5) energy min
#6) energy max
#7) min TS
#8) file name of the list
#9) radius of analysis (10, 15)
#10) outfile
#11) gas coefficient (optional)
#12) iso coefficient (optional)
#13) diagnostic file (optional)

if ARGV[0].to_s == "help"
	system("head -15 " + $0 );
	exit;
end

filter = ARGV[0];
cts = ARGV[1];
exp = ARGV[2];
gas = ARGV[3];
spectralindex = ARGV[4];
emin = ARGV[5];
emax = ARGV[6];
minTS = ARGV[7];
listsource = ARGV[8];
ranal = ARGV[9];
outfile = ARGV[10];
if ARGV[11] != nil
	gascoeff = ARGV[11];
else
	gascoeff = -999;
end
if ARGV[12] != nil
	iso = ARGV[12];
else
	iso = -999;
end
if ARGV[13] != nil
	diagfilename = ARGV[13];
else
	diagfilename = "/dev/null";
end


sarmatrix = "AG_GRID_G0017_S0001_I0001_NEW3.sar"
edpmatrix = "AG_GRID_G0017_S0001_I0001_NEW3.edp"
psdmatrix = "AG_GRID_G0017_S0001_I0001_NEW3.psd"

filterdir = filter;
if filter == "F4"
	filterdir = "F4_MI"
end

#selezione della matrix
if filter == "FT3ab"
	sarmatrix = "AG_GRID_G0017_S0FT3abG_I0003.sar.gz"
	edpmatrix = "AG_GRID_G0017_S0001_I0002.edp.gz"
	psdmatrix = "AG_GRID_G0017_S0001_I0001_NEW3.psd"
end
if filter == "F4"
	sarmatrix = "AG_GRID_G0017_S0000F4G_I0003.sar.gz"
	edpmatrix = "AG_GRID_G0017_S0001_I0002.edp.gz"
	psdmatrix = "AG_GRID_G0017_S0001_I0001_NEW3.psd"
end
if filter == "FT3"
	sarmatrix = "AG_GRID_G0017_S000FT3G_I0003.sar.gz"
	edpmatrix = "AG_GRID_G0017_S0001_I0002.edp.gz"
	psdmatrix = "AG_GRID_G0017_S0001_I0001_NEW3.psd"
end

cmd = "~/ADC/scientific_analysis/bin/AG_srclist " + exp.to_s + " " + cts.to_s + " " + gas.to_s + " ~/ADC/scientific_analysis/data/" + sarmatrix.to_s + " ~/ADC/scientific_analysis/data/" + edpmatrix.to_s + " ~/ADC/scientific_analysis/data/" + psdmatrix.to_s + " " + spectralindex.to_s + " " + emin.to_s + " " + emax.to_s + " " + ranal.to_s + " " + gascoeff.to_s + " " + iso.to_s + " " + minTS.to_s + " " + listsource.to_s + " " + outfile.to_s + " " + diagfilename.to_s;
puts cmd
system(cmd)