

class Conf
	def initialize
			
	end
	
	def process(filenameconf, fnhyp0, fndisplayreg)
		@fndisplayreg = fndisplayreg
		@typeanalysis = ""
		@filter = ""
		@tstart = ""
		@tstop = ""
		@timetype = ""
		@l = ""
		@b = ""
		@proj = ""
		@galcoeff = ""
		@isocoeff = ""
		@mapparam = ""
		@hypothesisgen1 = ""
		@hypothesisgen2 = ""
		@radmerger = ""
		@multiparam = ""
		@tsmapparam = ""
		@iddisp = ""
		@dir_run_output = ""
		@mail = ""
		@analysisname = ""
		@ds91 = "" #default, none, 1 -1 3 B 2
		@ds92 = "" #default, none, 1 -1 3 B 2
		@ds93 = "" #default, none, 1 -1 3 B 2
		@ds94 = "" #default, none, 1 -1 3 B 2
		@regfile = ""
		@detGIF = ""
		@comments = ""
		@reg = "" #yes/no or nop/con/reg
		@binsize = 0.3

		@queue = nil
		@result_dir = nil
		@result_dir_minSqrtTS = 0
		@result_dir_sourcename = "all"
		
		if fnhyp0 != nil
			f = File.new(fnhyp0 , "w")
		else
			f = nil
		end
		
		fr = nil;

		extractmulti = true
		index = 0
		File.open(filenameconf).each_line do | line |
			line = line.chomp
			if index.to_i == 0
				typeanalysis_and_result_dir = line
				@typeanalysis = typeanalysis_and_result_dir.split(",")[0]
				if typeanalysis_and_result_dir.split(",").size >= 2
					@result_dir = typeanalysis_and_result_dir.split(",")[1]
				end
				if typeanalysis_and_result_dir.split(",").size >= 3
					@result_dir_minSqrtTS = typeanalysis_and_result_dir.split(",")[2]
				end
				if typeanalysis_and_result_dir.split(",").size >= 4
					@result_dir_sourcename = typeanalysis_and_result_dir.split(",")[3]
				end
			end

			if index.to_i == 1
				@filter = line
			end
			if index.to_i == 2
				@tstart = line
			end
			if index.to_i == 3
				@tstop = line
			end
			if index.to_i == 4
				@timetype = line
			end
			if index.to_i == 5
				@l = line
			end
			if index.to_i == 6
				@b = line
			end
			if index.to_i == 7
				@proj = line
			end
			if index.to_i == 8
				@galcoeff = line
			end
			if index.to_i == 9
				@isocoeff = line
			end
			if index.to_i == 10
				@mapparam = line
				if @mapparam.split("binsize").size() > 1
					@binsize  = mapparam.split("binsize")[1].split("=")[1].split(" ")[0]
				else
					@binsize = 0.3
				end
			end
			if index.to_i == 11
				@hypothesisgen1 = line
			end
			if index.to_i == 12
				@hypothesisgen2 = line
			end
			if index.to_i == 13
				@radmerger = line
			end
			if index.to_i == 14
				@multiparam = line
			end
			if index.to_i == 15
				@tsmapparam = line
			end
			if index.to_i == 16
				@ds91 = line
			end
			if index.to_i == 17
				@ds92 = line
			end
			if index.to_i == 18
				@ds93 = line
			end
			if index.to_i == 19
				@ds94 = line
			end
			if index.to_i == 20
				@regfile = line
				if @regfile == "none"
					@regfile = ""
				else
					@regfile = PATH_RES + "/regs/" + @regfile
				end
			end
			if index.to_i == 21
				@detGIF = line
			end
			if index.to_i == 22
				@iddisp = line
			end
			if index.to_i == 23
				user_and_queue = line
				@dir_run_output = user_and_queue.split(",")[0]
				if user_and_queue.split(",").size == 2
					@queue = user_and_queue.split(",")[1]
				end
			end
			if index.to_i == 24
				@mail = line
			end
			if index.to_i == 25
				@analysisname =  line
				if @proj.to_s == "AIT"
					@analysisname = "AIT_" + @analysisname.to_s;
				end
				if @proj.to_s == "ARC"
					@analysisname = "ARC_" + @analysisname.to_s
				end
			end
			if index.to_i == 26
				@comments =  line
			end
			if index.to_i == 27
				@reg =  line
				if @reg == "yes" or @reg == "reg"
					if @fndisplayreg != nil
						@fndisplayreg += ".reg"
					end
				end
				if @reg == "con"
					if @fndisplayreg != nil
						@fndisplayreg += ".con"
					end
				end
				if @fndisplayreg != nil
					fr = File.new(@fndisplayreg , "w")
				else
					fr = nil
				end
			end
			if index.to_i >= 28
				if index.to_i > 28
					if line.to_s == "-----"
						extractmulti = false
						next
					end
			
					if extractmulti == true
						if line.size() > 2
							if f != nil
								f.write(line + "\n")
							end
						end
					else
						if line.size() > 2
							if fr != nil
								fr.write(line + "\n")
							end
						end
					end
				end
			end
			index = index.to_i + 1
		end

		if f != nil
			f.close()
		end
		if fr != nil
			fr.close()
		end

	end
	
	def existsFile(filename)
		if filename == nil
			return ""
		end
		if File.exists?(filename)
			return filename
		else
			return ""
		end
	end
	
	def plotjpgcts1(mle, smooth)
		if File.exists?(mle + ".multi.reg") 
			Dir["*.cts.gz"].each do | file |
				if @ds91 != "none"
					fname = file.split(".cts.gz")[0]
					if @ds91 == "default"
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".ctsall 1 -1 " + smooth.to_s + " B all png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					else
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".ctsall " + @ds91.to_s +  " png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					end
					if @reg == "yes" or @reg == "reg" or @reg == "con"
						cmd += " "
						cmd += existsFile(@fndisplayreg)
					end
					puts cmd
					system(cmd)
				end
			end
		end
	end

	def plotjpgint(mle, smooth)
		if File.exists?(mle + ".multi.reg") 
			Dir["*.int.gz"].each do | file |
				if @ds92 != "none"
					fname = file.split(".int.gz")[0]
					if @ds92 == "default"
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".intall 1 -1 " + smooth.to_s + " B all png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					else
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".intall " + @ds92.to_s +  " png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					end
					if @reg == "yes" or @reg == "reg" or @reg == "con"
						cmd += " "
						cmd += existsFile(@fndisplayreg)
					end
					puts cmd
					system(cmd)
				end
			end
		end
	end

	def plotjpgexp(mle)
		if File.exists?(mle + ".multi.reg") 
			Dir["*.exp.gz"].each do | file |
				if @ds93 != "none"
					fname = file.split(".exp.gz")[0]
					if @ds93 == "default"
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".expall 1 -1 1 B all png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					else
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".expall " + @ds93.to_s +  " png 1400x1400 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
					end
					if @reg == "yes" or @reg == "reg" or @reg == "con"
						cmd += " "
						cmd += existsFile(@fndisplayreg)
					end
					puts cmd
					system(cmd)
				end
			end
		end
	end

	def plotjpgcts2(mle, smooth)
		if File.exists?(mle + ".multi.reg") 
			Dir["*.cts.gz"].each do | file |
				if @ds94 != "none"
					fname = file.split(".cts.gz")[0]
					if @ds94 == "default"
						#cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".cts2   2 -1 " + smooth.to_s + " B 16 jpg 1800x1800 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(regfile)
						#if reg == "yes" or reg == "reg" or reg == "con"
						#	cmd += " "
						#	cmd += existsFile(@fndisplayreg)
						#end
						#puts cmd
						#system(cmd)
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".cts2   2 -1 " + smooth.to_s + " B 16 png 1800x1800 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
						if @reg == "yes" or @reg == "reg" or @reg == "con"
							cmd += " "
							cmd += existsFile(@fndisplayreg)
						end
						puts cmd
						system(cmd)
					else
						cmd = "export DISPLAY=localhost:3.0; " + ENV["AGILE"] + "/scripts/sor/ds9.rb " + file + " " + mle  + "_" + fname + ".cts2   " + @ds94.to_s +  " png 1800x1800 " + existsFile(mle + ".reg") + " " +  existsFile(mle + ".multi.reg") + " " + existsFile(@regfile)
						if @reg == "yes" or @reg == "reg" or @reg == "con"
							cmd += " "
							cmd += existsFile(@fndisplayreg)
						end
						puts cmd
						system(cmd)
					end
			
				end
			end
		end
	end
	
	def detsmooth
		@smooth = 3	
		if @binsize.to_f == 0.05
			@smooth = 20;
		end
		if @binsize.to_f == 0.1
			@smooth = 10;
		end
		if @binsize.to_f == 0.2
			@smooth = 5;
		end
		if @binsize.to_f == 0.25
			@smooth = 4;
		end
		if @binsize.to_f == 0.3
			@smooth = 3;
		end
		if @binsize.to_f == 0.5
			@smooth = 3;
		end
	
	end
	
	def copyresults(mle)
		sourceexpr = ""
		if @result_dir != nil
		begin
			#copia i risultati in result_dir
			pathres = PATH_RES + "/" + @result_dir + "/"
			system("mkdir -p " + pathres);
			cmd = "cp " + mle + ".conf " + pathres + "/" + @analysisname + "_" + mle + ".conf"
			puts cmd
			system cmd
			cmd = "cp " + mle + ".ll " + pathres + "/" + @analysisname + "_" + mle + ".ll"
			puts cmd
			system cmd
			#copy the results of .source
			
			if @result_dir_sourcename == "all"
				sourceexpr = mle + "_*.source"
			else
				sourceexpr = mle + "_" + @result_dir_sourcename + ".source"
			end
					
			Dir[sourceexpr].each do | file |
					mo = MultiOutput.new
					mo.readDataSingleSource(file)
					if mo.sqrtTS.to_f >= @result_dir_minSqrtTS
						puts file
						system("cp " + file.to_s + " " + pathres + "/" + @analysisname + "_" + file);
					end	
			end
			Dir[mle + "*.cts2.png"].each do | file |
				system("cp " + file.to_s + " " + pathres + "/" + @analysisname + "_" + file);
			end
			Dir[mle + "*.ctsall.png"].each do | file |
				system("cp " + file.to_s + " " + pathres + "/" + @analysisname + "_" + file);
			end
			
		rescue
			puts "error result_dir copy results"
		end		
	end
	end

		
	def typeanalysis
		@typeanalysis
	end
	
	def filter
		@filter
	end
	
	def smooth
		@smooth
	end
	
	def tstart
		@tstart
	end
	
	def tstop
		@tstop
	end
	
	def timetype
		@timetype
	end
	
	def l
		@l
	end
	
	def b
		@b
	end
	
	def proj
		@proj
	end
	
	def galcoeff
		@galcoeff
	end
	
	def isocoeff
		@isocoeff
	end
	
	def mapparam
		@mapparam
	end
	
	def hypothesisgen1
		@hypothesisgen1
	end
	
	def hypothesisgen2
		@hypothesisgen2
	end
	
	def radmerger
		@radmerger
	end
	
	def multiparam
		@multiparam
	end
	
	def tsmapparam
		@tsmapparam
	end
	
	def iddisp
		@iddisp
	end
	
	def dir_run_output
		@dir_run_output
	end
	
	def mail
		@mail
	end
	
	def analysisname
		@analysisname
	end
	
	def ds91
		@ds91
	end
	
	def ds92
		@ds92
	end
	
	def ds93
		@ds93
	end
	
	def ds94
		@ds94
	end
	
	def regfile
		@regfile
	end
	
	def detGIF
		@detGIF
	end
	
	def comments
		@comments
	end	
		
	def reg
		@reg
	end
	
	def binsize
		@binsize
	end
	
	def queue
		@queue
	end
	
	def result_dir
		@result_dir
	end
	
	def result_dir_minSqrtTS
		@result_dir_minSqrtTS
	end
	
	def result_dir_sourcename
		@result_dir_sourcename
	end
end
