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
//3
Double_t powerlaw(Double_t *x, Double_t *par)
{
		//Prefactor = $N_0$ par[0]
		//Index = $\gamma$ par[1]
		//Scale = $E_0$ par[2]
		//dN / dE = N_0 * ( E / E_0 ) ^ \gamma
		par[2] = 100;
        Double_t f = par[0] * pow((x[0]/par[2]), -par[1]);
        return f;
}	

//4
Double_t logparabola(Double_t *x, Double_t *par)
{
		//norm = $N_0$ par[0]
		//alpha = par[1]
		//beta par[2]
		//Eb = $E_0$ par[3]
        Double_t f = par[0] * pow((x[0]/par[3]), -(-par[1] + par[2] * TMath::Log(x[0] / par[3])));
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


	t->SetBranchAddress("ERG", &erg);
	t->SetBranchAddress("EMIN", &emin);
	t->SetBranchAddress("EMAX", &emax);
	t->SetBranchAddress("ELOGC", &e_log_center);
//	t->SetBranchAddress("SI", &spectral_index);
	Long64_t j = 0;
	for(j = 0; j<nlines; j++) {
    	t->GetEntry(j);
    	x[j] = e_log_center;
    	y[j] = erg;
    	exl[j] = e_log_center - emin;
    	exh[j] = emax - e_log_center;
    	eyl[j] = eyh[j] = erg / 10.;
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

void fitSpectra(string filename) {

	ROOT::Math::MinimizerOptions::SetDefaultMinimizer("Minuit2");

	//int n = loadAGILESpectra(filename);
	int n = loadFERMISpectra(filename);

	TGraphAsymmErrors* gr = new TGraphAsymmErrors(x,y,exl,exh,eyl,eyh);
   	gr->SetTitle("TGraphAsymmErrors Spectra");
   	gr->SetMarkerColor(4);
   	gr->SetMarkerStyle(21);
   	gr->Draw("ALP");
   	gPad->SetLogx();
   	gPad->SetLogy();
   	double maxenergy = x[n-1] + exh[n-1];
   	double minenergy = x[0] - exl[0];
   	cout << "min energy: " << minenergy << endl;
   	cout << "max energy: " << maxenergy << endl;
   	
   	//Prefactor = $N_0$ par[0]
		//Index = $\gamma$ par[1]
		//Scale = $E_0$ par[2]
   	TF1* plaw = new TF1("powerlaw", powerlaw, minenergy, maxenergy, 3);
    plaw->SetParName(0, "N0");
    plaw->SetParName(1, "gamma");
    plaw->SetParName(2, "E0");
    //plaw->SetParLimits(0, 0, 5);
    plaw->SetParameter(0, 10e-9);
    plaw->SetParLimits(1, 0, 3);
    plaw->SetParLimits(2, minenergy, maxenergy);
    plaw->SetLineColor(kBlue);
    
    TF1* logp = new TF1("logparabola", logparabola, minenergy, maxenergy, 4);
    logp->SetParName(0, "norm");
    logp->SetParName(1, "alpha");
    logp->SetParName(2, "beta");
    logp->SetParName(3, "eb");
    
    //N0
    //logp->SetParLimits(0, 0, 1);
    logp->FixParameter(0, 1e-10);
    
    //alpha
    //logp->SetParLimits(1, 1, 3);
    logp->FixParameter(1, 1.8);
    
    //beta
    logp->SetParLimits(2, 0.2, 0.4);
    //logp->FixParameter(2, 0.3);//0.0386
    
    //EB
    logp->SetParLimits(3, minenergy, maxenergy);
    //logp->FixParameter(3, 110);
    
    
    
    logp->SetLineColor(kRed);
    
    gr->Fit(logp);
    gr->Fit(logp);
    //f3sf->Draw("L");

}