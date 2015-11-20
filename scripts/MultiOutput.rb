load ENV["AGILE"] + "/scripts/DataUtils.rb"

class MultiOutput
	def readDataSingleSource2(res, sourcename)
		puts res.to_s + "_" + sourcename
		readDataSingleSource(res.to_s + "_" + sourcename + ".src");
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
			@fitdata = "-1, -1, -1, -1, -1, -1, -1"
			File.open(nameout).each_line do | line |
				index2 = index2 + 1;
				lll = line.split(" ")
				if index2.to_i == 15
					@label =lll[0];
					@fix =lll[1];
					@si_start = lll[2];
					@ulconflevel = lll[3];
					@srcconflevel = lll[4];
					@startL = lll[5];
					@startB = lll[6];
					@startFlux = lll[7];
					@lmin = lll[9];
					@lmax = lll[11];
					@bmin = lll[14];
					@bmax = lll[16];
				end
				if index2.to_i == 16
					@sqrtTS =lll[0];
				end
				if index2.to_i == 17
					@l_peak = lll[0];
					@b_peak = lll[1];
					@dist = lll[2];
				end
				if index2.to_i == 18
					@l = lll[0]
					@b = lll[1]
					@distellipse = lll[2];
					@r = lll[3];
					@ell_a = lll[4];
					@ell_b = lll[5];
					@ell_phi = lll[6];
				end
				if index2.to_i == 19
					@counts = lll[0]
					@counts_error = lll[1]
					@counts_error_p = lll[2]
					@counts_error_m = lll[3]
					@counts_ul = lll[4];
				end
				if index2.to_i == 20
					@flux = lll[0]
					@flux_error = lll[1]
					@flux_error_p = lll[2]
					@flux_error_m = lll[3]
					@flux_ul = lll[4];
					@exposure = lll[5]
				end
				if index2.to_i == 21
					@sicalc = lll[0]
					@sicalc_error = lll[1]
				end
				
				if index2.to_i == 22
					@fit_cts = lll[0]
					@fit_fcn0 = lll[1]
					@fit_fcn1 = lll[2]
					@fit_edm0 = lll[3]
					@fit_edm1 = lll[4]
					@fit_iter0 = lll[5]
					@fit_iter1 = lll[6]
				end
				
				if index2.to_i == 23
					@galcoeff = lll[0]
					@galcoeff_err = lll[1]
				end
				
				if index2.to_i == 24
					@galcoeffzero = lll[0]
					@galcoeffzero_err = lll[1]
				end
				
				if index2.to_i == 25
					@isocoeff = lll[0]
					@isocoeff_err = lll[1]
				end
				
				if index2.to_i == 26
					@isocoeffzero = lll[0]
					@isocoeffzero_err = lll[1]
				end
				
				if index2.to_i == 27
					@tstart = lll[0]
					@tstop = lll[1]
				end
				
				if index2.to_i == 28
					@energyrange = lll[0]
					@fovrange = lll[1]
					@albedo = lll[2]
					@binsize  = lll[3] 
					@expstep  = lll[4]  
					@phasecode = lll[5]  
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
		@multiOutputLineFull2 = @label.to_s  + " " + @sqrtTS.to_s + " " + @l_peak.to_s + " " + @b_peak.to_s + " " + @dist.to_s + " " + @counts.to_s + " " + @counts_error.to_s + " " + @counts_ul.to_s + " " + @flux.to_s + " " + @flux_error.to_s + " " + @flux_ul.to_s + " " + @sicalc.to_s + " " + @sicalc_error.to_s + " " + @l.to_s + " " + @b.to_s + " " + @r.to_s + " " + @ell_a.to_s +  " " + @ell_b.to_s + " " + @ell_phi.to_s + " " + @galcoeff + " " + @galcoeff_err + " " + @isocoeff + " " + @isocoeff_err + " " + @galcoeffzero + " " + @galcoeffzero_err + " " + @isocoeffzero + " " + @isocoeffzero_err
		
	end
	
	def multiOutputLineFull3(flag)
		d = DataUtils.new
		mjdstart = d.time_utc_to_mjd(tstart);
		mjdstop = d.time_utc_to_mjd(tstop);
		ttstart = d.time_utc_to_tt(tstart);
		ttstop = d.time_utc_to_tt(tstop);
		@multiOutputLineFull3 = flag + " " + @label.to_s + " " + @sqrtTS.to_s + " POS " + @l_peak.to_s + " " + @b_peak.to_s + " " + @dist.to_s + " " + @l.to_s + " " + @b.to_s + " " + @distellipse.to_s + " " + @r.to_s + " " + @ell_a.to_s +  " " + @ell_b.to_s + " " + @ell_phi.to_s + " CTS " + @counts.to_s + " " + @counts_error.to_s + " " + @counts_error_p.to_s + " " + @counts_error_m.to_s + " " + @counts_ul.to_s + " FL " + @flux.to_s + " " + @flux_error.to_s + " " + @flux_error_p.to_s + " " + @flux_error_m.to_s + " " + @flux_ul.to_s + " EXP " + @exposure.to_s + " SI " + @sicalc.to_s + " " + @sicalc_error.to_s + " TI " + tstart.to_s + " " + tstop.to_s + " " + mjdstart.to_s + " " + mjdstop.to_s + " " + ttstart.to_s + " " + ttstop.to_s + " GI " + @galcoeff + " " + @galcoeff_err + " " + @galcoeffzero + " " + @galcoeffzero_err + " "  + @isocoeff + " " + @isocoeff_err + " "  + @isocoeffzero + " " + @isocoeffzero_err + " FIT " + @fit_cts + " "  + @fit_fcn0 + " " + @fit_fcn1 + " " + @fit_edm0 + " " + @fit_edm1 + " " + @fit_iter0 + " " + @fit_iter1  + " ANA " + @fix.to_s + " " + @si_start.to_s + " " + @ulconflevel.to_s + " " + @srcconflevel.to_s + " " + @startL.to_s + " " + @startB.to_s + " " + @startFlux.to_s + " [ " + @lmin.to_s + " , " + @lmax.to_s + " ] [ " + @bmin.to_s + " , " + @bmax.to_s + " ] " + " " + @energyrange + " " + @fovrange + " " + @albedo + " " + @binsize + " " + @expstep + " " + @phasecode;
		
	end
	
	def multiOutputLineFull4(flag, ring, dist)
		multiOutputLineFull3(flag)
		@multiOutputLineFull4 = @multiOutputLineFull3 + " RING " + ring.to_s + " " + dist.to_s;
	end
	
	def	phasecode
		@phasecode
	end
	
	def	expstep
		@expstep
	end
	
	def	binsize
		@binsize
	end
	
	def	albedo
		@albedo
	end
	
	def	fovrange
		@fovrange
	end
	
	def	energyrange
		@energyrange
	end
	
	def	lmax
		@lmax
	end
	
	def	lmin
		@lmin
	end
	
	def	bmax
		@bmax
	end
	
	def	bmin
		@bmin
	end
	
	def	tstart
		@tstart
	end
	
	def tstop
		@tstop
	end
	def	startL
		@startL
	end
	
	def startB
		@startB
	end
	
	def startFlux
		@startFlux
	end
	
	def dist
		@dist
	end
	
	def galcoeff
		@galcoeff
	end
	
	def distellipse
		@distellipse
	end
	
	def fit_cts
		@fit_cts
	end
	
	def fit_fcn0
		@fit_fcn0
	end

	def fit_fcn1
		@fit_fcn1
	end

	def fit_edm0
		@fit_edm0
	end

	def fit_edm1
		@fit_edm1
	end
	
	def fit_iter0
		@fit_iter0
	end

	def fit_iter1
		@fit_iter1
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
		if @sqrtTS == "-nan"
			@sqrtTS = 0;
		end
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
		f = File.new(resname + ".resfull", "w")
		f1 = File.new(resname + ".resfullsel", "w")
		File.open(multilist).each_line do | line |
			multioutput = MultiOutput.new()
			name = line.split(" ")[6];
			multioutput.readDataSingleSource2(resname, name)
			f.write(multioutput.multiOutputLineFull3(flag) + "\n");
			if multioutput.fix.to_i >= 1
				f1.write(multioutput.multiOutputLineFull3(flag) + "\n");
			end
		end
		f.close();
		f1.close();
	end
	
	def sources
		@sources
	end
	
	
end