load ENV["AGILE"] + "/scripts/conf.rb"

basepath = ARGV[0]

fits = Fits.new

dir = basepath + "/DATA_2/"

fout = File.new(dir + "INDEX/LOG.log.index", "w")

Dir[dir + "/LOG/*.gz"].each do | file |
        puts file
        fits.readFitsHeader(file);
        fout.write(file + " " + fits.tt_start + " " + fits.tt_end + " LOG\n");
end
fout.close()

dir = basepath + "/FM3.119_2/"

fout = File.new(dir + "INDEX/EVT.index", "w")

Dir[dir + "/EVT/*.gz"].each do | file |
        puts file
	if File.size(file).to_i != 0
        	fits.readFitsHeader(file);
        	fout.write(file + " " + fits.tt_start + " " + fits.tt_end + " EVT\n");
	end
end
fout.close()
