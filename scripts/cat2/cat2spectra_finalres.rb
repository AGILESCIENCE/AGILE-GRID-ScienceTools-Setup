#! /usr/bin/ruby
sourcename = ARGV[0]
spectratype = ARGV[1] #pl plec plsec lp
energyrange = ARGV[2] #00100-10000 00100-50000
analysisname = ARGV[3] #EDP1-EB01-FB01
irf = ARGV[4]
inttype = ARGV[5] #1-8
minradius = ARGV[6]
prefix = ARGV[7]
addff = ARGV[8] #1 (only flux free) or 3 (flux and position free)

fixsi = nil
if ARGV[9] != nil
	fixsi = ARGV[9].to_s;
end

load ENV["AGILE"] + "/scripts/conf.rb"

alikeutils = AlikeUtils.new

##############################
# DETCATLINE
##############################

catline = " "
galcoeff = "-1"
galcoefffull = "-1"
galcoeffhe = "-1"
fixflag = 1
coordb = 0
#192 314
File.open("/ANALYSIS3/catalogs/cat2_phase6_192all.multi").each do | line |
	ll = line.split(" ")
	if ll[6] == sourcename
		catline = ll[0] + " " + ll[1] + " " + ll[2] + " 2.1 " # + ll[3]
		coordb = ll[2].to_f
		
		if spectratype == "pl"
			fixflag = 4 #4
			if fixsi != nil
				fixflag = 0
			end
			endline = "0 0.0 0.0"
		end
		if spectratype == "plec"
			fixflag = 12
			endline = "1 2000.0 0.0"
		end
		if spectratype == "plsec"
			fixflag = 28
			endline = "2 2000.0 1.0"
		end
		if spectratype == "lp"
			fixflag = 28
			endline = "3 2000.0 1.0"
		end
		
		fixflag = fixflag.to_i +  addff.to_i
		
		if fixsi != nil
			catline = ll[0] + " " + ll[1] + " " + ll[2]  + fixsi.to_s + " " + fixflag.to_s + " " + ll[5] + " " + ll[6] + " " + ll[7] + " 0 0.0 0.0"
		else
			catline = catline + " " + fixflag + " " + ll[5] + " " + ll[6] + " " + ll[7]
			catline += " "
			catline += endline
		end
		
		if ll.size > 11
			for i in 11..ll.size-1
				catline += " "
				catline += ll[i].to_s
			end			
		end
		
		break
	end
end

##############################
# MAPLIST
##############################

suffix = "R" + inttype.to_s  + "_C" + format("%02d", minradius.to_f*10) + "-" + ARGV[1] + "-" + ARGV[2] + "-" + ARGV[3] + "-" + ARGV[4]

fan = prefix + "_FF"+fixflag.to_s+"_" +  suffix

maplist4name = fan + "_FM3.119_ASDCe_"+irf+"_B01_"+energyrange+".maplist4"

maplist4namefull = fan + "_FM3.119_ASDCe_"+irf+"_B01_"+energyrange+".full.maplist4"

maplist4namehe = fan + "_FM3.119_ASDCe_"+irf+"_B01_"+energyrange+".he.maplist4"

f1 = File.new(maplist4name, "w")
gcf = ""
if irf == "H0025"
	f1.write("EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	gcf = "0.7,0.7,0.7,0.7"
	if energyrange.split("-")[1].to_i == 50000
		f1.write("EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
		gcf = "0.7,0.7,0.7,0.7,0.7"
	end
	
end
f1.close()

f2 = File.new(maplist4namefull, "w")
gcffull = ""
if irf == "H0025"
	f2.write("EMIN00030_EMAX00050_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00030_EMAX00050_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00030_EMAX00050_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f2.write("EMIN00050_EMAX00100_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00050_EMAX00100_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00050_EMAX00100_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f2.write("EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f2.write("EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f2.write("EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f2.write("EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f2.write("EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	gcffull = "0.7,0.7,0.7,0.7,0.7,0.7,0.7"
end
f2.close()

f3 = File.new(maplist4namehe, "w")
gcfhe = ""
if irf == "H0025"
	f3.write("EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f3.write("EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f3.write("EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f3.write("EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f3.write("EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	gcfhe = "0.7,0.7,0.7,0.7,0.7"
end
f3.close()

if coordb.to_f < -10 or coordb.to_f > 10
	galcoeff = gcf
	galcoefffull = gcffull
	galcoeffhe = gcfhe
end

puts "##############################################"
puts "### STEP 1 - determination of the parameters"
puts "##############################################"

if addff.to_i == 1
	minf = "25e-08"
else
	minf = "0e-08"
end


system("rm INT_"+fan+"*")
cmd = "multi6.rb FM3.119_ASDC2_"+irf+" " + maplist4name +" none INT_"+fan+" addcat=\""+ catline +"\" catminradius=" + minradius.to_s + " catminflux="+minf.to_s+" fluxcorrection=1 emin_sources=100 emax_sources=50000 edpcorrection=0.75 minimizertype=Minuit minimizeralg=Migrad minimizerdefstrategy=2 scanmaplist=" + sourcename + "," + fan + " fluxcorrection=1 galmode2=3 isomode2=3 galmode2fit=0 isomode2fit=0 integratortype=" + inttype.to_s + " galcoeff=" + galcoeff.to_s
#galmode2=3 isomode2=3
puts cmd
system cmd
#fluxcorrection=1 isomode2=1 isomode2fit=2  # galmode2=1 isomode2=1 galmode2fit=1 isomode2fit=2

puts "####################################################"
puts "### multi preparation
puts "####################################################"


#reprocess with fan + ".multi" as input
newlistsource = fan + ".multi"
newlistsource2 = fan + ".ff1.multi"
alikeutils.rewriteMultiInputWithSingleSourcenewFixFlag(newlistsource, newlistsource2, sourcename, "1");
puts "############ NEW MULTI: " + newlistsource2

puts "####################################################"
puts "### STEP 2 - analysis of energy bins 00030-50000"
puts "####################################################"


suffix = "R" + inttype.to_s  + "_C" + format("%02d", minradius.to_f*10) + "-" + ARGV[1] + "-00030-50000-" + ARGV[3] + "-" + ARGV[4]
fan1 = prefix + "_FF1_" + suffix

cmd = "multi6.rb FM3.119_ASDC2_"+irf+" " + maplist4namefull +" " + newlistsource2 + " INT_"+fan1+" fluxcorrection=1 emin_sources=100 emax_sources=50000 edpcorrection=0.75 scanmaplist=" + sourcename + "," + fan1 + " minimizertype=Minuit minimizeralg=Migrad minimizerdefstrategy=2 fluxcorrection=1 galmode2=3 isomode2=3 galmode2fit=0 isomode2fit=0 integratortype=" + inttype.to_s + " galcoeff=" + galcoefffull.to_s
puts cmd
system cmd

puts "####################################################"
puts "### STEP 2 - analysis of energy bins 00100-50000"
puts "####################################################"


suffix = "R" + inttype.to_s  + "_C" + format("%02d", minradius.to_f*10) + "-" + ARGV[1] + "-00100-50000-" + ARGV[3] + "-" + ARGV[4]
fan1 = prefix + "_FF1_" + suffix

cmd = "multi6.rb FM3.119_ASDC2_"+irf+" " + maplist4namehe +" " + newlistsource2 + " INT_"+fan1+" fluxcorrection=1 emin_sources=100 emax_sources=50000 edpcorrection=0.75 scanmaplist=" + sourcename + "," + fan1 + " minimizertype=Minuit minimizeralg=Migrad minimizerdefstrategy=2 fluxcorrection=1 galmode2=3 isomode2=3 galmode2fit=0 isomode2fit=0 integratortype=" + inttype.to_s + " galcoeff=" + galcoeffhe.to_s
puts cmd
system cmd

