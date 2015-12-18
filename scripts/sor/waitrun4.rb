#! /usr/bin/ruby
#0) command to execute periodically
#1) time of sleep in seconds


begin
        b=1
        while b == 1
        		a = Dir["/ANALYSIS3/commands/*.conf"]
        		if a.size() > 0 
        			a.each do | line |
        				puts line
                		cmd = "mv " + line + " /tmp/ ";
               	 		puts cmd
                		system(cmd);
                		file = line.split("/")[line.split("/").size-1]
               			cmd = "cd /tmp; clusteranalysis4.rb " + file
               			puts cmd;
               			system(cmd)
               		end
               	end
                sleep (10);
        end
end
