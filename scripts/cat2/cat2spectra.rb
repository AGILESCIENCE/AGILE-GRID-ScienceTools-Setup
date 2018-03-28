
sourcename = ARGV[0]
spectratype = ARGV[1] #pl plec plsec lp
energyrange = ARGV[2] #00100-10000 00100-50000
analysisname = ARGV[3] #EDP1-EB01-FB01
irf = ARGV[4]

fan = ARGV[1] + "-" + ARGV[2] + "-" + ARGV[3] + "-" + ARGV[4]

maplist4name = "FM3.119_ASDCe_"+irf+"_B01_"+energyrange+".maplist4"

f1 = File.new(maplist4name, "w")

if irf == "H0025"
	f1.write("EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00100_EMAX00300_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN00300_EMAX01000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN01000_EMAX03000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN03000_EMAX10000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	if energyrange.split("-")[1].to_i == 50000
		f1.write("EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.cts.gz EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.exp.gz EMIN10000_EMAX50000_FM3.119_ASDCe_H0025_B01.gas.gz 25 -1 -1\n")
	end
end

if irf == "I0025"
	f1.write("EMIN00100_EMAX00200_FM3.119_ASDCe_I0025_B01.cts.gz EMIN00100_EMAX00200_FM3.119_ASDCe_I0025_B01.exp.gz EMIN00100_EMAX00200_FM3.119_ASDCe_I0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN00200_EMAX00400_FM3.119_ASDCe_I0025_B01.cts.gz EMIN00200_EMAX00400_FM3.119_ASDCe_I0025_B01.exp.gz EMIN00200_EMAX00400_FM3.119_ASDCe_I0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN00400_EMAX01000_FM3.119_ASDCe_I0025_B01.cts.gz EMIN00400_EMAX01000_FM3.119_ASDCe_I0025_B01.exp.gz EMIN00400_EMAX01000_FM3.119_ASDCe_I0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN01000_EMAX03000_FM3.119_ASDCe_I0025_B01.cts.gz EMIN01000_EMAX03000_FM3.119_ASDCe_I0025_B01.exp.gz EMIN01000_EMAX03000_FM3.119_ASDCe_I0025_B01.gas.gz 25 -1 -1\n")
	f1.write("EMIN03000_EMAX10000_FM3.119_ASDCe_I0025_B01.cts.gz EMIN03000_EMAX10000_FM3.119_ASDCe_I0025_B01.exp.gz EMIN03000_EMAX10000_FM3.119_ASDCe_I0025_B01.gas.gz 25 -1 -1\n")
	if energyrange.split("-")[1].to_i == 50000
		f1.write("EMIN10000_EMAX50000_FM3.119_ASDCe_I0025_B01.cts.gz EMIN10000_EMAX50000_FM3.119_ASDCe_I0025_B01.exp.gz EMIN10000_EMAX50000_FM3.119_ASDCe_I0025_B01.gas.gz 25 -1 -1\n")
	end
end

f1.close()

#detcatline
catline = " "
File.open("/ANALYSIS3/catalogs/cat2_phase6_192all.multi").each do | line |
	ll = line.split(" ")
	if ll[6] == sourcename
		catline = ll[0] + " " + ll[1] + " " + ll[2] + " " + ll[3]
		if spectratype == "pl"
			fixflag = "4"
			endline = "0 0.0 0.0"
		end
		if spectratype == "plec"
			fixflag = "12"
			endline = "1 2000.0 0.0"
		end
		if spectratype == "plsec"
			fixflag = "28"
			endline = "2 2000.0 1.0"
		end
		if spectratype == "lp"
			fixflag = "28"
			endline = "3 2000.0 1.0"
		end
		
		catline = catline + fixflag + " " + ll[5] + " " + ll[6] + " " + ll[7] + " " + endline
		
		break
	end
end



system("rm INT"+fan+"*")
cmd = "multi6.rb FM3.119_ASDC2_"+irf+" " + maplist4name +" none INT"+fan+" addcat=\""+ catline +"\" fluxcorrection=1 scanmaplist=" + sourcename + "," + fan + " minimizertype=Minuit minimizeralg=Migrad minimizerdefstrategy=2 galmode2=3 isomode2=3 "
puts cmd
#fluxcorrection=1 #isomode2=1 isomode2fit=2  # galmode2=1 isomode2=1 galmode2fit=1 isomode2fit=2

