load ENV["AGILE"] + "/scripts/conf.rb"

fits = Fits.new

dir = "/ASDC_PROC3/DATA_ASDC2/"

fout = File.new(dir + "INDEX/LOG.log.index", "w")

Dir[dir + "/LOG/*.gz"].each do | file |
        puts file
        fits.readFitsHeader(file);
        fout.write(file + " " + fits.tt_start + " " + fits.tt_end + " LOG\n");
end
fout.close()

dir = "/ASDC_PROC3/FM3.119_ASDC2/"

fout = File.new(dir + "INDEX/EVT.index", "w")

Dir[dir + "/EVT/*.gz"].each do | file |
        puts file
        fits.readFitsHeader(file);
        fout.write(file + " " + fits.tt_start + " " + fits.tt_end + " EVT\n");
end
fout.close()
