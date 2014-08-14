

class MultiOutput
	def readDataSingleSource2(res, sourcename)
		puts res.to_s + "_" + sourcename
		readDataSingleSource(res.to_s + "_" + sourcename);
	end
	
	#nameout = nome del file che contiene i dati	
	def readDataSingleSource(nameout)
			@l = -1;
			@b = -1;
			@r = -1;
			@ell_a = -1;
			@ell_b = -1;
			@ell_phi = -1;
			
			@sicalc = 0
			@sicalc_error = 0

			#read upper limit
			index2 = 0;
			@r = -1;
			@galcoeff = "-1"
			@galcoeff_err = "-1"
			@galcoeffzero = "-1"
			@galcoeffzero_err = "-1"	
			@isocoeff = "-1"
			@isocoeff_err = "-1"
			@isocoeffzero = "-1"
			@isocoeffzero_err = "-1"	
			File.open(nameout).each_line do | line |
				index2 = index2 + 1;
				lll = line.split(" ")
				if index2.to_i == 12
					@label =lll[0];
					@fix =lll[1];
					@si_start = lll[2];
					@ulconflevel = lll[3];
					@srcconflevel = lll[4];
				end
				if index2.to_i == 13
					@sqrtTS =lll[0];
				end
				if index2.to_i == 14
					@l_peak = lll[0];
					@b_peak = lll[1];
				end
				if index2.to_i == 15
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
				if index2.to_i == 16
					@counts = lll[0]
					@counts_error = lll[1]
					@counts_error_p = lll[2]
					@counts_error_m = lll[3]
					@counts_ul = lll[4];
				end
				if index2.to_i == 17
					@flux = lll[0]
					@flux_error = lll[1]
					@flux_error_p = lll[2]
					@flux_error_m = lll[3]
					@flux_ul = lll[4];
					@exposure = lll[5]
				end
				if index2.to_i == 18
					@sicalc = lll[0]
					@sicalc_error = lll[1]
				end
				
				if index2.to_i == 19
					@galcoeff = lll[0]
					@galcoeff_err = lll[1]
				end
				
				if index2.to_i == 20
					@galcoeffzero = lll[0]
					@galcoeffzero_err = lll[1]
				end
				
				if index2.to_i == 21
					@isocoeff = lll[0]
					@isocoeff_err = lll[1]
				end
				
				if index2.to_i == 22
					@isocoeffzero = lll[0]
					@isocoeffzero_err = lll[1]
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
		@multiOutputLineFull2 = @label.to_s  + " " + @sqrtTS.to_s + " " + @l_peak.to_s + " " + @b_peak.to_s + " " + @counts.to_s + " " + @counts_error.to_s + " " + @counts_ul.to_s + " " + @flux.to_s + " " + @flux_error.to_s + " " + @flux_ul.to_s + " " + @sicalc.to_s + " " + @sicalc_error.to_s + " " + @l.to_s + " " + @b.to_s + " " + @r.to_s + " " + @ell_a.to_s +  " " + @ell_b.to_s + " " + @ell_phi.to_s + " " + @galcoeff + " " + @galcoeff_err + " " + @isocoeff + " " + @isocoeff_err + " " + @galcoeffzero + " " + @galcoeffzero_err + " " + @isocoeffzero + " " + @isocoeffzero_err
		
	end
	
	def multiOutputLineFull3(flag)
		@multiOutputLineFull3 = flag + " " + @label.to_s  + " " + @fix.to_s + " " + @si_start.to_s + " " + @ulconflevel.to_s + " " + @srcconflevel.to_s + " " + @sqrtTS.to_s + " " + @l_peak.to_s + " " + @b_peak.to_s + " " + @l.to_s + " " + @b.to_s + " " + @r.to_s + " " + @ell_a.to_s +  " " + @ell_b.to_s + " " + @ell_phi.to_s + " " + @counts.to_s + " " + @counts_error.to_s + " " + @counts_error_p.to_s + " " + @counts_error_m.to_s + " " + @counts_ul.to_s + " " + @flux.to_s + " " + @flux_error.to_s + " " + @flux_error_p.to_s + " " + @flux_error_m.to_s + " " + @flux_ul.to_s + " " + @exposure.to_s + " " + @sicalc.to_s + " " + @sicalc_error.to_s + " "  + @galcoeff + " " + @galcoeff_err + " " + @galcoeffzero + " " + @galcoeffzero_err + " "  + @isocoeff + " " + @isocoeff_err + " "  + @isocoeffzero + " " + @isocoeffzero_err
		
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
	
	def galcoeffzero
		@galcoeffzero
	end
	
	def isocoeffzero
		@isocoeffzero
	end
	
	def galcoeffzero_err
		@galcoeffzero_err
	end
	
	def isocoeffzero_err
		@isocoeffzero_err
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
	def counts_error_p
		@counts_error_p
	end
	def counts_error_m
		@counts_error_m
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
	def flux_error_p
		@flux_error_p
	end
	def flux_error_m
		@flux_error_m
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
	def readSources(resname, multilist, flag)
		f = File.new(resname + ".res", "w")
		File.open(multilist).each_line do | line |
			multioutput = MultiOutput.new()
			name = line.split(" ")[6];
			multioutput.readDataSingleSource2(resname, name)
			f.write(multioutput.multiOutputLineFull3(flag) + "\n");
		end
		f.close();
	end
	
	def sources
		@sources
	end
	
	
end