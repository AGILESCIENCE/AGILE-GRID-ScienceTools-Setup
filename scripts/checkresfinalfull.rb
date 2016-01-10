#! /usr/bin/ruby
#0) file name input
#1) file name output (optional): if specified, generate a multi file
#2) min sqrt(ts)
#3) color
#4) 2AGL name generation (1 yes, 0 no)
#5) minimum exposure (default 0, e.g. 5.4e8)
#6) systematic error (default 0.2)
#7) list of sources to write to output

load ENV["AGILE"] + "/scripts/conf.rb"

filename = ARGV[0]

datautils = DataUtils.new

if ARGV[0].to_s == "help" || ARGV[0] == nil || ARGV[0] == "h"
	system("head -10 " + $0 );
	exit;
end

if ARGV[5] != nil
	expmin = ARGV[5]
else
	expmin = 0
end

if ARGV[6] != nil
	systematicerror = ARGV[6]
else
	systematicerror = 0.2
end


if ARGV[1] != nil
	if ARGV[2] != nil
		mints = ARGV[2]
	else
		mints = 0
	end
	if ARGV[3] != nil
		color = ARGV[3]
	else
		color = "green"
	end
	fout = File.new(ARGV[1] + ".multi", "w")
	fout2 = File.new(ARGV[1] + ".reg", "w");
	fout3 = File.new(ARGV[1] + ".ell", "w");
	fout4 = File.new(ARGV[1] + ".res2", "w");
	fout5 = File.new(ARGV[1] + ".res3", "w");
	File.open(ARGV[0]).each do | line1 |
		lll1 = line1.split(" ")
		name = lll1[1]
		
		ts = lll1[2]
		flux = lll1[21]
		fixflag = "0"
		dist = "0.0"
		l1 = lll1[4]
		b1 = lll1[5]
		
		si1 = lll1[29]
		exp = lll1[27]
		if ts.to_f >= mints.to_f && exp.to_f > expmin.to_f
			if lll1[7].to_i != -1
				lll = lll1[7]
				bbb = lll1[8]
			else
				lll = l1
				bbb = b1
			end
			if(ARGV[4].to_i == 1)
				fidl = File.new("idlcom", "w")

                        	fidl.write("getsource_name, " + lll.to_s + ", " + bbb.to_s)

                        	fidl.close()

                        	system("idl < idlcom > /dev/null 2> /dev/null")

                        	ssname = ""

                        	File.open("source_name.prt", "r").each_line do |line2|

                            ssname = line2

                        	end

                        	ssname = "2AGLJ" + ssname.chomp

				name = ssname;
				#puts name
			end
			wr = false
			if ARGV[7] != nil
				File.open(ARGV[7]).each_line do | line2 |
					if name.chomp == line2.chomp
						wr = true
					end
				end
			else
				wr = true
			end
			if wr == false
				next
			end
			fout.write(flux + " " + l1 + " " + b1 + " " + si1.to_s + " 0 2 " + name + " 0.0\n")
			out2 = name
			for i in 1..lll1.size()
				out2 = out2 + " " + lll1[i].to_s
			end
			fout4.write(out2 + "\n")
			
			fout5.write(lll1[1] + " " + lll1[2] + " " + lll1[0] + " " + lll1[82] + " " + lll1[86] + " " + lll1[87] + " " + " " + lll1[21] + " " + lll1[22] + " " + " " + lll1[4] + " " + lll1[5] + " " + lll1[6]  + " " + lll1[7] + " " + lll1[8] + " " + lll1[9] + " " + lll1[10] + " " + lll1[11] + " " + lll1[12] + " " + lll1[13] + " " + (lll1[11].to_f / lll1[12].to_f).to_s +  " " + lll1[88] + " " + lll1[29] + " " + lll1[30] + " " + lll1[27] + " " + lll1[90] + "\n")
			
			
			if lll1[10].to_i != -1
				fout2.write("galactic;ellipse(" + lll1[7].to_s + "," + lll1[8].to_s + "," + (lll1[10].to_f+systematicerror.to_f).to_s + "," + (lll1[11].to_f+systematicerror.to_f).to_s + ", " + (- lll1[12].to_f).to_s + ") # color=" + color + " text={" + name + "}")
				fout3.write(name + " " + lll1[7].to_s + " " + lll1[8].to_s + " " + (lll1[10].to_f+systematicerror.to_f).to_s + " " + (lll1[11].to_f+systematicerror.to_f).to_s + " " + (- lll1[12].to_f).to_s)
				
			else
				fout2.write("galactic;ellipse(" + l1.to_s + "," + b1.to_s + ",1800\",1800\",0.0) # color=" + color + " text={" + name + "}")
				fout3.write(name + " " + l1.to_s + " " + b1.to_s + " 0.6 0.6 0.0 ")
			end
			fout2.write("\n")
			fout3.write("\n")
		end
	end
	fout.close()
	fout2.close()
	fout3.close()
	fout4.close()
	fout5.close()
end
