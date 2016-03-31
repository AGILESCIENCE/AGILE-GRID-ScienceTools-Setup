#! /usr/bin/ruby
#0) command to execute periodically
#1) time of sleep in seconds

load ENV["AGILE"] + "/scripts/sor/sorpaths.rb"

begin
        #b=1
        #while b == 1
        		a = Dir[PATH_RES + "/commands/*.conf"]
        		if a.size() > 0 
        			a.sort.each do | line |
        				puts line
                		cmd = "mv " + line + " /tmp/ ";
               	 		puts cmd
                		system(cmd);
                		file = line.split("/")[line.split("/").size-1]
               			cmd = "cd /tmp; clusteranalysis5.rb " + file
               			puts cmd;
               			system(cmd)
               			sleep(1)
               			system("rm /tmp/" + line);
               		end
               	end
        #        sleep (10);
        #end
end
