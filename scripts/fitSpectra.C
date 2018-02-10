#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <string>       // std::string
#include "TGraphAsymmErrors.h"

using namespace std;

TVectorF x(100);
TVectorF y(100);
TVectorF exl(100);
TVectorF exh(100);
TVectorF eyl(100);
TVectorF eyh(100);
float spectral_index = 0;

//funzione per fare il fitting
/*
<source name="PowerLaw_source" type="PointSource">
<!-- point source units are cm^-2 s^-1 MeV^-1 -->
<spectrum type="PowerLaw">
<parameter free="1" max="1000.0" min="0.001" name="Prefactor" scale="1e-09" value="1"/>
<parameter free="1" max="-1.0" min="-5." name="Index" scale="1.0" value="-2.1"/>
<parameter free="0" max="2000.0" min="30.0" name="Scale" scale="1.0" value="100.0"/>
</spectrum>
<spatialModel type="SkyDirFunction">
<parameter free="0" max="360." min="-360." name="RA" scale="1.0" value="83.45"/>
<parameter free="0" max="90." min="-90." name="DEC" scale="1.0" value="21.72"/>
</spatialModel>
</source>
*/
Double_t powerlaw(Double_t *x, Double_t *par)
{
		//Prefactor = $N_0$ par[0]
		//Index = $\gamma$ par[1]
		//Scale = $E_0$ par[2]
		//dN / dE = N_0 * ( E / E_0 ) ^ \gamma
		Double_t gamma = -par[1]; //ATTENZIONE!!!!!!!!!
        Double_t f = par[0] * pow((x[0]/par[2]), gamma);
        return f;
}	

/*
<source name="LogParabola_source" type="PointSource">
<!-- point source units are cm^-2 s^-1 MeV^-1 -->
<spectrum type="LogParabola">
<parameter free="1" max="1000.0" min="0.001" name="norm" scale="1e-9" value="1"/>
<parameter free="1" max="10" min="0" name="alpha" scale="1.0" value="1"/>
<parameter free="1" max="1e4" min="20" name="Eb" scale="1" value="300."/>
<parameter free="1" max="10" min="0" name="beta" scale="1.0" value="2"/>
</spectrum>
<spatialModel type="SkyDirFunction">
<parameter free="0" max="360." min="-360." name="RA" scale="1.0" value="83.45"/>
<parameter free="0" max="90." min="-90." name="DEC" scale="1.0" value="21.72"/>
</spatialModel>
</source>
*/
Double_t logparabola(Double_t *x, Double_t *par)
{
		//norm = $N_0$ par[0]
		//alpha = par[1]
		//beta par[2]
		//Eb = $E_0$ par[3]
		Double_t alpha = par[1]; //ATTENZIONE
        Double_t f = par[0] * pow((x[0]/par[3]), -(alpha + par[2] * TMath::Log(x[0] / par[3])));
        return f;
}

/*
<source name="PLExpCutoff_source" type="PointSource">
<!-- point source units are cm^-2 s^-1 MeV^-1 -->
<spectrum type="PLSuperExpCutoff">
<parameter free="1" max="1000" min="1e-05" name="Prefactor" scale="1e-07" value="1"/>
<parameter free="1" max="0" min="-5" name="Index1" scale="1" value="-1.7"/>
<parameter free="0" max="1000" min="50" name="Scale" scale="1" value="200"/>
<parameter free="1" max="30000" min="500" name="Cutoff" scale="1" value="3000"/>
</spectrum>
<spatialModel type="SkyDirFunction">
<parameter free="0" max="360." min="-360." name="RA" scale="1.0" value="83.45"/>
<parameter free="0" max="90." min="-90." name="DEC" scale="1.0" value="21.72"/>
</spatialModel>
</source>
*/
Double_t plexpcutoff(Double_t *x, Double_t *par)
{
		//norm = $N_0$ par[0]
		//gamma = par[1]
		//E0 par[2]
		//Ec = par[3] //cutoff energy
		Double_t gamma = -par[1]; //ATTENZIONE!!!!!!!!!
        Double_t f = par[0] * pow((x[0]/par[2]), gamma) * exp(- (x[0] - par[2]) / par[3] );
        return f;
}

/*
<source name="PLSuperExpCutoff_source" type="PointSource">
<!-- point source units are cm^-2 s^-1 MeV^-1 -->
<spectrum type="PLSuperExpCutoff">
<parameter free="1" max="1000" min="1e-05" name="Prefactor" scale="1e-07" value="1"/>
<parameter free="1" max="0" min="-5" name="Index1" scale="1" value="-1.7"/>
<parameter free="0" max="1000" min="50" name="Scale" scale="1" value="200"/>
<parameter free="1" max="30000" min="500" name="Cutoff" scale="1" value="3000"/>
<parameter free="1" max="5" min="0" name="Index2" scale="1" value="1.5"/>
</spectrum>
<spatialModel type="SkyDirFunction">
<parameter free="0" max="360." min="-360." name="RA" scale="1.0" value="83.45"/>
<parameter free="0" max="90." min="-90." name="DEC" scale="1.0" value="21.72"/>
</spatialModel>
</source>
*/
Double_t plsuperexpcutoff(Double_t *x, Double_t *par)
{
		//norm = $N_0$ par[0]
		//gamma1 = par[1]
		//E0 par[2]
		//Ec = par[3] //cutoff energy
		//gamma2 = par[4]
		Double_t gamma1 = -par[1]; //ATTENZIONE!!!!!!!!!
		Double_t gamma2 = par[4];
        Double_t f = par[0] * pow((x[0]/par[2]), gamma1) * exp(- pow(x[0] / par[3], gamma2) );
        return f;
}

int loadAGILESpectra(TString filename) {
	//(0)sqrtts (1)flux[ph/cm2/s] (2)flux_err (3)erg[erg/cm2/s] (4)Erg_err (5)Emin (6)Emax (7)E_log_center (8)exp (9)flux_ul (10)spectral_index (11)spectral_index_err (12)id_detection
	

	int i = 0;
	float sqrtts, flux, flux_err, erg, erg_err, emin, emax, e_log_center, exp, flux_ul;
	
	TTree* t = new TTree("DATA", "");
	//METTERE IL DATA TYPE IN MODO ESPLICITO:
	Long64_t nlines = t->ReadFile(filename, "SQRTTS/F:FLUX/F:FLUXE/F:ERG/F:ERGE/F:EMIN/F:EMAX/F:ELOGC/F:EXP/F:FLUXUL/F:SI/F:SIE/F:ID/F");

	cout << nlines << endl;


	t->SetBranchAddress("ERG", &erg);
	t->SetBranchAddress("ERGE", &erg_err);
	t->SetBranchAddress("EMIN", &emin);
	t->SetBranchAddress("EMAX", &emax);
	t->SetBranchAddress("ELOGC", &e_log_center);
	t->SetBranchAddress("SI", &spectral_index);
	Long64_t j = 0;
	for(j = 0; j<nlines; j++) {
    	t->GetEntry(j);
    	x[j] = e_log_center;
    	y[j] = erg;
    	exl[j] = e_log_center - emin;
    	exh[j] = emax - e_log_center;
    	eyl[j] = eyh[j] = erg_err;
    	cout << x[j] << " " << exl[j] << " " << exh[j] << " erg " << y[j] << " " << " " << eyl[j] << " " << eyh[j] << endl;
	}
	cout << "dim " << x.GetNrows() << endl;
	x.ResizeTo(j);
	y.ResizeTo(j);
	exl.ResizeTo(j);
	exh.ResizeTo(j);
	eyl.ResizeTo(j);
	eyh.ResizeTo(j);
	return x.GetNrows();
}

int loadFERMISpectra(TString filename) {
	//(0)sqrtts (1)flux[ph/cm2/s] (2)erg[erg/cm2/s] (3)Emin (4)Emax (5)E_log_center
	

	int i = 0;
	float sqrtts, flux, flux_err, erg, erg_err, emin, emax, e_log_center, exp, flux_ul;
	
	TTree* t = new TTree("DATA", "");
	//METTERE IL DATA TYPE IN MODO ESPLICITO:
	Long64_t nlines = t->ReadFile(filename, "SQRTTS/F:FLUX/F:ERG/F:EMIN/F:EMAX/F:ELOGC/F:SI/F");

	cout << nlines << endl;

	t->SetBranchAddress("FLUX", &flux);
	t->SetBranchAddress("ERG", &erg);
	t->SetBranchAddress("EMIN", &emin);
	t->SetBranchAddress("EMAX", &emax);
	t->SetBranchAddress("ELOGC", &e_log_center);
//	t->SetBranchAddress("SI", &spectral_index);
	Long64_t j = 0;
	for(j = 0; j<nlines; j++) {
    	t->GetEntry(j);
    	x[j] = e_log_center;
    	y[j] = flux; //erg
    	exl[j] = e_log_center - emin;
    	exh[j] = emax - e_log_center;
    	eyl[j] = eyh[j] = y[j] / 100.;
    	cout << x[j] << " " << exl[j] << " " << exh[j] << " erg " << y[j] << " " << " " << eyl[j] << " " << eyh[j] << endl;
	}
	cout << "dim " << x.GetNrows() << endl;
	x.ResizeTo(j);
	y.ResizeTo(j);
	exl.ResizeTo(j);
	exh.ResizeTo(j);
	eyl.ResizeTo(j);
	eyh.ResizeTo(j);
	return x.GetNrows();
}

void drawSpectra() {

}

void fitSpectra(string filename) {

	TCanvas* c1 = new TCanvas();
	c1->Divide(2,1);
	c1->cd(1);
	gPad->SetLogx();
   	gPad->SetLogy();
   	c1->cd(2);
   	gPad->SetLogx();
   	gPad->SetLogy();


	//int n = loadAGILESpectra(filename);
	int n = loadFERMISpectra(filename);

	//TGraphAsymmErrors* gr = new TGraphAsymmErrors(x,y,exl,exh,eyl,eyh);
	TGraph* gr = new TGraph(x, y); 
	TString tit = filename;
   	gr->SetTitle(tit);
   	gr->SetMarkerColor(4);
   	gr->SetMarkerStyle(21);
   	c1->cd(1);
   	gr->Draw("ALP");
   	
   	double maxenergy = x[n-1] + exh[n-1];
   	double minenergy = x[0] - exl[0];
   	cout << "min energy: " << minenergy << endl;
   	cout << "max energy: " << maxenergy << endl;
   	
	////////////////////////////////////////////////////////////////////////////////
   	//Prefactor = $N_0$ par[0]
		//Index = $\gamma$ par[1]
		//Scale = $E_0$ par[2]
   	TF1* plaw = new TF1("powerlaw", powerlaw, minenergy, maxenergy, 3);
    plaw->SetParName(0, "N0");
    plaw->SetParName(1, "gamma");
    plaw->SetParName(2, "E0");
    
    //<parameter free="1" max="1000.0" min="0.001" name="Prefactor" scale="1e-09" value="1"/>
    plaw->SetParLimits(0, 1e-12, 1e-5);
    plaw->SetParameter(0, 1e-9);
    plaw->FixParameter(0, 1e-9);
    
    //<parameter free="1" max="-1.0" min="-5." name="Index" scale="1.0" value="-2.1"/>
    plaw->SetParLimits(1, 1, 5);
    plaw->SetParameter(1, 2.1);
    //plaw->FixParameter(1, 2.1);
    
    //<parameter free="0" max="2000.0" min="30.0" name="Scale" scale="1.0" value="100.0"/>
    plaw->SetParLimits(2, 30, 2000);
    plaw->SetParameter(2, 100);
    plaw->FixParameter(2, 100);
    
    plaw->SetLineColor(kBlue);
    
    ///////////////////////////////////////////////////////////////////////////////
    TF1* logp = new TF1("logparabola", logparabola, minenergy, maxenergy, 4);
    logp->SetParName(0, "norm");
    logp->SetParName(1, "alpha");
    logp->SetParName(2, "beta");
    logp->SetParName(3, "eb");
    
    //N0
    //<parameter free="1" max="1000.0" min="0.001" name="norm" scale="1e-9" value="1"/>
    logp->SetParLimits(0, 1e-12, 1e-6);
    logp->SetParameter(0, 1e-9);
    //logp->FixParameter(0, 1e-9);
    
    //alpha
    //<parameter free="1" max="10" min="0" name="alpha" scale="1.0" value="1"/>
    logp->SetParLimits(1, 0, 10);
    logp->SetParameter(1, 1);
    //logp->FixParameter(1, 1.879);
    
    //beta
    //<parameter free="1" max="10" min="0" name="beta" scale="1.0" value="2"/>
    logp->SetParLimits(2, 0.0, 10);
    logp->SetParameter(2, 2);
    //logp->FixParameter(2, 0.0386); //0.0386
    
    //EB
    //<parameter free="1" max="1e4" min="20" name="Eb" scale="1" value="300."/>
    logp->SetParLimits(3, 20, 1e4);
    logp->SetParameter(3, 300);
    //logp->FixParameter(3, 120);

    logp->SetLineColor(kRed);
    
    //////////////////////////////////////////////////////////////////////////////
	TF1* ple = new TF1("plexpcutoff", plexpcutoff, minenergy, maxenergy, 4);
    ple->SetParName(0, "norm");
    ple->SetParName(1, "gamma");
    ple->SetParName(2, "E0");
    ple->SetParName(3, "Ec");	//cutoff
	
	//<parameter free="1" max="1000" min="1e-05" name="Prefactor" scale="1e-07" value="1"/>
	ple->SetParLimits(0, 1e-12, 1e-4);	
	ple->SetParameter(0, 1e-07);
    //ple->FixParameter(0, 1e-07);	
    
    //<parameter free="1" max="0" min="-5" name="Index1" scale="1" value="-1.7"/>
    ple->SetParLimits(1, 0, 5);
    ple->SetParameter(1, 1.7);
    //ple->FixParameter(1, 1.00295);
    
    //<parameter free="0" max="1000" min="50" name="Scale" scale="1" value="200"/>
    ple->SetParLimits(2, 50, 1000);
    ple->SetParameter(2, 200);
    //ple->FixParameter(2, 200);
    
    //<parameter free="1" max="30000" min="500" name="Cutoff" scale="1" value="3000"/>
    ple->SetParLimits(3, 500, 30000);
    ple->SetParameter(3, 3000);
    //ple->FixParameter(3, 255.80); //500, 30000
    
    ///////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////

	TF1* psle = new TF1("plsuperexpcutoff", plexpcutoff, minenergy, maxenergy, 5);
    psle->SetParName(0, "Prefactor");
    psle->SetParName(1, "Index1");
    psle->SetParName(2, "Scale");
    psle->SetParName(3, "Ecutoff");	//cutoff
	psle->SetParName(4, "Index2");
	
	//<parameter free="1" max="1000" min="1e-05" name="Prefactor" scale="1e-07" value="1"/>
	psle->SetParLimits(0, 1e-12, 1e-4);	
	psle->SetParameter(0, 1e-07);
    //psle->FixParameter(0, 7.55801e-06);	
    
    //<parameter free="1" max="0" min="-5" name="Index1" scale="1" value="-1.7"/>
    //3FGL Spectral_Index
    psle->SetParLimits(1, 0, 5);
    psle->SetParameter(1, 1.7);
    //psle->FixParameter(1, 1.00295);
    
    //<parameter free="0" max="1000" min="50" name="Scale" scale="1" value="200"/>
    psle->SetParLimits(2, 50, 1000);
    psle->SetParameter(2, 200);
    //psle->FixParameter(2, 127.589);
    
    //<parameter free="1" max="30000" min="500" name="Cutoff" scale="1" value="3000"/>
    //Cutoff 3FGL
    psle->SetParLimits(3, 500, 30000);
    psle->SetParameter(3, 3000);
    //psle->FixParameter(3, 255.80); 
    
    //<parameter free="1" max="5" min="0" name="Index2" scale="1" value="1.5"/>
    //Exp_Index 
    psle->SetParLimits(4, 0, 5);
    psle->SetParameter(4, 1.5);
    //psle->FixParameter(4, 0.4759);
    
    
    ////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////
    
    //plaw -> PowerLaw
    //logp -> LogParabole
    //ple -> PLExpCutoff
    //psle -> PLSuperExpCutoff
    TF1* fitfun = psle;
    
    ROOT::Math::MinimizerOptions::SetDefaultMinimizer("Minuit");
	//cout << ROOT::Math::MinimizerOptions::DefaultTolerance() << endl;
	//cout << ROOT::Math::MinimizerOptions::DefaultPrecision() << endl;
	//ROOT::Math::MinimizerOptions::SetDefaultTolerance(0.000001);

    
    gr->Fit(fitfun);
    //ROOT::Math::MinimizerOptions::SetDefaultMinimizer("Minuit");
    //gr->Fit(fitfun);
    //gr->Fit(fitfun);
    //gr->Fit(fitfun);
    
    c1->cd(2);
    fitfun->Draw("");
    gr->Draw("LP");

   // gr->Fit(ple);
    //f3sf->Draw("L");

}