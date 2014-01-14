#0) filter type (F4, FT3ab, FT3)
#1) output file name prefix
#2) tstart (in TT)
#3) tstop (in TT)
#4) l
#5) b
#6) energy min
#7) energy max
#8) fov (60)
#9) map size (diameter of the map in degree)
#10) bin size (0.5, 0.3)
#11) albedorad (default 80, optional)
#12) projection (default ARC, AIT, optional)
#13) step size of exp map gen (default 1, optional)
#14) sky map file name (optional, absolute path)

if ARGV[0].to_s == "help"
	system("head -16 " + $0 );
	exit;
end

filter = ARGV[0];
name = ARGV[1];
cts = name + ".cts.gz";
exp = name + ".exp.gz";
gas = name + ".gas.gz";
int = name + ".int.gz";
t0 = ARGV[2];
t1 = ARGV[3];
l = ARGV[4];
b = ARGV[5];
emin = ARGV[6];
emax = ARGV[7];
fov = ARGV[8];
mapsize = ARGV[9];
bin = ARGV[10];

if emax.to_f > 50000
	puts "Error in the energy range: the maximum energy should be 50000"
	exit(1)
end

emin1 = emin;
emax1 = emax;


if (ARGV[11] != nil)
	albedorad = ARGV[11];
else
	albedorad = 80;
end

if (ARGV[12] != nil)
	proj = ARGV[12];
else
	proj = "ARC";
end

if (ARGV[13] != nil)
	step = ARGV[13];
else
	step = 1;
end

if (ARGV[14] != nil)
	skymap = ARGV[14];	
else
	skymap =  format("%01d_%01d", emin1, emax1) + ".0.1.conv.sky ";
end

filterdir = filter;
if filter == "F4"
	filterdir = "F4_MI"
end

sarmatrix = "AG_GRID_G0017_S0FT3abG_I0003.sar.gz"
#selezione della sar matrix
if filter == "FT3ab"
	sarmatrix = "AG_GRID_G0017_S0FT3abG_I0003.sar.gz"
end
if filter == "F4"
	sarmatrix = "AG_GRID_G0017_S0000F4G_I0003.sar.gz"
end
if filter == "FT3"
	sarmatrix = "AG_GRID_G0017_S000FT3G_I0003.sar.gz"
end

cmd = "~/ADC/scientific_analysis/bin/AG_ctsmapgen /AGILE_PROC2/" + filterdir  + "/INDEX/EVT.index " + cts.to_s + " " + mapsize.to_s + " " + bin.to_s + " "  + l.to_s + " " + b.to_s + " " + t0.to_s + " " + t1.to_s + " " + emin.to_s + " " + emax.to_s + " " + fov.to_s + " " + albedorad.to_s + " 180.0 18 5 " + proj.to_s;
puts cmd
system(cmd)

cmd = "~/ADC/scientific_analysis/bin/AG_expmapgen @/AGILE_PROC2/DATA/INDEX/LOG.log.index " + exp.to_s + " ~/ADC/scientific_analysis/data/" + sarmatrix.to_s + " " + mapsize.to_s + " " + bin.to_s  + " " + l.to_s + " " + b.to_s + " 180.0 " + t0.to_s + " " + t1.to_s + " " + emin.to_s + " " + emax.to_s +  " 2.1 " + fov.to_s + " " + albedorad.to_s +  " 0.5 360.0 5.0 no 18 " + proj.to_s + " " + step.to_s;
puts cmd
system(cmd)

cmd = "~/ADC/scientific_analysis/bin/AG_gasmapgen " + exp.to_s + " " + gas.to_s + " ~/ADC/scientific_analysis/data/" + skymap.to_s;
puts cmd
system(cmd)

aai = Dir["~/ADC/scientific_analysis/bin/AG_intmapgen"];
if aai.size() != 0
	cmd = "~/ADC/scientific_analysis/bin/AG_intmapgen " + exp.to_s + " " + int.to_s + " " + cts.to_s;
	puts cmd
	system(cmd)
end
