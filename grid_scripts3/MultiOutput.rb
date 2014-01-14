

class MultiOutput
	#nameout = nome del file che contiene i dati	
	def readDataSingleSourceWithoutGalIso(nameout)
			@l = -1;
			@b = -1;
			@r = -1;
			@ell_a = -1;
			@ell_b = -1;
			@ell_phi = -1;
					
			
			@sicalc = 0
			@sicalc_error = 0
			#calcola la dimensione del file
			dimf = 0
			File.open(nameout).each_line do | line |
				dimf = dimf + 1
			end
			#read upper limit
			index2 = 0;
			if dimf.to_i == 10
				File.open(nameout).each_line do | line |
					index2 = index2 + 1;
					lll = line.split(" ")
					if index2.to_i == 6						
						@label =lll[0];
						@fix =lll[1];
						@si_start = lll[2];
						@ulconflevel = lll[3];
						@srcconflevel = lll[4];
					end
					if index2.to_i == 7
						@sqrtTS =lll[0];
					end
					if index2.to_i == 8
						@l_peak = lll[0];
						@b_peak = lll[1];
					end
					if index2.to_i == 9
						@counts = lll[0]
						@counts_error = lll[1]
						@counts_ul = lll[4];
					end
					if index2.to_i == 10						
						@flux = lll[0]
						@flux_error = lll[1]
						@flux_ul = lll[4];
					end
				end
			end
			if dimf.to_i == 12
				@r = -1;
				File.open(nameout).each_line do | line |
					index2 = index2 + 1;
					lll = line.split(" ")
					if index2.to_i == 7
						@label =lll[0];
						@fix =lll[1];
						@si_start = lll[2];
						@ulconflevel = lll[3];
						@srcconflevel = lll[4];
					end
					if index2.to_i == 8
						@sqrtTS =lll[0];
					end
					if index2.to_i == 9
						@l_peak = lll[0];
						@b_peak = lll[1];
					end
					if index2.to_i == 10
						@l = lll[0]
						@b = lll[1]
						@r = lll[2];
						@ell_a = lll[3];
						@ell_b = lll[4];
						@ell_phi = lll[5];
					end
					if index2.to_i == 11
						@counts = lll[0]
						@counts_error = lll[1]
						@counts_ul = lll[4];
					end
					if index2.to_i == 12
						@flux = lll[0]
						@flux_error = lll[1]
						@flux_ul = lll[4];
					end
				end
			end 
			stepf = 0
			if dimf.to_i == 14
				stepf = 0 #versione multi4 BUILD20
			else 
				stepf = 4 #versione multi4 BUILD21 con iso e gals
			end
			if dimf.to_i >= 14 #multi4 #22
				@r = -1;
				File.open(nameout).each_line do | line |
					index2 = index2 + 1;
					lll = line.split(" ")
					if index2.to_i == (8 + stepf.to_i)
						@label =lll[0];
						@fix =lll[1];
						@si_start = lll[2];
						@ulconflevel = lll[3];
						@srcconflevel = lll[4];
					end
					if index2.to_i == (9 + stepf.to_i)
						@sqrtTS =lll[0];
					end
					if index2.to_i == (10 + stepf.to_i)
						@l_peak = lll[0];
						@b_peak = lll[1];
					end
					if index2.to_i == (11 + stepf.to_i)
						@fullellipseline = line;
						if lll.size.to_i != 3
							@l = lll[0]
							@b = lll[1]
							@r = lll[2];
							@ell_a = lll[3];
							@ell_b = lll[4];
							@ell_phi = lll[5];
						else
							@l = -1
							@b = -1
							@r = -1
							@ell_a = -1
							@ell_b = -1
							@ell_phi = -1
						end
					end
					if index2.to_i == (12 + stepf.to_i)
						@counts = lll[0]
						@counts_error = lll[1]
						@counts_ul = lll[4];
					end
					if index2.to_i == (13 + stepf.to_i)
						@flux = lll[0]
						@flux_error = lll[1]
						@flux_ul = lll[4];
						@exposure = lll[5]
					end
					if index2.to_i == (14 + stepf.to_i)
						@sicalc = lll[0]
						@sicalc_error = lll[1]
					end
				end
			end
	end
	
	def readGalIsoAndSources(resname)
		index = 0;
		indexsources = 0;
		@galcoeff = ""
		@isocoeff = ""
		@modefile = 3
		@sources = Array.new()
		#lettura del file resname
		if File.exists?(resname) then
			File.open(resname).each_line do | line |
				if line.split("!").size() >= 2
					next
				end
				if line.split("'").size() >= 2
					next
				end
				fs = line.split("Galactic")
				if fs.size == 2
					@modefile = 4
					next
				end
				fs = line.split("Isotropic")
				if fs.size == 2
					@modefile = 4
					next
				end
				fs = line.split(" ")
				if fs.size == 4
					next
				end
				index = index + 1
			end
			index = 0;
			File.open(resname).each_line do | line |
				if line.split("!").size() >= 2
					next
				end
				if line.split("'").size() >= 2
					next
				end
				fs = line.split(" ")
				if fs.size == 4
					#next AB modificato il 2011-01-31 per poter leggere i files multi2
				end
				if @modefile.to_i == 3
					if index.to_i == 0
						@galcoeff = line.split(" ")[0]
						@galcoeff_err = line.split(" ")[1]
					end
					if index.to_i == 1
						@isocoeff = line.split(" ")[0]
						@isocoeff_err = line.split(" ")[1]
					end
				end
				if @modefile.to_i == 4
					fs = line.split("Galactic")
					fssize = fs.size 
					if fssize.to_i == 2
						if @galcoeff != ""
							@galcoeff = @galcoeff.to_s + ","
							@galcoeff_err = @galcoeff_err.to_s + ","
						end
						fs1 = line.split("_")
						fs1size = fs1.size 
						@galcoeff = @galcoeff.to_s + fs[1].split(" ")[fs1size.to_i - 1].to_s 
						@galcoeff_err = @galcoeff_err.to_s + fs[1].split(" ")[fs1size.to_i - 0].to_s
					else
						fs = line.split("Isotropic")
						fssize = fs.size
						if fssize.to_i == 2
							if @isocoeff != ""
								@isocoeff = @isocoeff.to_s + ","
								@isocoeff_err = @isocoeff_err.to_s + ","
							end
							fs1 = line.split("_")
							fs1size = fs1.size
							@isocoeff = @isocoeff.to_s + fs[1].split(" ")[fs1size.to_i - 1].to_s
							@isocoeff_err = @isocoeff_err.to_s + fs[1].split(" ")[fs1size.to_i - 0].to_s
						else
							#is a source
							@sources[indexsources] = line;
							indexsources = indexsources + 1
						end
					end
				end
				index = index +1
			end
		end

	end
	
	def readGalIso(resname)
		index = 0;
		@galcoeff = ""
		@isocoeff = ""
		@modefile = 3
		#lettura del file resname
		if File.exists?(resname) then
			File.open(resname).each_line do | line |
				if line.split("!").size() >= 2
					next
				end
				if line.split("'").size() >= 2
					next
				end
				fs = line.split("Galactic")
				if fs.size == 2
					@modefile = 4
					next
				end
				fs = line.split("Isotropic")
				if fs.size == 2
					@modefile = 4
					next
				end
				fs = line.split(" ")
				if fs.size == 4
					next
				end
				index = index + 1
			end
			index = 0;
			File.open(resname).each_line do | line |
				if line.split("!").size() >= 2
					next
				end
				if line.split("'").size() >= 2
					next
				end
				fs = line.split(" ")
				if fs.size == 4
					#next AB modificato il 2011-01-31 per poter leggere i files multi2
				end
				if @modefile.to_i == 3 #vecchio formato
					#! Gascoeff: Coeff, Err, +Err, -Err
					#2.4662 16.0632 6.83989 0 
					#! Isocoeff: Coeff, Err, +Err, -Err
					#7.54629 21.9242 5.22582 0  
					if index.to_i == 0
						@galcoeff = line.split(" ")[0]
						@galcoeff_err = line.split(" ")[1]
					end
					if index.to_i == 1
						@isocoeff = line.split(" ")[0]
						@isocoeff_err = line.split(" ")[1]
					end
				end
				if @modefile.to_i == 4
					#! DiffName, Coeff, Err, +Err, -Err
					#Galactic_1 0.205462 0.163366 0.164556 -0.162113
					#Galactic_2 1.09183 0.163716 0.164633 -0.162844
					#Galactic_3 1.11198 0.170554 0.172145 -0.169012
					#Isotropic_1 10.1176 1.42604 1.4456 -1.40617
					#Isotropic_2 6.84772 1.76934 1.80347 -1.73526
					#Isotropic_3 7.55861 2.19528 2.24018 -2.15047
					fs = line.split("Galactic")
					fssize = fs.size 
					if fssize.to_i == 2
						if @galcoeff != ""
							@galcoeff = @galcoeff.to_s + ","
							@galcoeff_err = @galcoeff_err.to_s + ","
						end
						fs1 = line.split("_")
						fs1size = fs1.size 
						@galcoeff = @galcoeff.to_s + fs[1].split(" ")[fs1size.to_i - 1].to_s
						@galcoeff_err = @galcoeff_err.to_s + fs[1].split(" ")[fs1size.to_i - 0].to_s
					else
						fs = line.split("Isotropic")
						fssize = fs.size
						if fssize.to_i == 2
							if @isocoeff != ""
								@isocoeff = @isocoeff.to_s + ","
								@isocoeff_err = @isocoeff_err.to_s + ","
							end
							fs1 = line.split("_")
							fs1size = fs1.size
							@isocoeff = @isocoeff.to_s + fs[1].split(" ")[fs1size.to_i - 1].to_s
							@isocoeff_err = @isocoeff_err.to_s + fs[1].split(" ")[fs1size.to_i - 0].to_s
						else
							#is a source
							
						end
					end
				end
				index = index +1
			end
		end

	end


	#usa il file di dettaglio con _
	def readDataSingleSource(resname, sourcename)

		#lettura del file resname
		readGalIsoAndSources(resname)
		#puts @galcoeff
		#puts @isocoeff
		
		#lettura del file della singola sorgente
		if sourcename != nil 
			nameout = resname.to_s + "_" + sourcename.to_s;
			readDataSingleSourceWithoutGalIso(nameout);
		end
	end
	
	#usa il file di dettaglio con _
	def readSingleSource(resname, sourcename)
	
		#lettura del file della singola sorgente
		if sourcename != nil 
			nameout = resname.to_s + "_" + sourcename.to_s;
			readDataSingleSourceWithoutGalIso(nameout);
		end
	end
	
	#usa solo il file .res
	def readSingleSourceRes(resname, sourcename)
		readGalIsoAndSources(resname)
		@sources.each do | s |
				s1 = s.split(" ")
				if s1[0] == sourcename
					@label = s1[0]
					@sqrtTS = s1[1]
					@l = s1[2]
					@b = s1[3]
					@l_peak = s1[2]
					@b_peak = s1[3]
					@counts = s1[4]
					@counts_error = s1[5]
					@flux = s1[6]
					@flux_error = s1[7]
					@sicalc = s1[8]
					@sicalc_error = s1[9]
				end
		end
	end

	def multiOutputLine()
		@multiOutputLine = @label.to_s  + " " + @sqrtTS.to_s + " " + @l_peak.to_s + " " + @b_peak.to_s + " " + @counts.to_s + " " + @counts_error.to_s + " " + @flux.to_s + " " + @flux_error.to_s + " " + @sicalc.to_s + " " + @sicalc_error.to_s
	end
	
	def multiOutputLineFull()
		@multiOutputLineFull = @label.to_s  + " " + @sqrtTS.to_s + " " + @l_peak.to_s + " " + @b_peak.to_s + " " + @counts.to_s + " " + @counts_error.to_s + " " + @flux.to_s + " " + @flux_error.to_s + " " + @sicalc.to_s + " " + @sicalc_error.to_s + " " + @l.to_s + " " + @b.to_s + " " + @r.to_s + " " + @ell_a.to_s +  " " + @ell_b.to_s + " " + @ell_phi.to_s
	end
	
	def multiOutputLineFull2()
		@multiOutputLineFull = @label.to_s  + " " + @sqrtTS.to_s + " " + @l_peak.to_s + " " + @b_peak.to_s + " " + @counts.to_s + " " + @counts_error.to_s + " " + @counts_ul.to_s + " " + @flux.to_s + " " + @flux_error.to_s + " " + @flux_ul.to_s + " " + @sicalc.to_s + " " + @sicalc_error.to_s + " " + @l.to_s + " " + @b.to_s + " " + @r.to_s + " " + @ell_a.to_s +  " " + @ell_b.to_s + " " + @ell_phi.to_s + " " + @galcoeff + " " + @galcoeff_err + " " + @isocoeff + " " + @isocoeff_err
		
	end
	
	def galcoeff
		@galcoeff
	end
	
	def isocoeff
		@isocoeff
	end
	
	def galcoeff_err
		@galcoeff_err
	end
	
	def isocoeff_err
		@isocoeff_err
	end
	
	def modefile
		@modefile
	end

	def label
		@label
	end
	
	def sources
		@sources
	end

	
	def sicalc
		@sicalc
	end
	
	def sicalc_error
		@sicalc_error
	end

	def fix
		@fix
	end

	def si_start
		@si_start
	end
	def ulconflevel
		@ulconflevel
	end
	def srcconflevel
		@srcconflevel
	end
	def sqrtTS
		@sqrtTS
	end
	def l_peak
		@l_peak
	end
	def b_peak
		@b_peak
	end
	def l
		@l
	end
	def b
		@b
	end
	def r
		@r
	end
	def ell_a
		@ell_a
	end
	def ell_b
		@ell_b
	end
	def ell_phi
		@ell_phi
	end
	def counts
		@counts
	end
	def counts_error
		@counts_error
	end
	def counts_ul
		@counts_ul
	end
	def flux
		@flux
	end
	def flux_error
		@flux_error
	end
	def flux_ul
		@flux_ul
	end
	def exposure
		@exposure
	end
	def fullellipseline
		@fullellipseline
	end
end


class MultiOutputList
	def readSources(resname)
		@sources = Array.new()
		multioutput = MultiOutput.new()
		multioutput.readGalIsoAndSources(resname);
		for i in 0...multioutput.sources.size()
			m = MultiOutput.new()
			sname = multioutput.sources[i].split(" ")[0]
			m.readSingleSource(resname, sname)
			@sources[i] = m
			#puts sources[i].multiOutputLineFull()
		end
	end
	
	def sources
		@sources
	end
	
	
end