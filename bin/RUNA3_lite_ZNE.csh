#!/bin/csh -f
#
# W phase package - RUNA3_lite for Z, N, E components
#
# Zacharie Duputel, Luis Rivera and Hiroo Kanamori
#

source $WPHASE_HOME/bin/WP_HEADER.CSH
##################################

set my_argv = ($ARGV)
if ($#my_argv < 1) then
    set wZ = 1.
    set wN = 1.
    set wE = 1.
else
    set wZ = $my_argv[1]
    set wN = $my_argv[2]
    set wE = $my_argv[3]
else
    $ECHO "*** ERROR ($0) ***"
    $ECHO "Syntax: $0 [wZ wN wE]"
    exit
endif

set BIN     = $WPHASE_HOME/bin
set EXTRACT = ${BIN}/extract_lite.csh
set CALC    = ${BIN}/calc_fast_synths_ZNE.csh
set PREPARE = ${BIN}/prepare_wp_ZNE.csh
set WPINVER = ${BIN}/wpinversion_ZNE


${RM} -rf SYNTH
${MKDIR} SYNTH

$EXTRACT
$CALC
$PREPARE

if (-e i_master) then
        ${GREP} -v "^#" i_master >! i_tmp
else
        ${ECHO} "Error: file  i_master not available"
        exit
endif
set gf_dir   = "./GF"
set tmp      = `${GREP} GFDIR   i_tmp`
if ! $status then
        set gf_dir   = `$ECHO $tmp | ${HEAD} -1 | ${CUT} -d: -f2`
endif
${RM} -f i_tmp

$WPINVER -log LOG/wpinversion.noth.log -osyndir SYNTH -gfdir ${gf_dir} \
	-wn ${wN} -we ${wE} -wz ${wZ} -med

${CP} -f p_wpinversion p_wpinversion.noth
${CP} -f o_wpinversion o_wpinversion.noth
${CP} -f WCMTSOLUTION WCMTSOLUTION.noth

${CP} -f o_wpinversion o_wpinv
set ths =  "5.0 3.0 0.9"


foreach th ($ths)

    $WPINVER  -th ${th} -ifil o_wpinversion -ofil o_wpinv.th_${th} \
    -log LOG/wpinversion.th_${th}.log -ps p_wpinversion.th_${th} \
    -osyndir SYNTH -ocmtf  WCMTSOLUTION.th_${th} -gfdir ${gf_dir}\
    -wn ${wN} -we ${wE} -wz ${wZ} -old 
    ${CP} -f o_wpinv.th_$th o_wpinversion        
    set NBSTA = `${CAT} o_wpinversion | ${WC}  -l`
    if ( $NBSTA < 25 ) then
 	${ECHO} "${NBSTA} stations : stop for th=${th}"
 	break
    endif
end

${CP} -f WCMTSOLUTION.th_${th} WCMTSOLUTION
${CP} -f p_wpinversion.th_${th} p_wpinversion
${CP} LOG/wpinversion.th_${th}.log LOG/wpinversion.log

