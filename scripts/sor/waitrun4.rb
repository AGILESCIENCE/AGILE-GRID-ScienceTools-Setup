#! /usr/bin/ruby
#0) command to execute periodically
#1) time of sleep in seconds


begin
        b=1
        while b == 1
        		a = Dir["/AGILE_PROC3/ANALYSIS3/commands/*.conf"]
        		if a.size() > 0 
        			a.each do | line |
        			puts line
                		cmd = "mv " + line + " ~/sor/ ";
               	 		puts cmd
                		system(cmd);
                		file = line.split("/")[line.split("/").size-1]
               			cmd = "cd ~/sor; clusteranalysis4.rb " + file
               			puts cmd;
               			system(cmd)
               		end
               	end
                sleep (10);
        end
end
