
filter = ARGV[0];
cts = ARGV[1];
exp = ARGV[2];
gas = ARGV[3];
spectralindex = ARGV[4];
l = ARGV[5];
b = ARGV[6];
emin = ARGV[7];
emax = ARGV[8];
ranal = ARGV[9];
outfile = ARGV[10];

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

cmd = "~/ADC/scientific_analysis/bin/AG_srctest " + exp.to_s + " " + cts.to_s + " " + gas.to_s + " ~/ADC/scientific_analysis/data/" + sarmatrix.to_s + " ~/ADC/scientific_analysis/data/" + edpmatrix.to_s + " ~/ADC/scientific_analysis/data/" + psdmatrix.to_s + " " + spectralindex.to_s + " " + emin.to_s + " " + emax.to_s + " " + l.to_s + " " + b.to_s + " " + ranal.to_s + " " + outfile.to_s;
puts cmd
system(cmd)