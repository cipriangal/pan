#!/usr/bin/perl -w

# Script to generate DevTypes.hh
# R. Holmes Aug 2002
#
# Inputs: none
# Output to stdout.
#
# To add a new device of an existing type to DevTypes.hh, add its
# (unique) name to the appropriate list (or, for a new ADC or scaler,
# increase $adcnum or $scanum). 
#
# To add a new type of device, add a list of device names and a sub
# do_<whatever> modelled on do_striplines, do_bcms, etc., and call it
# along with the rest of the do_<whatever> subroutines below.
#
# Note that in either case you must still make appropriate changes to
# e.g. TaDevice.cc in addition.

# Hall A stripline BPMs
@halla_strlist = qw / IBPM8 IBPM10 IBPM12 IBPM1 IBPM4A IBPM4B/;
# Injector stripline BPMs
@inj_strlist =   qw / IBPM1I02 IBPM1I04 IBPM1I06 IBPM0I02 IBPM0I02A IBPM0I05 IBPM0L01 IBPM0L02 IBPM0L03 IBPM0L04 IBPM0L05 IBPM0L06 /;  
# Cavity BPMs
@cavlist =       qw / IBPMCAV1 IBPMCAV2 IBPMCAV3 IBPMCAV4 /;
# Old (HAPPEX-I era) current monitors
@old_bcmlist =   qw / IBCM1 IBCM2 IBCM3 IBCM4 IBCM5 IBCM6 /;
# G0 current monitors
@g0_bcmlist =    qw / IBCMCAV1 IBCMCAV2 IBCMCAV3 IBCMCAV4 /;
# UMass profile scanner
@prof_list =    qw / IRPROF IRPROFX IRPROFY IRPROFV1 IRPROFV2 IRPROFV3 ILPROF ILPROFX ILPROFY ILPROFV1 ILPROFV2 ILPROFV3 /;
# Batteries
@battlist =      qw / IBATT1 IBATT2 IBATT3 IBATT4 IBATT5 IBATT6 IBATT7 IBATT8/;
# Detectors
@detlist =       qw / IDET1 IDET2 IDET3 IDET4 /;
# Lumi detectors
@lumilist =      qw / IBLUMI1 IBLUMI2 IBLUMI3 IBLUMI4 IBLUMI5 IBLUMI6 IBLUMI7 IBLUMI8 IFLUMI1 IFLUMI2 IFLUMI3 ILUMI1 ILUMI2 ILUMI3 ILUMI4/;
# V2F clocks
@v2fclocklist =  qw / IV2F_CLK0 IV2F_CLK1 IV2F_CLK2 IV2F_CLK3 IV2F_CLK4 IV2F_CLK5 IV2F_CLK6 /;
# quad photodiode
@qpdlist = qw / IQPD1 /;
# Q2 scanner
@scanlist = qw / ISCANL ISCANR /;
# BMW words
@bmwlist = qw / IBMWCLN IBMWOBJ IBMWVAL IBMWCYC /;
# scanflags
@scanflist = qw / ISCANCLEAN ISCANDATA1 ISCANDATA2 ISCANDATA3 ISCANDATA4 /;
# SYNC words
@synclist = qw / IISYNC0 ICHSYNC0 ICHSYNC1 ICHSYNC2 IRSYNC1 IRSYNC2 ILSYNC1 ILSYNC2 /;
# Number of ADC modules, scaler modules, and crates
$adcnum = 31;
$scanum = 7;
$ncrates = 4;

$p = 1;      # next value to be assigned
$out = "";   # output being built

&do_striplines();
&do_cavities();
&do_bcms();
&do_profile();
&do_batts();
&do_dets();
&do_adcs();
&do_scalers();
&do_tirs();
&do_daqflag();
&do_timeboards();
&do_lumis();
&do_v2fclocks();
&do_qpds();
&do_scans();
&do_bmwwords();
&do_scanflags();
&do_syncwords();

print << "END";
//////////////////////////////////////////////////////////////////////////
//
//  NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
//  Note: This header file is generated by the script genDevTypes.pl .
//  Do not edit it; make changes to the script instead.
//  NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
//
//////////////////////////////////////////////////////////////////////////
//
//     HALL A C++/ROOT Parity Analyzer  Pan           
//
//           DevTypes.hh  (definition file)
//           ^^^^^^^^^^^
//
//    Authors :  R. Holmes, A. Vacheret, R. Michaels
//
//  Defines arbitrary integer "keys" used to access data (both raw 
//  and calibrated) from fData array in TaEvent class.   
//  The keys have easy-to-remember names.  
//  Restrictions: 
//    1. the keys must be unique.
//    2. MAXKEYS must be > largest key.
//    3. ordering of keys affects TaEvent::Decode().
//
//////////////////////////////////////////////////////////////////////////
 
\#define   MAXKEYS        $p
\#define   ADCREADOUT     1
\#define   SCALREADOUT    2
\#define   SCALREADOUT    2
\#define   TBDREADOUT     3
\#define   TIRREADOUT     4
\#define   DAQFLAG        5

// Keys for getting data from devices.
// They keys are mapped to devices automatically.
// Use these keys for  TaEvent::GetData(Int_t key)

END

print $out;

sub do_striplines
{
# Stripline BPMs

    $stroff = $p;
    $strnum = scalar (@halla_strlist) + scalar (@inj_strlist);
    $out1 = "// Hall A striplines\n";
    foreach $str (@halla_strlist)
    {
	$out1 .= &add_str ($str);
    }
    $out1 .= "// Injector striplines\n";
    foreach $str (@inj_strlist)
    {
	$out1 .= &add_str ($str);
    }
    
    $out .= << "ENDSTRCOM";
// Stripline BPMs

\#define   STROFF     $stroff     // Stripline BPMs start here
\#define   STRNUM     $strnum     // number of striplines defined below

// XP, XM, YP, YM = antennas; X, Y = calibrated position;
// XWS, YWS, WS = X, Y, and total wiresum

$out1
ENDSTRCOM

    $strcorroff = $p;
    $out1 = "// Hall A stripline wires (before pedestal subtraction)\n";
    foreach $str (@halla_strlist)
    {
	$out1 .= &add_strcorr ($str);
    }
    $out1 .= "// Injector stripline wires (before pedestal subtraction)\n";
    foreach $str (@inj_strlist)
    {
	$out1 .= &add_strcorr ($str);
    }
    
    $out .= << "ENDSTRCORRCOM";
// Stripline wires before pedestal subtraction

\#define   STRCORROFF     $strcorroff     // Corrected Stripline wires

// XPC, XMC, YPC, YMC = corrected antennas (before pedestal subtraction);

$out1
ENDSTRCORRCOM

}

sub add_str
{
    my ($str) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${str}XP    $p\n"; $p++;
    $ret .= "\#define   ${str}XM    $p\n"; $p++;
    $ret .= "\#define   ${str}YP    $p\n"; $p++;
    $ret .= "\#define   ${str}YM    $p\n"; $p++;
    $ret .= "\#define   ${str}X     $p\n"; $p++;
    $ret .= "\#define   ${str}Y     $p\n"; $p++;
    $ret .= "\#define   ${str}XWS   $p\n"; $p++;
    $ret .= "\#define   ${str}YWS   $p\n"; $p++;
    $ret .= "\#define   ${str}WS    $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub add_strcorr
{
# Stripline wires.. after dacnoise subtraction or clock division
    my ($str) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${str}XPC    $p\n"; $p++;
    $ret .= "\#define   ${str}XMC    $p\n"; $p++;
    $ret .= "\#define   ${str}YPC    $p\n"; $p++;
    $ret .= "\#define   ${str}YMC    $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub do_cavities
{
# Cavity BPMs

    $cavoff = $p;
    $cavnum = scalar (@cavlist);
    $out1 = "";
    foreach $cav (@cavlist)
    {
	$out1 .= &add_cav ($cav);
    }
    
    $out .= << "ENDCAVCOM";
// Cavity BPMs
\#define   CAVOFF     $cavoff     // Cavity BPMs start here
\#define   CAVNUM     $cavnum     // number of cavities defined below

// XR, YR = raw data; X, Y = calibrated position

$out1
ENDCAVCOM

    $cavcorroff = $p;
    $out1 = "";
    foreach $cavcorr (@cavlist)
    {
	$out1 .= &add_cavcorr ($cavcorr);
    }
    
    $out .= << "ENDCAVCORRCOM";
// Cavity BPMs (before pedestal subtraction)
\#define   CAVCORROFF     $cavcorroff     // Cavity BPMs (before peds)

// XC, YC = data before pedestal subtraction

$out1
ENDCAVCORRCOM

}

sub add_cav
{
    my ($cav) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${cav}XR    $p\n"; $p++;
    $ret .= "\#define   ${cav}YR    $p\n"; $p++;
    $ret .= "\#define   ${cav}X     $p\n"; $p++;
    $ret .= "\#define   ${cav}Y     $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub add_cavcorr
{
    my ($cav) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${cav}XC    $p\n"; $p++;
    $ret .= "\#define   ${cav}YC    $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub do_profile
{
# UMass profile scanner

    $profoff = $p;
    $profnum = scalar (@prof_list);
    $out1 = "";
    foreach $prof (@prof_list)
    {
	$out1 .= &add_profile ($prof);
    }
    
    $out .= << "ENDPROFCOM";
// UMass Profile Scanner
\#define   PROFOFF     $profoff     // UMass profile scanner start here
\#define   PROFNUM     $profnum     // num. prof. devices defined below

// "PROFX", "PROFY" = positions, "PROF" = amplitude.
// "PROFV1" "V2" "V3" = control voltage levels.
// Prefix "IR","IL" = right, left spectrometer.
// Suffix "R" = raw data.
// Suffix "C" = corrected but no pedestal subtraction.
// No suffix = fully corrected data.

$out1
ENDPROFCOM
}

sub add_profile
{
    my ($prof) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${prof}R    $p\n"; $p++;
    $ret .= "\#define   ${prof}C    $p\n"; $p++;
    $ret .= "\#define   ${prof}    $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}


sub do_bcms
{
# BCMs

    $bcmoff = $p;
    $bcmnum = scalar (@old_bcmlist);
    $out1 = "";
    foreach $bcm (@old_bcmlist)
    {
	$out1 .= &add_bcm ($bcm);
    }
    $out .= << "ENDBCMCOM";
// Old (HAPPEX-I era) BCMs

\#define   BCMOFF     $bcmoff     // Old BCMs start here
\#define   BCMNUM     $bcmnum     // number of old BCMs defined below

// R = raw data; "" = calibrated data

$out1
ENDBCMCOM

    $bcmcorroff = $p;
    $out1 = "";
    foreach $bcm (@old_bcmlist)
    {
	$out1 .= &add_bcmcorr ($bcm);
    }
    $out .= << "ENDBCMCORRCOM";
// Old (HAPPEX-I era) BCMs (before pedestal subtraction)

\#define   BCMCORROFF     $bcmcorroff     // Old BCMs start here

// C = data before pedestal subtraction

$out1
ENDBCMCORRCOM

    $ccmoff = $p;
    $ccmnum = scalar (@g0_bcmlist);
    $out1 = "";
    foreach $bcm (@g0_bcmlist)
    {
	$out1 .= &add_bcm ($bcm);
    }
    
    $out .= << "ENDCCMCOM";
// G0 BCMs

\#define   CCMOFF     $ccmoff     // G0 BCMs start here
\#define   CCMNUM     $ccmnum     // number of G0 BCMs defined below

// R = raw data; "" = calibrated data

$out1
ENDCCMCOM

    $ccmcorroff = $p;
    $out1 = "";
    foreach $bcm (@g0_bcmlist)
    {
	$out1 .= &add_bcmcorr ($bcm);
    }
    
    $out .= << "ENDCCMCORRCOM";
// G0 BCMs (before pedestal subtraction)

\#define   CCMCORROFF     $ccmcorroff     // G0 BCMs (before peds)

// C = data before pedestal subtraction

$out1
ENDCCMCORRCOM
}

sub add_bcm
{
    my ($bcm) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${bcm}R     $p\n"; $p++;
    $ret .= "\#define   ${bcm}      $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub add_bcmcorr
{
    my ($bcm) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${bcm}C     $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub do_batts
{
# Batteries

    $batoff = $p;
    $batnum = scalar (@battlist);
    $out1 = "";
    foreach $batt (@battlist)
    {
	$out1 .= &add_batt ($batt);
    }
    $out .= << "ENDBATTCOM";
// Batteries

\#define   BATOFF     $batoff     // Batteries start here
\#define   BATNUM     $batnum     // number of batteries defined below

$out1
ENDBATTCOM
}

sub add_batt
{
    my ($batt) = @_;
    my ($ret);
    $ret = "\#define   ${batt}      $p\n"; $p++;
    return $ret;
}

sub do_dets
{
# Detectors

    $detoff = $p;
    $detnum = scalar (@detlist);
    $out1 = "";
    foreach $det (@detlist)
    {
	$out1 .= &add_det ($det);
    }
    $out .= << "ENDDETCOM";
// Detectors

\#define   DETOFF     $detoff     // Detectorss start here
\#define   DETNUM     $detnum     // number of detectors defined below

// R = raw data; "" = calibrated data

$out1
ENDDETCOM

    $detcorroff = $p;
    $out1 = "";
    foreach $det (@detlist)
    {
	$out1 .= &add_detcorr ($det);
    }
    $out .= << "ENDDETCORRCOM";
// Detectors (before pedestal subtraction)

\#define   DETCORROFF     $detcorroff     // Detectors (before peds)

// C = data before pedestal subtraction

$out1
ENDDETCORRCOM
}

sub add_det
{
    my ($det) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${det}R     $p\n"; $p++;
    $ret .= "\#define   ${det}      $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub add_detcorr
{
    my ($det) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${det}C     $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub do_adcs
{
# ADCs

    $adcoff = $p;
    $out1 = "";
    for $iadc (0..$adcnum-1)
    {
	$adc = "IADC$iadc";
	$out1 .= &add_adc ($adc);
    }
    $out .= << "ENDADCCOM";
// ADC data.  Data are arranged in sequence starting with ADC0_0
// First index is the adc#, second is channel#.  Indices start at 0
// ADC# 0 - 9 are in first crate, 10 in next crate, etc.  

// First the raw data

\#define   ADCOFF     $adcoff     // Raw ADCs start here
\#define   ADCNUM     $adcnum     // number of ADCs defined below

$out1
ENDADCCOM

    $adcdacsuboff = $p;
    $out1 = "";
    for $iadcdacsub (0..$adcnum-1)
    {
	$adcdacsub = "IADC$iadcdacsub";
	$out1 .= &add_adcdacsub ($adcdacsub);
    }
    $out .= << "ENDADCDACSUBCOM";
// Now the dacnoise subtracted data

\#define   ADCDACSUBOFF     $adcdacsuboff     // Dacnoise Subtracted ADCs start here

$out1
ENDADCDACSUBCOM

    $accoff = $p;
    $out1 = "";
    for $iacc (0..$adcnum-1)
    {
	$acc = "IADC$iacc";
	$out1 .= &add_adccal ($acc);
    }
    $out .= << "ENDACCCOM";
// Now the calibrated data

\#define   ACCOFF     $accoff     // Calibrated ADCs start here

$out1
ENDACCCOM

    $dacoff = $p;
    $dacnum = $adcnum;
    $out1 = "";
    for $idac (0..$dacnum-1)
    {
	$dac = "IDAC$idac";
	$out1 .= &add_daccsr ($dac);
    }
    $out .= << "ENDDACCOM";
// DAC noise.

\#define   DACOFF     $dacoff     // DACs start here
\#define   DACNUM     $dacnum     // number of DACs defined below

$out1
ENDDACCOM

    $csroff = $p;
    $csrnum = $adcnum;
    $out1 = "";
    for $icsr (0..$csrnum-1)
    {
	$csr = "ICSR$icsr";
	$out1 .= &add_daccsr ($csr);
    }
    $out .= << "ENDCSRCOM";
// CSRs

\#define   CSROFF     $csroff     // CSRs start here
\#define   CSRNUM     $csrnum     // number of CSRs defined below

$out1
ENDCSRCOM
}

sub add_adc
{
    my ($adc) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${adc}_0     $p\n"; $p++;
    $ret .= "\#define   ${adc}_1     $p\n"; $p++;
    $ret .= "\#define   ${adc}_2     $p\n"; $p++;
    $ret .= "\#define   ${adc}_3     $p\n"; $p++;
    return $ret;
}

sub add_adcdacsub
{
    my ($adc) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${adc}_0_DACSUB    $p\n"; $p++;
    $ret .= "\#define   ${adc}_1_DACSUB    $p\n"; $p++;
    $ret .= "\#define   ${adc}_2_DACSUB    $p\n"; $p++;
    $ret .= "\#define   ${adc}_3_DACSUB    $p\n"; $p++;
    return $ret;
}

sub add_adccal
{
    my ($adc) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${adc}_0_CAL     $p\n"; $p++;
    $ret .= "\#define   ${adc}_1_CAL     $p\n"; $p++;
    $ret .= "\#define   ${adc}_2_CAL     $p\n"; $p++;
    $ret .= "\#define   ${adc}_3_CAL     $p\n"; $p++;
    return $ret;
}

sub add_daccsr
{
    my ($adc) = @_;
    my ($ret);
    $ret = "\#define   ${adc}      $p\n"; $p++;
    return $ret;
}

sub do_scalers
{
# Scalers

    $scaoff = $p;
    $out1 = "";
    for $iscaler (0..$scanum-1)
    {
	$scaler = "ISCALER$iscaler";
	$out1 .= &add_scaler ($scaler);
    }
    $out .= << "ENDSCALERCOM";
// Raw scalers

\#define   SCAOFF     $scaoff     // Raw SCALERs start here
\#define   SCANUM     $scanum     // number of SCALERs defined below

$out1
ENDSCALERCOM

    $scaclkdivoff = $p;
    $out1 = "";
    for $iscaclkdiv (0..$scanum-1)
    {
	$sclkdiv = "ISCALER$iscaclkdiv";
	$out1 .= &add_scalerclkdiv ($sclkdiv);
    }
    $out .= << "ENDSCACLKDIVCOM";
// Clock Divided scalers (before pedestal subtraction)

\#define   SCACLKDIVOFF     $scaclkdivoff     // Clock Divided SCALERs start here

$out1
ENDSCACLKDIVCOM

    $sccoff = $p;
    $out1 = "";
    for $iscc (0..$scanum-1)
    {
	$scc = "ISCALER$iscc";
	$out1 .= &add_scalercal ($scc);
    }
    $out .= << "ENDSCCCOM";
// Calibrated scalers

\#define   SCCOFF     $sccoff     // Calibrated SCALERs start here

$out1
ENDSCCCOM
}

sub add_scaler
{
    my ($scaler) = @_;
    my ($ret);
    $ret = "";
    for $i (0..31)
    {
	$ret .= "\#define   ${scaler}_$i     $p\n"; $p++;
    }
    $ret .= "\n";
    return $ret;
}

sub add_scalerclkdiv
{
    my ($scaler) = @_;
    my ($clkdiv) = "_CLKDIV";
    my ($ret);
    $ret = "";
    for $i (0..31)
    {
	$ret .= "\#define   ${scaler}_$i${clkdiv}     $p\n"; $p++;
    }
    $ret .= "\n";
    return $ret;
}

sub add_scalercal
{
    my ($scaler) = @_;
    my ($cal) = "_CAL";
    my ($ret);
    $ret = "";
    for $i (0..31)
    {
	$ret .= "\#define   ${scaler}_$i${cal}     $p\n"; $p++;
    }
    $ret .= "\n";
    return $ret;
}

sub do_tirs
{
# TIRs

    $tiroff = $p;
    $out1 = &add_tir ("ITIRDATA");
    $out .= << "ENDTIRCOM";
// TIR data from various crates

\#define   TIROFF     $tiroff     // TIRs start here
\#define   TIRNUM     $ncrates     // number of TIRs defined below

$out1
ENDTIRCOM

    $heloff = $p;
    $out1 = &add_tir ("IHELICITY");
    $out .= << "ENDHELCOM";
// Helicity info from various crates

\#define   HELOFF     $heloff     // Helicities start here
\#define   HELNUM     $ncrates     // number of HELs defined below

$out1
ENDHELCOM

    $timoff = $p;
    $out1 = &add_tir ("ITIMESLOT");
    $out .= << "ENDTIMCOM";
// Timeslot info from various crates

\#define   TIMOFF     $timoff     // Timeslots start here
\#define   TIMNUM     $ncrates     // number of timeslots defined below

$out1
ENDTIMCOM

    $paroff = $p;
    $out1 = &add_tir ("IPAIRSYNCH");
    $out .= << "ENDPARCOM";
// Pairsynch info from various crates

\#define   PAROFF     $paroff     // Pairsynchs start here
\#define   PARNUM     $ncrates     // number of pairsynchs defined below

$out1
ENDPARCOM
    $qudoff = $p;
    $out1 = &add_tir ("IQUADSYNCH");
    $out .= << "ENDQUDCOM";
// Quadsynch info from various crates

\#define   QUDOFF     $qudoff     // Quadsynchs start here
\#define   QUDNUM     $ncrates     // number of quadsynchs defined below

$out1
ENDQUDCOM
}


sub do_daqflag
{
# DAQ flags

    $daqoff = $p;
    $out1 = "";
    $out1 .= &add_tir ("IDAQ1FLAG");
    $out1 .= "\n";
    $out1 .= &add_tir ("IDAQ2FLAG");
    $out1 .= "\n";
    $out1 .= &add_tir ("IDAQ3FLAG");
    $out1 .= "\n";
    $out1 .= &add_tir ("IDAQ4FLAG");

    $out .= << "ENDDAQCOM";
// DAQ Flag data from various crates
// (note: BMW data only comes from one crate)

\#define   DAQOFF     $daqoff     // DAQ flags start here
\#define   DAQNUM     $ncrates    // number of DAQ flags defined below

$out1
ENDDAQCOM
}


sub do_timeboards
{
# Timeboards

    $tbdoff = $p;
    $out1 = "";
    $out1 .= &add_tir ("ITIMEBOARD");
    $out1 .= "\n";
    $out1 .= &add_tir ("IRAMPDELAY");
    $out1 .= "\n";
    $out1 .= &add_tir ("IINTEGTIME");
    $out1 .= "\n";
    $out1 .= &add_tir ("IOVERSAMPLE");
    $out1 .= "\n";
    $out1 .= &add_tir ("IPRECDAC");
    $out1 .= "\n";
    $out1 .= &add_tir ("IPITADAC");

    $out .= << "ENDTBDCOM";
// Timeboard data from various crates

\#define   TBDOFF     $tbdoff     // Timeboards start here
\#define   TBDNUM     $ncrates     // number of timeboards defined below

$out1
ENDTBDCOM
}

sub add_tir
{
    my ($tir) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${tir}        $p\n"; $p++;
    $ret .= "\#define   ${tir}1       $p\n"; $p++;
    $ret .= "\#define   ${tir}2       $p\n"; $p++;
    $ret .= "\#define   ${tir}3       $p\n"; $p++;
    return $ret;
}

sub add_pitadac
{
    my ($pita) = @_;
    my ($ret);
    $ret = "\#define   ${pita}        $p\n"; $p++;
    return $ret;
}

sub do_lumis
{
# Lumi detectors

    $lmioff = $p;
    $lminum = scalar (@lumilist);
    $out1 = "";
    foreach $lumi (@lumilist)
    {
	$out1 .= &add_lumi ($lumi);
    }
    $out .= << "ENDLUMICOM";
// Lumi detectors

\#define   LMIOFF     $lmioff     // Lumis start here
\#define   LMINUM     $lminum     // number of lumis defined below

// R = raw data; "" = calibrated data

$out1
ENDLUMICOM

    $lmicorroff = $p;
    $out1 = "";
    foreach $lumi (@lumilist)
    {
	$out1 .= &add_lumicorr ($lumi);
    }
    $out .= << "ENDLUMICORRCOM";
// Lumi detectors (before pedestal subtraction)

\#define   LMICORROFF     $lmicorroff     // Lumis (before peds)

// C = data before pedestal subtraction

$out1
ENDLUMICORRCOM
}

sub add_lumi
{
    my ($lumi) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${lumi}R     $p\n"; $p++;
    $ret .= "\#define   ${lumi}      $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub add_lumicorr
{
    my ($lumi) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${lumi}C     $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub do_v2fclocks
{
# V2F Clocks

    $v2fclkoff = $p;
    $v2fclknum = scalar (@v2fclocklist);
    $out1 = "";
    foreach $v2fclock (@v2fclocklist)
    {
	$out1 .= &add_v2fclock ($v2fclock);
    }
    $out .= << "ENDV2FCLOCKCOM";
// V2f_Clocks

\#define   V2FCLKOFF     $v2fclkoff     // V2F clocks start here
\#define   V2FCLKNUM     $v2fclknum     // number of V2F clocks defined below

$out1
ENDV2FCLOCKCOM
}

sub add_v2fclock
{
    my ($v2fclock) = @_;
    my ($ret);
    $ret = "\#define   ${v2fclock}      $p\n"; $p++;
    return $ret;
}


sub do_qpds
{
# Quad photodiodes

    $qpdoff = $p;
    $qpdnum = scalar (@qpdlist);
    $out1 = "";
    foreach $qpd (@qpdlist)
    {
	$out1 .= &add_qpd ($qpd);
    }
    
    $out .= << "ENDQPDCOM";
// Quad photodiodes

\#define   QPDOFF     $qpdoff     // Quad photodiodes start here
\#define   QPDNUM     $qpdnum     // number of quad photodiodes defined below

// PP, PM, MP, MM = diodes (x side, y side); X, Y = calibrated position;
// SUM = X, Y, and total diode sum

$out1
ENDQPDCOM

    $qpdcorroff = $p;
    $out1 = "";
    foreach $qpd (@qpdlist)
    {
	$out1 .= &add_qpdcorr ($qpd);
    }
    
    $out .= << "ENDQPDCORRCOM";
// Quad photodiodes (before pedestal subtraction)

\#define   QPDCORROFF     $qpdcorroff     // Quad photodiodes (before peds)

// PPC, PMC, MPC, MMC = diodes (x side, y side) before pedestal subtraction

$out1
ENDQPDCORRCOM
}

sub add_qpd
{
    my ($qpd) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${qpd}PP   $p\n"; $p++;
    $ret .= "\#define   ${qpd}PM   $p\n"; $p++;
    $ret .= "\#define   ${qpd}MP   $p\n"; $p++;
    $ret .= "\#define   ${qpd}MM   $p\n"; $p++;
    $ret .= "\#define   ${qpd}X    $p\n"; $p++;
    $ret .= "\#define   ${qpd}Y    $p\n"; $p++;
    $ret .= "\#define   ${qpd}SUM  $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub add_qpdcorr
{
    my ($qpd) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${qpd}PPC   $p\n"; $p++;
    $ret .= "\#define   ${qpd}PMC   $p\n"; $p++;
    $ret .= "\#define   ${qpd}MPC   $p\n"; $p++;
    $ret .= "\#define   ${qpd}MMC   $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}


sub do_scans
{
# Q2 scanners

    $scanoff = $p;
    $scannum = scalar (@scanlist);
    $out1 = "";
    foreach $scan (@scanlist)
    {
	$out1 .= &add_scan ($scan);
    }
    
    $out .= << "ENDSCANCOM";
// Q2 Scanners

\#define   SCANOFF     $scanoff     // Q2 scanners start here
\#define   SCANNUM     $scannum     // number of Q2 scanners defined below

// XENC, YENC = raw encoder values,  X, Y = calibrated encoder values  
// DET = integrated PMT signal

$out1
ENDSCANCOM

    $scancorroff = $p;
    $out1 = "";
    foreach $scan (@scanlist)
    {
	$out1 .= &add_scancorr ($scan);
    }
    
    $out .= << "ENDSCANCORRCOM";
// Q2 Scanners (before pedestal subtraction)

\#define   SCANCORROFF     $scancorroff     // Q2 scanners (before peds)

// XENCC, YENCC = encoder values before pedestal subtraction
// DETC = integrated PMT signal before pedestal subtraction

$out1
ENDSCANCORRCOM
}

sub add_scan
{
    my ($scan) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${scan}XENC   $p\n"; $p++;
    $ret .= "\#define   ${scan}YENC   $p\n"; $p++;
    $ret .= "\#define   ${scan}X      $p\n"; $p++;
    $ret .= "\#define   ${scan}Y      $p\n"; $p++;
    $ret .= "\#define   ${scan}DET    $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}

sub add_scancorr
{
    my ($scan) = @_;
    my ($ret);
    $ret = "";
    $ret .= "\#define   ${scan}XENCC   $p\n"; $p++;
    $ret .= "\#define   ${scan}YENCC   $p\n"; $p++;
    $ret .= "\#define   ${scan}DETC    $p\n"; $p++;
    $ret .= "\n";
    return $ret;
}


sub do_bmwwords
{
# Beam modulation information

    $bmwoff = $p;
    $bmwnum = scalar (@bmwlist);
    $out1 = "";
    foreach $bmwword (@bmwlist)
    {
	$out1 .= &add_bmwword ($bmwword);
    }
    $out .= << "ENDBMWWORDCOM";
// bmw words

\#define   BMWOFF     $bmwoff     // bmw words start here
\#define   BMWNUM     $bmwnum     // number of bmw words defined below

$out1
ENDBMWWORDCOM
}

sub add_bmwword
{
    my ($bmwword) = @_;
    my ($ret);
    $ret = "\#define   ${bmwword}      $p\n"; $p++;
    return $ret;
}

sub do_scanflags
{
# Scan flags

    $scanfloff = $p;
    $scanflnum = scalar (@scanflist);
    $out1 = "";
    foreach $scanfl (@scanflist)
    {
	$out1 .= &add_scanflag ($scanfl);
    }
    $out .= << "ENDSCANFLCOM";
// scan flags

\#define   SCANFLAGOFF     $scanfloff     // scanflags start here
\#define   SCANFLAGNUM     $scanflnum     // number of scanflags defined below

$out1
ENDSCANFLCOM
}

sub add_scanflag
{
    my ($scanfl) = @_;
    my ($ret);
    $ret = "\#define   ${scanfl}      $p\n"; $p++;
    return $ret;
}

sub do_syncwords
{
# Beam modulation information

    $syncoff = $p;
    $syncnum = scalar (@synclist);
    $out1 = "";
    foreach $syncword (@synclist)
    {
	$out1 .= &add_syncword ($syncword);
    }
    $out .= << "ENDSYNCWORDCOM";
// sync words

\#define   SYNCOFF     $syncoff     // sync words start here
\#define   SYNCNUM     $syncnum     // number of sync words defined below

$out1
ENDSYNCWORDCOM
}

sub add_syncword
{
    my ($syncword) = @_;
    my ($ret);
    $ret = "\#define   ${syncword}      $p\n"; $p++;
    return $ret;
}

