#0) input file source list
#1) file name base of the .multi
#2) filter
#3) prefix
#4) dir output
#5) fixflag of analysis
#6) additional commands to multi.rb (optional)

#Questo script si usa per fare la scansione su una lista di sorgenti (source list) fissandole tutte tranne una. 
#Alla fine si raccoglie il risultato finale nelle directory che viene creata (dir output)
#NB: tutte le sorgenti sono messe con fixflag=0 di default prima di inziare l'analisi
#Le sorgenti che hanno il nome che inizia con _ non sono analizzate, ma lasciate nel fondo

#ruby ~/grid_scripts2/make_catalogs/makecatalog_phase3.rb list3.multi OB1 FM3.119_ASDCd_I0007 -999 OUT 3 "maplist=OB0000_FM3.119_ASDCd_I0007_b020.maplist4 multitype=4"

load "~/grid_scripts3/MultiOutput.rb"

if ARGV[0].to_s == "help" || ARGV[0].to_s == "h" || ARGV[0] == nil 
	system("head -13 " + $0 );
	exit;
end

diroutput = ARGV[4]

fixflaganalysis=ARGV[5]

maplist=nil
if ARGV[6] != nil
	maplist=ARGV[6]
end

class Source < 
  Struct.new(:flux, :l, :b, :si, :fixflag, :minsqrtts, :name, :rmax)
  
  def print
    puts flux.to_s + " " + l.to_s + " " + b.to_s + " " + si.to_s + " " + fixflag.to_s + " " + minsqrtts.to_s + " " + name.to_s + " " + rmax.to_s
  end
  
  def output
	@output = flux.to_s + " " + l.to_s + " " + b.to_s + " " + si.to_s + " " + fixflag.to_s + " " + minsqrtts.to_s + " " + name.to_s + " " + rmax.to_s  
  end
  
  
end


cmd = "mkdir " + diroutput
system cmd

resfilename =diroutput.to_s + ".res"

sources = Array.new

a = File.open(ARGV[0], "r")

a.each_line do | line |
  words = line.split(" ")
  s = Source.new
  s.flux = words[0].to_f
  s.l = words[1].to_f
  s.b = words[2].to_f
  s.si = words[3].to_f
  s.fixflag = words[4].to_i
  s.minsqrtts = words[5].to_f
  s.name = words[6].to_s
  s.rmax = words[7].to_f
  sources.push(s)
#   s.print
end

sources2 = sources.sort_by { |a| [ -a.flux ] }

sources2.each { |s|
	s.print
	s.fixflag=0
	s.rmax = 2.0
}

index = 0
ffinal = diroutput.to_s + ".resfinal"
ffinalfull = diroutput.to_s + ".resfinalfull"

fout1 = File.new(ffinal, "w")
fout2 = File.new(ffinalfull, "w")

sources2.each { |s|
	namesource = s.name
	#salta quelle che iniziano con _
	if namesource[0].to_i == 95
		next
	else
		puts "1"
	end
	puts namesource
	
	#metti la sorgente da analizzare con fixflag passato da input
	s.fixflag = fixflaganalysis
	
	filename = ARGV[1].to_s + "_" + index.to_s + ".multi"
	fo = File.new(filename, "w")
	sources2.each { |s2|
		out = s2.output
		fo.write(out + "\n")
	}
	fo.close()
	#il file di input e' pronto, si esegue ora il multi
	addcmd = ""
	if maplist != nil
		addcmd = maplist
	end
	cmd = "ruby ~/grid_scripts3/multi5.rb " + ARGV[2].to_s + " " + ARGV[3].to_s + " " + filename.to_s + " outfile=" + resfilename.to_s + " " + addcmd.to_s
	puts cmd
	system cmd
	#eseguita la alike, copio via i risulati
	cmd = "cp " + resfilename.to_s + "_" + namesource.to_s + "* " + diroutput
	system cmd
	cmd = "mv " + resfilename.to_s + " " + diroutput + "/" + namesource.to_s + ".res"
	system cmd
	#modifico ora i dati della sorgente che e' stata calcolata
	sout = MultiOutput.new
	sout.readDataSingleSource(resfilename.to_s + "_" + namesource.to_s);
	fout1.write(sout.multiOutputLine + "\n")
	fout2.write(sout.multiOutputLineFull + "\n")
	#aggiorna i valori
	s.flux = sout.flux
	s.l = sout.l_peak
	s.b = sout.b_peak
	#alla fine rimettilo a 0
	s.fixflag = 0
	index = index + 1
}
fout1.close()
fout2.close()

system("mv " + ffinal.to_s + " " + diroutput.to_s + "/" + resfilename.to_s)
system("mv " + ffinalfull.to_s + " " + diroutput.to_s)



