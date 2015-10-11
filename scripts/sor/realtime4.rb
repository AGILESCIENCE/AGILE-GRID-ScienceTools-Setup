#! /usr/bin/ruby

def runait(lastcontacttime, day, hours_shift)

        		tstart = 0
        		tstop = 0
        		abspath="/AGILE_PROC3/ANALYSIS3/"
        		lastprocessing2 = 0
        		if File.exists?("/AGILE_PROC3/ANALYSIS3/commands/lastprocessing_aitoff_rt"+format("%02i", day)+"")
        			File.open("/AGILE_PROC3/ANALYSIS3/commands/lastprocessing_aitoff_rt"+format("%02i", day)+"", "r").each_line do | line |
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
        		puts lastcontacttime.to_s + " - " + lastprocessing2.to_s + " - " + tstart.to_s + " " + tstop.to_s
        		
        		if tstop.to_i <= lastcontacttime.to_i
        			#change and copy the card
        			fo = File.new("/home/bulgarelli/sor/aitoff_rt"+format("%02i", day)+".conf", "w")
        			index = 0
        			File.open("/home/bulgarelli/sor/cards/ait_rt/aitoff_rt"+format("%02i", day)+".conf").each_line do | line |
        				out = line
        				if index.to_i == 2
        					out = tstart.to_i.to_s + "\n"
        				end
        				if index.to_i == 3
        					out = tstop.to_i.to_s + "\n"
        				end
        				if index.to_i == 23
        					abspath += line.chomp
        					abspath += "/AIT_"
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
        			f = File.new("/AGILE_PROC3/ANALYSIS3/commands/lastprocessing_aitoff_rt"+format("%02i", day), "w")
        			f.write(lastprocessing2);
        			f.close();
        			system("cp /home/bulgarelli/sor/aitoff_rt"+format("%02i", day)+".conf  commands/");
        		end
end


begin
        b=1
        
        while b == 1
        		
        		cmd = "sort --key=3 /AGILE_PROC3/FM3.119_2/INDEX/EVT.index | tail -1 > /AGILE_PROC3/ANALYSIS3/commands/lastorbit "
        		puts cmd
        		system(cmd)
        		lastcontacttime = 0
        		
        		cmd = "cp /AGILE_PROC3/FM3.119_2/INDEX/EVT.index /AGILE_PROC3/ANALYSIS3/commands/"
        		system(cmd)
        		
        		
        		File.open("/AGILE_PROC3/ANALYSIS3/commands/lastorbit", "r").each_line do | line |
        			lastcontacttime = line.split(" ")[2].to_i
        		end
        		puts "lastcontacttime " + lastcontacttime.to_s
        		
        		#run02
        		runait(lastcontacttime, 2, 2);
        		
        		#run04
        		runait(lastcontacttime, 4, 8);
        		
        		#run07
        		runait(lastcontacttime, 7, 12);
        		
                sleep (100);
                
                begin
					abspath="/AGILE_PROC3/ANALYSIS3/aitoff_rt/"
					b02=Dir[abspath + "*RT02*/orbit"].sort()
					last02 = b02[b02.size() - 1].split("orbit")[0]
					system("cp " + last02 + "/MLE0000.ctsall.jpg /home/bulgarelli/sor/app/lastait2.jpg")
					system("cp " + last02 + "/orbit /home/bulgarelli/sor/app/lastait2.orb")
					system("cp " + last02 + "/MLE0000.ctsall.jpg /home/bulgarelli/sor/app/public.jpg")
					system("cp " + last02 + "/orbit /home/bulgarelli/sor/app/public.orb")
				
					b04=Dir[abspath + "*RT04*/orbit"].sort()
					last04 = b04[b04.size() - 1].split("orbit")[0]
					system("cp " + last04 + "/MLE0000.ctsall.jpg /home/bulgarelli/sor/app/lastait4.jpg")
					system("cp " + last04 + "/orbit /home/bulgarelli/sor/app/lastait4.orb")
				
					b07=Dir[abspath + "*RT07*/orbit"].sort()
					last07 = b07[b07.size() - 1].split("orbit")[0]
					system("cp " + last07 + "/MLE0000.ctsall.jpg /home/bulgarelli/sor/app/lastait7.jpg")
					system("cp " + last07 + "/orbit /home/bulgarelli/sor/app/lastait7.orb")
                rescue
                	puts "error in file system"
                end
                system("scp /home/bulgarelli/sor/app/* marlin:/var/www/html/AGILEApp/RT/")
                
        end
end