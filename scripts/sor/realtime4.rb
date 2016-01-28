#! /usr/bin/ruby

load ENV["AGILE"] + "/scripts/sor/sorpaths.rb"
load ENV["AGILE"] + "/scripts/conf.rb"

def runait(lastcontacttime, day, hours_shift)

	tstart = 0
	tstop = 0
	abspath=PATH_RES
	lastprocessing2 = 0
	if File.exists?(abspath + "/commands/lastprocessing_aitoff_rt"+format("%02i", day)+"")
		File.open(abspath + "/commands/lastprocessing_aitoff_rt"+format("%02i", day)+"", "r").each_line do | line |
			lastprocessing2 = line.to_i
		end
	end
	
	if lastprocessing2.to_i == 0
		tstart = lastcontacttime.to_i - 86400 * day.to_i
		tstop = lastcontacttime.to_i
	else
		tstop = lastprocessing2 + 3600 * hours_shift.to_i
		tstart = tstop.to_i - 86400 * day.to_i	
	end
	puts "TIME: " + lastcontacttime.to_s + " - " + lastprocessing2.to_s + " - " + tstart.to_s + " " + tstop.to_s
	
	if tstop.to_i <= lastcontacttime.to_i
		#change and copy the card
		fo = File.new("/tmp/aitoff_rt"+format("%02i", day)+".conf", "w")
		index = 0
		File.open(ENV["AGILE"] + "/scripts/sor/cards/ait_rt/aitoff_rt"+format("%02i", day)+".conf").each_line do | line |
			out = line
			if index.to_i == 1
				out = line.split("_")[0] + "_" + ARCHIVE.to_s + "_" + line.split("_")[2]
			end
			if index.to_i == 2
				out = tstart.to_i.to_s + "\n"
			end
			if index.to_i == 3
				out = tstop.to_i.to_s + "\n"
			end
			if index.to_i == 23
				#abspath += line.chomp
				#abspath += "/AIT_"
			end
			if index.to_i == 25
				out = line.chomp + "_" + tstart.to_i.to_s + "_" +  tstop.to_i.to_s + "\n"
				#abspath += out.chomp + "/"
			end
			fo.write(out);
			index = index + 1
		end
		fo.close()
		lastprocessing2 = tstop	
		
		puts "New run AIT: " + "cp /tmp/aitoff_rt"+format("%02i", day)+".conf " + abspath + "/commands/";
		system("cp /tmp/aitoff_rt"+format("%02i", day)+".conf " + abspath + "/commands/");
		
		runspot6(lastcontacttime, day, hours_shift);
		
		f = File.new(abspath + "/commands/lastprocessing_aitoff_rt"+format("%02i", day), "w")
		f.write(lastprocessing2);
		f.close();
		
	end
end

def runspot6(lastcontacttime, day, hours_shift)

	tstart = 0
	tstop = 0
	abspath=PATH_RES
	lastprocessing2 = 0
	if File.exists?(abspath + "/commands/lastprocessing_aitoff_rt"+format("%02i", day)+"")
		File.open(abspath + "/commands/lastprocessing_aitoff_rt"+format("%02i", day)+"", "r").each_line do | line |
			lastprocessing2 = line.to_i
		end
	end
	
	if lastprocessing2.to_i == 0
		tstart = lastcontacttime.to_i - 86400 * day.to_i
		tstop = lastcontacttime.to_i
	else
		tstop = lastprocessing2 + 3600 * hours_shift.to_i
		tstart = tstop.to_i - 86400 * day.to_i	
	end
	#puts "SPOT6: " + lastcontacttime.to_s + " - " + lastprocessing2.to_s + " - " + tstart.to_s + " " + tstop.to_s
	
	if tstop.to_i <= lastcontacttime.to_i
		#change and copy the card
		indexfile = 0;
		Dir[ENV["AGILE"] + "/scripts/sor/cards/spot6/*.conf"].sort.each do | file |
			indexring = 0;
			File.open(ENV["AGILE"] + "/scripts/sor/cards/spot6/rings.coord").each_line do | coords |
				outfileconf = "/tmp/spot6_" + format("%02i", day) + "_" + format("%02d", indexfile) + "_" + format("%02d", indexring) + ".conf";
				fo = File.new(outfileconf, "w")
				index = 0
				File.open(file).each_line do | line |
					out = line
					if index.to_i == 1
						out = line.split("_")[0] + "_" + ARCHIVE.to_s + "_" + line.split("_")[2]
					end
					if index.to_i == 2
						out = tstart.to_i.to_s + "\n"
					end
					if index.to_i == 3
						out = tstop.to_i.to_s + "\n"
					end
					if index.to_i == 4
						out = "TT\n"
					end
					if index.to_i == 5
						out = coords.split(" ")[0].to_f.to_s + "\n"
					end
					if index.to_i == 6
						out = coords.split(" ")[1].to_f.to_s + "\n"
					end
					if index.to_i == 25
						out = line.chomp + format("%02i", day) + "_" + tstart.to_i.to_s + "_" +  tstop.to_i.to_s + "_" + format("RING%02d", indexring) + "\n"
					end
					fo.write(out);
					index = index + 1
				end
				fo.close()
				puts "New run SPOT6: " + "cp " + outfileconf + " " + abspath + "/commands/";
				system("cp " + outfileconf + " " + abspath + "/commands/");
				indexring = indexring.to_i + 1
			end
			indexfile = indexfile.to_i + 1
		end
		#lastprocessing2 = tstop	
		#f = File.new(abspath + "/commands/lastprocessing_spot6_rt"+format("%02i", day), "w")
		#f.write(lastprocessing2);
		#f.close();
		
	end
end

def existsFile(filename)
	if File.exists?(filename)
		return filename
	else
		return ""
	end
end

def genaitoffspot6(rttype)
	abspath=PATH_RES + "/aitoff_rt/"
	b02=Dir[abspath + "*" + rttype + "*/orbit"].sort()
	last02 = b02[b02.size() - 1].split("orbit")[0]
	pathaitoff = last02 + "/MAP.cts.gz";
	pathaitoffint = last02 + "/MAP.int.gz";
	if File.exists?(pathaitoff)
		#build path
		aitname = last02.split("/")[last02.split("/").size - 1]
		aitsplitname = aitname.split("_");
		pathalerts = PATH_RES + "/alerts/" + aitsplitname[1] + "_" + aitsplitname[2] + "_" + aitsplitname[3] + "/"
		#find the AITOFF - questo va rimosso da qui e messo in un task a parte che fa la scansione della dir alert e prende l'ultimo
		
		begin
			mout = MultiOutputList.new
			mout.readSourcesInDir(pathalerts, "spot6", "SPOT6", 4);
		rescue
			puts "gen .reg and .html error"
		end
		
		cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + pathaitoff +  " " + pathalerts + "/" + rttype + "spot6.ctsall 1 -1 7 B 2 png 1400x1000 " + existsFile(pathalerts + "/spot6.reg");
		puts cmd
		system(cmd)
		system("cp " + pathalerts + "/" + rttype + "spot6.ctsall.png /tmp/app/lastaitspot6_"+rttype+".png")
		
		system("cp " + pathalerts + "/spot6.html /tmp/app/lastaitspot6_"+rttype+".html")
		
		if File.exists?(pathaitoffint)
			cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + pathaitoffint +  " " + pathalerts + "/" + rttype + "spot6.intall 0 0.0010 7 B 2 png 1400x1000 " + existsFile(pathalerts + "/spot6.reg");
			puts cmd
			system(cmd)
			system("cp " + pathalerts + "/" + rttype + "spot6.intall.png /tmp/app/lastaitspot6_"+rttype+".int.png")
		end
		
		#send alerts
		begin
			Dir[pathalerts + "/_+*"].each do | file |
				nfile = file.sub("_+", "++")
				system("mv " + file + " " + nfile);
				mout = MultiOutput.new
				mout.readDataSingleSource(name)
				mout.assoc(",")
				subject = "ALERT LEVEL " + format("%.2f", mout.sqrtTS) + " " + format("%.1E", mout.flux) + "+/-" + format("%.1E", mout.flux_error) + " (" + format("%.2f", mout.l_peak) + "," + format("%.2f", mout.b_peak) + "," + format("%.2f", mout.b_peak) + ")" + mout.assoc
				 
				cmd = "mail -s " + subject + " bulgarelli@iasfbo.inaf.it < " + nfile
				puts cmd
				system(cmd)
			end
		rescue
			puts "mail problem"
		end
		
		
	end	
end

begin
        #b=1
        
        #while b == 1
        		
        		cmd = "sort --key=3 " + PATH_DATA + "/FM3.119_" + ARCHIVE + "/INDEX/EVT.index | tail -1 > " + PATH_RES + "/commands/lastorbit "
        		puts cmd
        		system(cmd)
        		lastcontacttime = 0
        		
        		File.open(PATH_RES + "/commands/lastorbit", "r").each_line do | line |
        			lastcontacttime = line.split(" ")[2].to_i
        		end
        		puts "lastcontacttime " + lastcontacttime.to_s
        		
        		#run01
        		runait(lastcontacttime, 1, 1);
        		
        		#run02
        		runait(lastcontacttime, 2, 1);
        		
        		#run04
        		runait(lastcontacttime, 4, 8);
        		
        		#run07
        		runait(lastcontacttime, 7, 12);
        		
              	
                #copy aitoff
                begin
					abspath=PATH_RES + "/aitoff_rt/"
					system("mkdir /tmp/app");
					system("chmod -R g+w /tmp/app");
					b02=Dir[abspath + "*RT02*/orbit"].sort()
					last02 = b02[b02.size() - 1].split("orbit")[0]
					system("cp " + last02 + "/MLE000*.ctsall.jpg /tmp/app/lastait2.jpg")
					system("cp " + last02 + "/orbit /tmp/app/lastait2.orb")
					system("cp " + last02 + "/MLE000*.ctsall.jpg /tmp/app/public.jpg")
					system("cp " + last02 + "/orbit /tmp/app/public.orb")
				
					b04=Dir[abspath + "*RT04*/orbit"].sort()
					last04 = b04[b04.size() - 1].split("orbit")[0]
					system("cp " + last04 + "/MLE000*.ctsall.jpg /tmp/app/lastait4.jpg")
					system("cp " + last04 + "/orbit /tmp/app/lastait4.orb")
				
					b07=Dir[abspath + "*RT07*/orbit"].sort()
					last07 = b07[b07.size() - 1].split("orbit")[0]
					system("cp " + last07 + "/MLE000*.ctsall.jpg /tmp/app/lastait7.jpg")
					system("cp " + last07 + "/orbit /tmp/app/lastait7.orb")
					
					b01=Dir[abspath + "*RT01*/orbit"].sort()
					last01 = b01[b01.size() - 1].split("orbit")[0]
					system("cp " + last01 + "/MLE000*.ctsall.jpg /tmp/app/lastait1.jpg")
					system("cp " + last01 + "/orbit /tmp/app/lastait1.orb")
					
                rescue
                	puts "error in file system"
                end
                
                begin
                	genaitoffspot6("RT01")
                	genaitoffspot6("RT02")
                	genaitoffspot6("RT04")
                	genaitoffspot6("RT07")
                rescue
                	puts "error in file system "
                end
                
                #copy images to agile.iasfbo.inaf.it
                system("scp /tmp/app/* marlin:/var/www/html/AGILEApp/RT/")
                
        #end
end