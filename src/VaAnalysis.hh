//**********************************************************************
//
//     HALL A C++/ROOT Parity Analyzer  Pan           
//
//       VaAnalysis.hh  (interface)
//
// Author:  R. Holmes <http://mepserv.phy.syr.edu/~rsholmes>, A. Vacheret <http://www.jlab.org/~vacheret>, R. Michaels <http://www.jlab.org/~rom>
// @(#)pan/src:$Name$:$Id$
//
////////////////////////////////////////////////////////////////////////
//
// Abstract base class of analysis. Derived classes include TaADCCalib
// (for computation of pedestals and DAC noise slopes), TaBeamAna (for
// analysis of beam characteristics), and TaPromptAna (for prompt
// physics analysis).  Each of these is responsible for some treatment
// of TaEvents from a TaRun.  The type of analysis to be done is
// specified in the database, and the TaAnalysisManager instantiates
// the appropriate analysis class accordingly.
//
// VaAnalysis has initialization and termination routines for both the
// overall analysis and the analysis of a particular run.  At present
// Pan is designed to analyze only a single run, but these routines
// provide for a possible future version that will handle multiple
// runs.
//
// The main event loop is inside the ProcessRun method.  The three
// main methods called from here are PreProcessEvt, ProcessEvt, and
// ProcessPair.  The first of these places the most recently read
// event into a delay queue until the delayed helicity information for
// that event becomes available.  Cut conditions are checked for here.
// Once the helicity information is added the event is pushed onto a
// second delay queue, while the events are used to construct pairs
// which are pushed onto a third delay queue.  These two delay queues
// are used to hold events and pairs until we can tell whether they
// fall within a cut interval caused by a cut condition arising later.
// Events and pairs which emerge from the ends of these queues are
// analyzed in ProcessEvt and ProcessPair, respectively.  Analysis
// results are added to the events and pairs themselves.
//
////////////////////////////////////////////////////////////////////////

#ifndef PAN_VaAnalysis
#define PAN_VaAnalysis

#include "Rtypes.h"
#include "TTree.h"
#include "PanTypes.hh"
#include <deque>
#include <string>
#include <strstream>
#include <utility>
#include <vector>

class TaCutList;
class TaRun;
class TaEvent;
class VaPair;
class AnaList {
// Utility class of variable info
public: 
  AnaList(string svar, Int_t ivar, string sun, UInt_t iflag) :
    fVarStr(svar), 
    fVarInt(ivar), 
    fVarInts(0), 
    fVarWts(0),
    fUniStr(sun), 
    fFlagInt(iflag) { }
  AnaList(string svar, vector<Int_t> ivars, vector<Double_t> wts, string sun, UInt_t iflag) :
    fVarStr(svar), 
    fVarInt(0), 
    fUniStr(sun), 
    fFlagInt(iflag) 
  {
    fVarInts = new vector<Int_t> (ivars);
    fVarWts = new vector<Double_t> (wts);
  }
  AnaList (const AnaList& al) :
    fVarStr(al.fVarStr), 
    fVarInt(al.fVarInt), 
    fUniStr(al.fUniStr), 
    fFlagInt(al.fFlagInt) 
  {
    if (al.fVarInts != 0)
      {
	fVarInts = new vector<Int_t> (*(al.fVarInts));
	fVarWts = new vector<Double_t> (*(al.fVarWts));
      }
    else
      {
	fVarInts = 0;
	fVarWts = 0;
      }
  }
  ~AnaList() { delete fVarInts; delete fVarWts; }
  AnaList& operator= (const AnaList& al) 
  {
    if (this != &al)
      {
	fVarStr = al.fVarStr;
	fVarInt = al.fVarInt;
	fUniStr = al.fUniStr;
	fFlagInt = al.fFlagInt;
	if (al.fVarInts != 0)
	  {
	    fVarInts = new vector<Int_t> (*(al.fVarInts));
	    fVarWts = new vector<Double_t> (*(al.fVarWts));
	  }
	else
	  {
	    fVarInts = 0;
	    fVarWts = 0;
	  }
      }
    return *this;
  }

  string fVarStr; 
  Int_t fVarInt;
  vector<Int_t> *fVarInts;
  vector<Double_t> *fVarWts;
  string fUniStr;
  UInt_t fFlagInt;
};

class VaAnalysis
{
  // Base class for analysis.  

  // Most of the member functions are virtual, although some have
  // default implementations that probably will not need to be changed
  // by most derived classes.

  // Calling function should call Init, RunIni, Process, RunFini, and
  // Finish in that order.  These respectively initialize the whole
  // analysis; initialize the analysis of a run (somewhat redundant
  // since at present Pan handles only one run per analysis); process
  // the run; finish processing the run (again somewhat redundant);
  // and finish the analysis.

public:

  // Constructors/destructors/operators
  VaAnalysis();
  virtual ~VaAnalysis();

  // We should not need to copy or assign an analysis, so copy
  // constructor and operator= are protected.

  // Major functions
  virtual void Init(const Bool_t&);
  virtual ErrCode_t RunIni(TaRun&);
  virtual ErrCode_t RunReIni(TaRun&);
  virtual ErrCode_t ProcessRun();
  virtual void RunFini();
  virtual void Finish();

  // Data access functions
  size_t PairsLeft() const { return fPDeque.size(); }

  // Constants

  // Flags for results
  static const UInt_t fgNO_STATS;        // Do not print statistics
  static const UInt_t fgNO_BEAM_NO_ASY;  // Do not compute asym if lobeam cut fails
  static const UInt_t fgCOPY;            // Store right and left values as results
  static const UInt_t fgDIFF;            // Store R-L difference as result
  static const UInt_t fgASY;             // Store asymmetry as result
  static const UInt_t fgASYN;            // Store normalized asymmetry as result
  static const UInt_t fgAVE;             // Use average asymmetry, not sum
  static const ErrCode_t fgVAANA_ERROR;  // returned on error
  static const ErrCode_t fgVAANA_OK;      // returned on success
  static const UInt_t fgNumBpmFdbk;
  static const EventNumber_t fgSLICELENGTH;  // events in a statistics slice

protected:


  // Protected member functions

  // We should not need to copy or assign an analysis, so copy
  // constructor and operator= are protected.
  VaAnalysis( const VaAnalysis& copy);
  VaAnalysis& operator=(const VaAnalysis& assign);

  // PreProcessEvt checks events, puts them on the event delay queues,
  // puts events into pairs and pushes pairs onto the pair delay
  // queue.  ProcessEvt (ProcessPair) handles analysis of each event
  // (pair) that has passed through the event (pair) delay queues.  The
  // actual analysis happens in protected member functions
  // EventAnalysis and PairAnalysis; these are pure virtual and must
  // be supplied by the derived classes.

  virtual ErrCode_t PreProcessEvt();
  virtual ErrCode_t ProcessEvt();
  virtual ErrCode_t ProcessPair();
  virtual void EventAnalysis () = 0;
  virtual void PairAnalysis () = 0;
  ErrCode_t NewPrePair();
  virtual void InitChanLists ();
  virtual void InitTree (const TaCutList&);
  virtual vector<AnaList> ChanList (const string& devtype, 
				      const string& channel, 
				      const string& other,
				      const UInt_t flags = 0);
  virtual vector<AnaList> ChanListFromName (const string& chanbase, 
					    const string& other, 
					    const UInt_t flags = 0);
  virtual void AutoPairAna();
  // virtual void SendVoltagePC();
  virtual void PZTSendEPICS();
  virtual void SendVoltagePZT();
  virtual void GetLastSetPt();
  // new code 
  virtual void InitFeedback();
  virtual void ProceedFeedback();
  virtual void ProceedLastFeedback();
  virtual void ComputeData(EFeedbackType fdbk, UInt_t timescale, Int_t devicekey);
  virtual void ComputeLastData(EFeedbackType fdbk, UInt_t timescale, Int_t devicekey);
  virtual void SendEPICS(EFeedbackType fdbk); 


  // Data members
  TaRun* fRun;                  // Run being analyzed
  UInt_t fMaxNumEv;             // Max number of events to analyze
  TaEvent* fPreEvt;             // Event being preprocessed
  VaPair* fPrePair;             // Pair being built
  // There are three delay queues (actually deques) fEHelDeque is used
  // to implement delayed helicity.  fEDeque and fPDeque are used to
  // implement cut extensions.  Note pairs are queued by pointers
  // (because VaPair is abstract) but events are simply copied
  // (because TaEvent is concrete)
  deque<TaEvent> fEHelDeque;    // Helicity delay event deque
  deque<TaEvent> fEDeque;       // Cut delay event deque
  deque<VaPair*> fPDeque;       // Cut delay pair deque
  TaEvent* fEvt;                // Event being analyzed
  VaPair* fPair;                // Pair being analyzed
  size_t fEHelDequeMax;         // Max size of helicity delay event deque
  size_t fEDequeMax;            // Max size of cut delay event deque
  size_t fPDequeMax;            // Max size of cut delay pair deque
  vector<AnaList> fTreeList;    // Quantities to put in the pair results and pair tree
  TTree* fPairTree;             // Pair tree for Root file
  Int_t fTreeREvNum;            // Right ev number for tree
  Int_t fTreeLEvNum;            // Left ev number for tree
  Double_t fTreeMEvNum;         // Mean ev number for tree
  Int_t fTreeOKCond;            // Pair passes cut conditions
  Int_t fTreeOKCut;             // Pair not in cut interval
  Int_t fTreePrevROHel;         // Readout helicity of prev event
  Int_t fTreePrevHel;           // True helicity of prev event
  Double_t* fTreeSpace;         // Other data for tree
  UInt_t fNCuts;                // Size of cut array
  Int_t* fCutArray;             // Array of cut values for tree
  Bool_t fOnlFlag;              // Flag whether data are online or not. 
  UInt_t fEvtProc;              // Number of events processed
  UInt_t fPairProc;             // Number of pairs processed
  EPairType fPairType;          // Type of beam helicity structure
  EventNumber_t fSliceLimit;    // Event number at end of next slice
  Bool_t fDoSlice;              // To control if slice stats are kept
  Bool_t fDoRun;                // To control if run stats are kept
  Bool_t fDoRoot;               // To control whether ROOT file is made
  Bool_t fFirstPass;            // Pass 1 or 2?

  Int_t fRunNum;                // current run number 
  
  // new feedback code 
  // array of size 4 is used for feedback type: 1 is IA,2 is PZTX,3 is PZTY, 4 is PITA.
  
  string fFdbkName[4];           // Feedback name
  string fMonitor[4];            // Current/postion Monitor name used for feedback                  
  Bool_t fSwitch[4];             // Enable compute vlaue for feedback
  Bool_t fSend[4];               // Enable send voltage value for feedback 
  UInt_t fTimeScale[4];          // Timescale of feedback
  UInt_t fMonitorKey[4];      // Current/position Monitor key   
  UInt_t fNPair[4];              // Number of pair for type i feedback  
  Int_t  fStartPair[4];          // Feedback pair start 
  Int_t  fStopPair[4];           // IA feedback pair stop
  Int_t  fFeedNum[4];            // feedback number
  vector<Double_t> fSum[4];      // Sum of value for feedback i 
  Double_t fMean1[4];            // Feedback Mean value 1st pass  
  Double_t fMean2[4];            // Feedback Mean value 2st pass  
  Double_t fRMS[4];              // Feedback RMS
  Double_t fResult[4];           // (asy or diff) result for feedback i  
  Double_t fResultError[4];      // (asy or diff) result error for feedback i 
  Double_t fIAslope;             // IA feedback calibration slope
  Double_t fPITAslope;           // PITA feedback calibration slope
  Double_t *fPZTMatrix;          // PZT matrix
  Double_t fLast[4];              // Last value of the voltage for feeback i  



  // Define LEAKCHECK to check that new = del
  //#define LEAKCHECK
#ifdef LEAKCHECK
  void LeakCheck();
  static UInt_t fLeakNewEvt;    // count of event allocations
  static UInt_t fLeakDelEvt;    // count of event deallocations
  static UInt_t fLeakNewPair;   // count of pair allocations
  static UInt_t fLeakDelPair;   // count of pair deallocations
#endif

#ifndef NODICT
  ClassDef(VaAnalysis, 0)  // Interface class for data analysis
#endif

};

#endif
