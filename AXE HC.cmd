
@@*** Script for ACTIVE AP node or for 5001 port in MML mode ***@@

! R6 file !

@@*** get NE name and date of execution ***@@
@CLEAR

@@ where connected to @@
@RELEASE
@CONNECT
call tmp
@FIND {_aploc} {_lines} ".*'tmp' is not recognized.*"
@FIND {_mml} {_lines} ".*NOT ACCEPTED.*"
@IFDEF {_aploc} THEN COMMENT "In AP mode"
@IFDEF {_aploc} THEN GOTO _mml_init
@IFDEF {_mml} THEN COMMENT "In MML mode"
@IFDEF {_mml} THEN GOTO _skip_mml_init

@LABEL _mml_init
call mml -a
@GREP {_on_passive_node} {_lines} ".*Only allowed from active AP node.*"
@IFNDEF {_on_passive_node} THEN GOTO _skip_mml_init
echo %COMPUTERNAME%
@CONCAT {_str} "Node " {_lines[1]} " is passive, script can't procced"
@CONFIRM {_str}
@IFDEF {_on_passive_node} THEN GOTO _end_exec

@LABEL _skip_mml_init

@SET {_cmd} = "ioexp;"
{_cmd}
@copy {_line4} {exch_name} 1 6
@UPCASE {exch_name}
@TRIM {exch_name}
@GETDATE {_date} YYMMDD
@COMMENT Command {_cmd} executed

@SET {_path} = C:\Logs\{exch_name}
@TRIM {_path}
@COMMENT {_path}
@EXECWAIT cmd /c mkdir {_path}

@@@@ Check IO system type @@@@
@SET {_apg_ne} = 0
@SET {_iog_ne} = 0
@SET {_cmd} = "APAMP"
{_cmd};
@IF {_lines[10]} = "NONE" THEN SET {_iog_ne} = 1
@SET {_cmd} = "EXSLP"
{_cmd}:SPG=ALL;
@IF {_lines[2]} = "COMMAND UNKNOWN" THEN SET {_apg_ne} = 1
@IF {_lines[4]} = "END" THEN SET {_apg_ne} = 1
@IF {_iog_ne} = 1 THEN COMMENT IO system is IOG
@IF {_apg_ne} = 1 THEN COMMENT IO system is APG
@IF {_apg_ne} = {_iog_ne} THEN COMMENT both type of IO system
@COMMENT Command {_cmd} executed

@@@@ Check node type @@@@
@SET {_bsc}	= 0
@SET {_msc}	= 0
@ONRECEIVE "BSC" SET {_bsc} = 1
RRNTP;
@ONRECEIVE "BSC"
@ONRECEIVE "ROUTE DATA" SET {_msc} = 1
exrop:dety=gri;
@ONRECEIVE "ROUTE DATA"
@IF {_bsc} = 1 THEN COMMENT node is BSC/R-BSC
@IF {_msc} = 1 THEN COMMENT node is MSC/MSS/TSC/TSS/HLR
@@COMMENT BSC is {_bsc}
@@COMMENT MSC is {_msc}

@@@@ Check CP type (SAOSP) @@@@
@SET {_cmd} = "SAOSP"
{_cmd};
@GREP {_apzt}{_lines}".*APZ TYPE.*"
@GREP {_apzv}{_lines}".*APZ VERSION.*"
@ITEM {_APZ_TYPE} {_apzt} " " 3
@ITEM {_APZ_VER} {_apzv} " " 3
@CONCAT {_CP_T} "APZ "{_APZ_TYPE}" "{_APZ_VER}

@TRIM {_CP_T}
@IF {_CP_T} = "APZ 212 33" THEN GOTO compact_check
@IF {_CP_T} <> "APZ 212 33" THEN GOTO skip_compact_check
@LABEL compact_check
@GREP {_apzpn} {_lines}".*APZ PRODUCT NUMBER INDEX.*"
@ITEM {_apzpn} {_apzpn} " " 3
@TRIM {_apzpn}
@IF {_apzpn} = 102 THEN CONCAT {_CP_T} {_CP_T}"c"
@LABEL skip_compact_check

@COMMENT {_CP_T}
@@ etalon calim value
@IF {_CP_T} = "APZ 212 60"  THEN SET {_calim_val} = 50000
@IF {_CP_T} = "APZ 212 55"  THEN SET {_calim_val} = 72000
@IF {_CP_T} = "APZ 212 50"  THEN SET {_calim_val} = 50000
@IF {_CP_T} = "APZ 212 40"  THEN SET {_calim_val} = 25000
@IF {_CP_T} = "APZ 212 33"  THEN SET {_calim_val} = 15000
@IF {_CP_T} = "APZ 212 33c" THEN SET {_calim_val} = 72000
@IF {_CP_T} = "APZ 212 30"  THEN SET {_calim_val} = 48000
@IF {_CP_T} = "APZ 212 25"  THEN SET {_calim_val} = 6000
@@ etalon mau state
@IF {_CP_T} = "APZ 212 60"  THEN SET {_mau} = "NRM"
@IF {_CP_T} = "APZ 212 55"  THEN SET {_mau} = "NRM"
@IF {_CP_T} = "APZ 212 50"  THEN SET {_mau} = "NRM"
@IF {_CP_T} = "APZ 212 40"  THEN SET {_mau} = "NRM"
@IF {_CP_T} = "APZ 212 33"  THEN SET {_mau} = "NRM"
@IF {_CP_T} = "APZ 212 33c" THEN SET {_mau} = "NRM"
@IF {_CP_T} = "APZ 212 30"  THEN SET {_mau} = "NRM"
@IF {_CP_T} = "APZ 212 25"  THEN SET {_mau} = "NRM"
@@ etalon SB state
@IF {_CP_T} = "APZ 212 60"  THEN SET {_SBstate} = "WO"
@IF {_CP_T} = "APZ 212 55"  THEN SET {_SBstate} = "WO"
@IF {_CP_T} = "APZ 212 50"  THEN SET {_SBstate} = "WO"
@IF {_CP_T} = "APZ 212 40"  THEN SET {_SBstate} = "WO"
@IF {_CP_T} = "APZ 212 33"  THEN SET {_SBstate} = "WO"
@IF {_CP_T} = "APZ 212 33c" THEN SET {_SBstate} = "WO"
@IF {_CP_T} = "APZ 212 30"  THEN SET {_SBstate} = "WO"
@IF {_CP_T} = "APZ 212 25"  THEN SET {_SBstate} = "WO"

@@@@ ASK for information @@@@
@SET {_summt} = 1
@SET {_abf} = before
@SET {_sft} = 1
@SET {_bl_dt_tp} = 1
@LABEL _inputdef
@FORM CREATE "Input data for script"
@FORM TEXT "Input data for script" 1 1 30 10
@FORM TEXT "Type 1 if summer time, else - 0" 1 4 30 10
@FORM EDITTEXT {_summt} 1 7 30
@FORM TEXT "Type 1 if for software upgrade, else 0" 1 10 30 10
@FORM EDITTEXT {_sft} 1 13  30
@FORM TEXT "Type 1 if cmd TPBLI'n'DTBLI is need, else - 0 (1 - default)" 1 16 30 10
@FORM EDITTEXT {_bl_dt_tp} 1 21 30
@FORM TEXT "Enter 'before' or 'after' for log file" 1 24 30 10
@FORM EDITTEXT {_abf} 1 27 30
@FORM RUN
@IF {_summt} = 0 THEN GOTO _sft_chk
@IF {_summt} = 1 THEN GOTO _sft_chk
@GOTO _inputdef
@LABEL _sft_chk
@IF {_sft} = 0 THEN GOTO _skip_sft
@IF {_sft} = 1 THEN GOTO _skip_sft
@GOTO _inputdef
@LABEL _skip_sft 

@CONCAT {_log_file} {_path}"\"{_date}"_HealthCheck_"{_abf}"_"{exch_name} ".log"
@CONCAT {_script_log_file} {_path}"\"{_date}"_state_"{_abf}"_"{exch_name}".res"

@Log ON {_log_file}
@COMMENT CP: {_CP_T}; {_mau}, {_SBstate}
@COMMENT Command {_cmd} executed

@@@@ Check alarm list ALLIP @@@@
@SET {_cmd} = "ALLIP"
@SCRIPTLOG ON {_script_log_file}
{_cmd};
@copy {_line4} {_clear} 1 4
@UPCASE {_clear}
@TRIM {_clear}
@IF {_clear} <> "NONE" THEN GOSUB _check_alist
@COMMENT Command {_cmd} executed

@@@@ Check CP load @@@@ (to change)
@SET {_line_count} = 0
@SET {_cmd} = "PLLDP"
{_cmd};
@GREP {_pll}{_lines}".*000.*"
@CUT {_pload}{_pll} col 2
@CUT {_calim}{_pll} col 3
@SET {i} = 0
@SIZE {_pload}{_line_count}
@WHILE {i} < {_line_count}
@SET {_hi_load} = 0
@SET {_calim_deg} = 0
@IF {_pload[{i}]} => 70 THEN SET {_hi_load} = 1
@IF {_calim[{i}]} <> {_calim_val} THEN SET {_calim_deg} = 1
@IF {_hi_load} <> 0 THEN SET {i} = {_line_count}
@IF {_calim[{i}]} <> {_calim_val} THEN SET {_calim_deg} = 1
@INC {i}
@ENDWHILE
@SCRIPTLOG APPEND {_script_log_file}
@IF {_hi_load} <> 0 THEN COMMENT Hi CP load
@@IF {_hi_load} <> 0 THEN PAUSE
@IF {_calim_deg} <> 0 THEN COMMENT Call limit degraded
@@IF {_calim_deg} <> 0 THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check SB state @@@@
@SET {_cmd} = "DPWSP"
{_cmd};
@SET {_SB_st1} = 0
@SET {_mau1} = 0
@COPY {_line4} {_SB_st} 9 10
@COPY {_line4} {_mau_st} 1 5
@TRIM {_SB_st}
@TRIM {_mau_st}
@IF {_SB_st} <> {_SBstate} THEN SET {_SBstate} = "SE-FMMAN"
@IF {_SB_st} <> {_SBstate} THEN SET {_SB_st1} = 1
@IF {_mau_st} <> {_mau} THEN SET {_mau} = "AAM"
@IF {_mau_st} <> {_mau} THEN SET {_mau} = "NRAM"
@IF {_mau_st} <> {_mau} THEN SET {_mau1} = 1
@SCRIPTLOG APPEND {_script_log_file}
@IF {_SB_st1} = 1 THEN COMMENT {_SB_st}: Wrong SB state
@@IF {_SB_st1} = 1 THEN PAUSE
@IF {_mau1} = 1 THEN COMMENT {_mau_st}: Wrong MAU state
@@IF {_mau1} = 1 THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check application blocks @@@@
@SET {_cmd} = "LASIP"
{_cmd}:BLOCK=ALL;
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_lasip}{_lines} ".*PASSIVE.*|.*PXLOADED.*|.*TEST.*"
@IFDEF {_lasip} THEN COMMENT Some BLOCKS are not in ACTIVE state
@IFDEF {_lasip} THEN COMMENT ''
@IFDEF {_lasip} THEN FOREACH {_lasip} COMMENT {_lines[{_CURRLINE}]}
@@IFDEF {_lasip} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check distributed Group Switch state @@@@
@SET {_cmd} = "GDSTP"
{_cmd};
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_gdstp}{_lines} ".*BLOC.*|.*WO/S.*"
@IFDEF {_gdstp} THEN COMMENT Some units are not in WO state
@IFDEF {_gdstp} THEN FOREACH {_gdstp} COMMENT {_lines[{_CURRLINE}]}
@@IFDEF {_gdstp} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_line_count} = 0
@SET {_cmd} = "GDCVP"
{_cmd};
@SCRIPTLOG APPEND {_script_log_file} 
@FIND {_clm_0} {_lines} "^CLM-0.*"
@FIND {_clm_1} {_lines} "^CLM-1.*"
@GREP {_clm_0_notdef} {_lines[{_clm_0}]} ".*DEVICE NOT AVAILABLE.*"
@GREP {_clm_1_notdef} {_lines[{_clm_1}]} ".*DEVICE NOT AVAILABLE.*"
@IFDEF {_clm_0_notdef} THEN COMMENT For CLM-0 HARDWARE NOT AVAILABLE
@IFDEF {_clm_0_notdef} THEN GOTO _skip_clm0_osc_def
@ITEM {_clm0_osc0} {_lines[{_clm_0[0]}]} " " 2
@ITEM {_clm0_osc1} {_lines[{_clm_0[0]}+1]} " " 1
@IF {_clm0_osc0} < 27000 THEN COMMENT Low CONTRVALUE ({_clm0_osc0}) for CLM-0 OSC-0
@IF {_clm0_osc1} < 27000 THEN COMMENT Low CONTRVALUE ({_clm0_osc1}) for CLM-0 OSC-1
@IF {_clm0_osc0} > 37000 THEN COMMENT High CONTRVALUE ({_clm0_osc0}) for CLM-0 OSC-0
@IF {_clm0_osc1} > 37000 THEN COMMENT High CONTRVALUE ({_clm0_osc1}) for CLM-0 OSC-1
@LABEL _skip_clm0_osc_def
@IFDEF {_clm_1_notdef} THEN COMMENT For CLM-1 HARDWARE NOT AVAILABLE
@IFDEF {_clm_1_notdef} THEN GOTO _skip_clm1_osc_def
@ITEM {_clm1_osc0} {_lines[{_clm_1[0]}]} " " 2
@ITEM {_clm1_osc1} {_lines[{_clm_1[0]}+1]} " " 1
@IF {_clm1_osc0} < 27000 THEN COMMENT Low CONTRVALUE ({_clm1_osc0}) for CLM-1 OSC-0
@IF {_clm1_osc1} < 27000 THEN COMMENT Low CONTRVALUE ({_clm1_osc1}) for CLM-1 OSC-1
@IF {_clm1_osc0} > 37000 THEN COMMENT High CONTRVALUE ({_clm1_osc0}) for CLM-1 OSC-0
@IF {_clm1_osc1} > 37000 THEN COMMENT High CONTRVALUE ({_clm1_osc1}) for CLM-1 OSC-1
@LABEL _skip_clm1_osc_def

@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check clock-reference state @@@@
@SET {_cmd} = "NSSTP"
{_cmd};
@FIND {_ns_st}{_lines} ".*ABL.*"
@@FOREACH {_ns_st} COMMENT {_CURRLINE}
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_ns_st} THEN COMMENT Some clock reference blocked
@IFDEF {_ns_st} THEN FOREACH {_ns_st} COMMENT {_lines[{_CURRLINE}]}
@@IFDEF {_ns_st} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check Regional Processors (RP) state @@@@
@SET {_cmd} = "EXRPP"
{_cmd}:RP=ALL;
@@COMMENT {_date}_{_cmd}_{exch_name}.res
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_rp_st}{_lines} ".*RB.*|.*FB.*|.*AB.*|.*MS.*"
@IFDEF {_rp_st} THEN COMMENT Some RPs blocked
@IFDEF {_rp_st} THEN FOREACH {_rp_st} COMMENT {_lines[{_CURRLINE}]}
@@IFDEF {_rp_st} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check Extention Moudles (EM) state @@@@
@SET {_cmd} = "EXEMP"
{_cmd}:EM=ALL,RP=ALL;
@@COMMENT {_date}_{_cmd}_{exch_name}.res
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_erpst}{_lines}".*RB|.*FC|.*AB|.*CB"
@IFDEF {_erpst} THEN COMMENT Some EMs blocked
@IFDEF {_erpst} THEN FOREACH {_erpst} COMMENT {_lines[{_CURRLINE}]}
@@IFDEF {_erpst} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check SNT state @@@@
@SET {_cmd} = "NTSTP"
{_cmd}:SNT=ALL; 
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_nt_st}{_lines} ".*ABL.*|.*CBL.*|.*SBL.*"
@IFDEF {_nt_st} THEN COMMENT Some SNTs blocked
@IFDEF {_nt_st} THEN FOREACH {_nt_st} COMMENT {_lines[{_CURRLINE}]}
!@IFDEF {_nt_st} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "NTCOP"
{_cmd}:SNT=ALL; 
@COMMENT Command {_cmd} executed

@@@@ Check CCITT7 LS state @@@@
@SET {_cmd} = "C7LTP"
{_cmd}:LS=ALL; 
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_c7ltp}{_lines} ".*BPO.*|.*DEACTIVE.*|.*FAULTY.*|.*LPO.*|.*RESTORING.*|.*RPO.*"
@IFDEF {_c7ltp} THEN COMMENT Some LS not in ACTIVE state
@IFDEF {_c7ltp} THEN FOREACH {_c7ltp} COMMENT {_lines[{_CURRLINE}]}
@@IFDEF {_c7ltp} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Print CCITT7 LS data @@@@
@SET {_cmd} = "C7LDP"
{_cmd}:LS=ALL; 
@COMMENT Command {_cmd} executed

@@@@ Check semipermanent connection state @@@@
@SET {_cmd} = "EXSCP"
{_cmd}:NAME=ALL; 
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_sc_st}{_lines} ".*BLOC.*|.*DEACT.*|.*FAULT.*|.*ORD.*|.*RES.*|.*SUSP.*|.*FSUSP.*|.*RELWAIT.*"
@IFDEF {_sc_st} THEN COMMENT Some Semipermanent connections not in ACT state
@IFDEF {_sc_st} THEN FOREACH {_sc_st} COMMENT {_lines[{_CURRLINE}]}
@@IFDEF {_sc_st} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@SET {_cmd} = "DTSTP"
{_cmd}:DIP=ALL; 
@FIND {_dip_st}{_lines} ".*MBL.*"
@IFDEF {_dip_st} THEN COMMENT Some DIPs blocked
@IFNDEF {_dip_st} THEN GOTO skip_dtbli
@IF {_bl_dt_tp} = 0 THEN GOTO skip_dtbli
@SET {_filename_dip} = {_path}+\{_date}_dtbli_{exch_name}.cmd
@CUT {_dips} {_lines} COL 1
@SIZE {_dip_st} {_lines_count}
@CALC {_progress_dip} = {_lines_count} - 1
@SET {i} = 0
@WHILE {i} < {_lines_count}
@COMMENT PROGRESS for DTBLI is {i} from {_progress_dip}
@SET {_textstring} = ""
@CONCAT {_textstring} {_textstring} "DTBLI:DIP=" {_dips[{_dip_st[{i}]}]} ";"
@APPEND {_filename_dip} {_textstring}
@INC {i}
@ENDWHILE

@LABEL skip_dtbli

@SET {_cmd} = "TPSTP"
{_cmd}:SDIP=ALL;
@GREP {_tpstp} {_lines} ".*(MBL|SBL).*"
@IFDEF {_tpstp} THEN COMMENT Some SDIPs are blocked
@IFNDEF {_tpstp} THEN GOTO skip_tpbli
@IF {_bl_dt_tp} = 0 THEN GOTO skip_tpbli
@SET {_filename_sdip} = {_path}+\{_date}_tpbli_{exch_name}.cmd

@CUT {_sdip} {_tpstp} COL 1
@FIND {_etm} {_sdip} ".*ET.*"
@FIND {_vc12} {_sdip} ".*VC12-.*"

@SIZE {_sdip} {_linecount_sdip}
@SIZE {_etm} {_linecount_etm}
@CALC {_progress} = {_linecount_etm} - 1
@SIZE {_vc12} {_linecount_vc12}
@SET {_vc12_all} = "VC12-ALL"
@SET {i} = 0

@WHILE {i} < {_linecount_etm}-1
@COMMENT PROGRESS for TPBLI is {i} from {_progress}
	@SET {k} = 0
	@WHILE {k} < {_linecount_vc12}
	@UNSET {_flag}
	@SET {_flag1} = 0
	@SET {_flag2} = 0
	@SET {_flag3} = 0
	@IF {_vc12[{k}]} < {_etm[{i}]} THEN GOTO fin_int
	@IF {_vc12[{k}]} > {_etm[{i}]} THEN SET {_flag1} = 1
	@IF {_vc12[{k}]} < {_etm[{i}+1]} THEN SET {_flag2} = 1
	@IF {_sdip[{_vc12[{k}]}]} = {_vc12_all} THEN SET {_flag3} = 1
	@CONCAT {_flag} {_flag1} {_flag2} {_flag3}
	@IF {_flag} = 111 THEN GOTO sdip_blk
	@IF {_flag} = 110 THEN GOTO blk
	@IF {_flag} = 100 THEN SET {k} = {_linecount_vc12}
	@GOTO fin_int

	@LABEL blk
	@CONCAT {_textstring} "TPBLI:SDIP="{_sdip[{_etm[{i}]}]}",lp="{_sdip[{_vc12[{k}]}]}";"
	@APPEND {_filename_sdip} {_textstring}
	@GOTO fin_int

	@LABEL sdip_blk
	@CONCAT {_textstring} "TPBLI:SDIP="{_sdip[{_etm[{i}]}]}";"
	@APPEND {_filename_sdip} {_textstring}
    @GOTO fin_int

	@LABEL fin_int

	@INC {k}
	@ENDWHILE

@INC {i}
@ENDWHILE

@SET {k} = 0
@COMMENT PROGRESS for TPBLI is {i} from {_progress}
@WHILE {k} < {_linecount_vc12}
@UNSET {_flag}
@SET {_flag1} = 0
@SET {_flag2} = 0
@SET {_flag3} = 0
@IF {_vc12[{k}]} < {_etm[{i}]} THEN GOTO fin
@IF {_vc12[{k}]} > {_etm[{i}]} THEN SET {_flag1} = 1
@IF {_sdip[{_vc12[{k}]}]} = {_vc12_all} THEN SET {_flag3} = 1
@CONCAT {_flag} {_flag1} {_flag2} {_flag3}
@IF {_flag} = 101 THEN GOTO sdip_blk1
@IF {_flag} = 100 THEN GOTO blk1
@GOTO fin

@LABEL blk1
@CONCAT {_textstring} "TPBLI:SDIP="{_sdip[{_etm[{i}]}]}",lp="{_sdip[{_vc12[{k}]}]}";"
@APPEND {_filename_sdip} {_textstring}
@GOTO fin

@LABEL sdip_blk1
@CONCAT {_textstring} "TPBLI:SDIP="{_sdip[{_etm[{i}]}]}";"
@APPEND {_filename_sdip} {_textstring}
@GOTO fin

@LABEL fin

@INC {k}
@ENDWHILE

@LABEL skip_tpbli

@SET {_cmd} = "NTSTP"
{_cmd}:SNT=ALL;
@FIND {_snt_st}{_lines} ".*MBL.*"
@IFDEF {_snt_st} THEN COMMENT Some SNTs blocked
@IFNDEF {_snt_st} THEN GOTO skip_ntbli
@IF {_bl_dt_tp} = 0 THEN GOTO skip_ntbli
@SET {_filename_snt} = {_path}+\{_date}_ntbli_{exch_name}.cmd

@CUT {_snts} {_lines} COL 1
@SIZE {_snt_st} {_lines_count}
@CALC {_progress_snt} = {_lines_count} - 1
@SET {i} = 0

@WHILE {i} < {_lines_count}
@COMMENT PROGRESS for NTBLI is {i} from {_progress}
@SET {_textstring} = ""
@CONCAT {_textstring} {_textstring} "NTBLI:SNT=" {_snts[{_snt_st[{i}]}]} ";"
@APPEND {_filename_snt} {_textstring}
@INC {i}
@ENDWHILE

@LABEL skip_ntbli

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@@@@ Check Network Protection state @@@@
@SET {_cmd} = "PWNSP"
{_cmd}:SDIP=ALL;
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_pwnsp}{_lines} ".*UNPROTECTED.*|.*LOCKED BOARD.*|.*LOCKED.*"
@IFDEF {_pwnsp} THEN COMMENT Some SDIPs in UNPROTECTED mode
@@IFDEF {_pwnsp} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check IPN state for APG & CP - SPG link for IOG @@@@
@IF {_CP_T} in ["APZ 212 33","APZ 212 33c","APZ 212 30","APZ 212 25"] THEN GOSUB _IPNck

@@@@ List SAACTIONS table @@@@
@SET {_line_count} = 0
@SET {_cmd} = "DBTSP"
{_cmd}:TAB=SAACTIONS;
@SCRIPTLOG APPEND {_script_log_file}
@SIZE {_lines}{_line_count}
@IF {_line_count} > 10 THEN COMMENT Some SAE need to change
@IF {_line_count} > 10 THEN FOREACH {_lines} COMMENT {_CURRLINE}
@@IF {_line_count} > 10 THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ List CP events @@@@
@SET {_cmd} = "DIRCP"
{_cmd};
@COMMENT Command {_cmd} executed
@COMMENT Check {_cmd} printout
@T 10

@@@@ List RP events @@@@
@SET {_cmd} = "DIRRP"
{_cmd}:RP=ALL;
@COMMENT Command {_cmd} executed
@COMMENT Check {_cmd} printout
@T 5

@@@@ List recovery events @@@@
@SET {_cmd} = "SYRIP"
{_cmd}:SURVEY;
@COMMENT Command {_cmd} executed
@COMMENT Check {_cmd} printout
@T 5

@@@@ Check Error intensity @@@@
@SET {_cmd} = "SYELP"
{_cmd};
@GREP {_curint}{_lines}".*CURRENT ERROR INTENSITY.*"
@CUT {_int}{_curint} col 4
@TRIM {_int}
@SCRIPTLOG APPEND {_script_log_file}
@IF {_int} > 0 THEN COMMENT Current error intensity is {_int}
@@IF {_int} > 0 THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check for pending restarts @@@@
@SET {_cmd} = "SYRTP"
{_cmd};
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_syrtp}{_lines}".*NO RESTART IS PENDING.*"
@@IFDEF {_syrtp} THEN COMMENT {_lines[{_curint}]}
@IFNDEF {_syrtp} THEN COMMENT TIME & TYPE of pending restart is
@IFNDEF {_syrtp} THEN COMMENT {_lines[5]}
@@IFNDEF {_syrtp} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Print available Backups @@@@
@SET {_cmd} = "SYBFP"
@SCRIPTLOG APPEND {_script_log_file}
{_cmd}:FILE;
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check COMMAND LOG status @@@@
@SET {_cmd} = ""
@IF {_CP_T} in ["APZ 212 60","APZ 212 55","APZ 212 50","APZ 212 40"] THEN SET {_cmd} = "SYCLP"
@IF {_CP_T} in ["APZ 212 33","APZ 212 33c","APZ 212 30","APZ 212 25"] THEN SET {_cmd} = "SYCLP"
{_cmd};
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_state}{_lines} ".*INACTIVE.*"
@FIND {_substate}{_lines} ".*BLOCKED.*"
@IFDEF {_state} THEN COMMENT Command log is INACTIVE
@IFDEF {_substate} THEN COMMENT Substate is BLOCKED
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@@@ Check time settings @@@@
@SET {_cmd} = "CACLP"
{_cmd};
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_summer}{_lines} ".*SUMMER TIME PERIOD.*"
@IFDEF {_summer} THEN CALC {_summt}={_summt}+1
@@IFDEF {_summer} THEN SET {_summt}={_summt}+1
@IF {_summt} = 2 THEN COMMENT Summer time applyed - OK
@IF {_summt} = 1 THEN COMMENT No Summer time but on Exch
@IFNDEF {_summer} THEN COMMENT Summer time not defined on Exch
@FIND {_urc}{_lines} ".*ACTIVE"
@@IFDEF {_urc} THEN COMMENT URC is {_lines[{_urc}]}
@IFNDEF {_urc} THEN COMMENT URC is not ACTIVE
@IFNDEF {_urc} THEN FIND {_urc1}{_lines} ".*URC.*"
@IFDEF {_urc1} THEN FOREACH {_urc1} COMMENT {_lines[{_urc1[{_CURRIDX}]}]}
@@IFNDEF {_urc} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@ Check routing printouts @@@@
@SET {_cmd} = "SARPI"
{_cmd};
@FIND {_FC}{_lines} "FAULT CODE.*"
@IFNDEF {_FC} THEN RELEASE
@T 3
@IFNDEF {_FC} THEN CONNECT
@FIND {_sarpi}{_lines} ".*RPB MAINTENANCE WORK IN PROGRESS.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_FC} THEN COMMENT Command {_cmd} executed with {_lines[{_FC}]}
@IFNDEF {_sarpi} THEN COMMENT No printout!
@IFNDEF {_FC} THEN COMMENT Command {_cmd} executed
@SCRIPTLOG OFF
@SET {_cmd} = ""
@IFDEF {_sarpi} THEN SET {_cmd} = "SARPE"
{_cmd};
@IFDEF {_sarpi} THEN RELEASE
@T 3
@IFDEF {_sarpi} THEN CONNECT
@FIND {_sarpe}{_lines} ".*RPB MAINTENANCE WORK IN PROGRESS.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_sarpe} THEN COMMENT Command {_cmd} executed
@SCRIPTLOG OFF 

@@@@ Check node type @@@@
@@ and go to check proc @@

@IF {_msc} = 1 THEN GOSUB _NSS_check
@IF {_bsc} = 1 THEN GOSUB _BSS_check

@IF {_apg_ne} = 1 THEN GOSUB _AP_check
@IF {_iog_ne} = 1 THEN GOSUB _SP_check

@Log off
@LABEL _end_exec
@IFDEF {_log_file} THEN COMMENT Results stored in files:
@IFDEF {_log_file} THEN COMMENT {_log_file} - log file
@IFDEF {_script_log_file} THEN COMMENT {_script_log_file} - script log file
@IFDEF {_pcorp_log_file} THEN COMMENT {_pcorp_log_file} - CP corrections
@IFDEF {_filename_dip} THEN COMMENT {_filename_dip}
@IFDEF {_filename_sdip} THEN COMMENT {_filename_sdip}
@IFDEF {_filename_snt} THEN COMMENT {_filename_snt}

@END
@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@ END OF EXECUTION @@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@

@LABEL _check_alist
@CONFIRM "Alarms there. Check alarm list during 10sec.!"
@SCRIPTLOG OFF
@T 10
@RETURN

@LABEL _IPNck
@SET {_line_count} = 0
@IF {_apg_ne} = 1 THEN SET {_cmd} = "OCINP:IPN=ALL;"
@IF {_iog_ne} = 1 THEN SET {_cmd} = "EXSLP:SPG=ALL;"
{_cmd}
@SCRIPTLOG APPEND {_script_log_file}
@IF {_cmd} = "OCINP:IPN=ALL;" THEN FIND {_ipnck}{_lines} ".*AB.*|.*CB.*|.*FC.*|.*MB.*|.*MS.*"
@IF {_cmd} = "EXSLP:SPG=ALL;" THEN FIND {_ipnck}{_lines} ".*ABL.*|.*MBL.*|.*NOSBACC.*|.*TBL.*|.*SEP.*"
@IFDEF {_ipnck} THEN SIZE {_ipnck}{_line_count}
@IF {_line_count} > 1 THEN FOREACH {_ipnck} COMMENT {_lines[{_CURRLINE}]}
@IF {_line_count} > 1 THEN COMMENT Some Link not in WO state
@@IF {_line_count} > 1 THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF
@RETURN

@LABEL _NSS_check

@@ Check related BSCs @@
@SET {_cmd} = "MGBSP"
{_cmd}:BSC=ALL;
@SCRIPTLOG APPEND {_script_log_file}
@IF {_line4} = NONE THEN COMMENT Thith NE is haven't BSCs 
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@ Check state of devices in routes @@
@SET {_line_count} = 0
@SET {_cmd} = "STRSP"
{_cmd}:R=ALL;
@FIND {_strsp}{_lines} "DEVICE STATE SURVEY"
@CALC {i} = {_strsp} + 2
@@SET {i} = {_strsp} + 2

@SIZE {_lines}{_line_count}
@CALC {_line_count} = {_line_count} - 1
@@SET {_line_count} = {_line_count} - 1

@CUT {_strsp_col}{_lines} col 5
@FOREACH {_strsp_col} TRIM {_strsp_col[{_CURRIDX}]}
@SET {j} = 0
@WHILE {i} < {_line_count}
@IF {_strsp_col[{i}]} <> 0 THEN COPY {_lines[{i}]}{_strsp_bk[{j}]} 1 7
@IF {_strsp_col[{i}]} <> 0 THEN INC {j}
@INC {i}
@ENDWHILE
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_strsp_bk} THEN COMMENT Routes with blocked devices:
@IFDEF {_strsp_bk} THEN FOREACH {_strsp_bk} TRIM {_strsp_bk[{_CURRIDX}]}
@IFDEF {_strsp_bk} THEN FOREACH {_strsp_bk} COMMENT {_CURRIDX}: {_CURRLINE}
@IFDEF {_strsp_bk} THEN SIZE {_strsp_bk}{_line_count}
@IFNDEF {_strsp_bk} THEN SET {_line_count} = 0
@IF {_line_count} <> 0 THEN SET {i} = 0
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF
@WHILE {i} < {_line_count}
@SET {_cmd} = "STRDP"
@SCRIPTLOG APPEND {_path}\{_date}_{_cmd}_{_abf}_{exch_name}.res
{_cmd}:R={_strsp_bk[{i}]};
@INC {i}
@SCRIPTLOG OFF
@ENDWHILE

@@ Check blocking state of devices @@
@SET {_cmd} = "STBSP"
{_cmd}:DETY=ALL,BLSTATE=ABL;
@SCRIPTLOG APPEND {_script_log_file}
@IF {_line3} <> "NONE" THEN COMMENT Some devices are blocked
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@ Check Network management Function @@
@SET {_cmd} = "NERDP"
@SCRIPTLOG APPEND {_script_log_file}
{_cmd}:R=ALL;
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "NEDBP"
@SCRIPTLOG APPEND {_script_log_file}
{_cmd}:BNC=ALL;
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@ Check IP port configuration on GARP-1 board @@
@SET {_cmd} = "IHCOP"
@SCRIPTLOG APPEND {_script_log_file}
{_cmd}:IPPORT=ALL;
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "IHSTP"
{_cmd}:IPPORT=ALL;
@FIND {_ihstp}{_lines} ".*IDLE.*"
@FIND {_ihstp_bk}{_lines} ".*ABL.*|.*CBL.*|.*MBL.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_ihstp_bk} THEN COMMENT Some IP PORTs blocked
@IFDEF {_ihstp_bk} THEN FOREACH {_ihstp_bk} COMMENT {_lines[{_ihstp[{_CURRIDX}]}]}
@IFDEF {_ihstp} THEN COMMENT Some IP PORTs not in BUSY state
@IFDEF {_ihstp} THEN FOREACH {_ihstp} COMMENT {_lines[{_ihstp[{_CURRIDX}]}]}
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "IHALP"
{_cmd}:EPID=ALL;
@FIND {_ihalp}{_lines} ".*NOT ACTIVE.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_ihalp} THEN COMMENT Some RIP is NOT ACTIVE
@IFDEF {_ihalp} THEN FOREACH {_ihalp} COMMENT {_lines[{_ihalp[{_CURRIDX}]}]}
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@ Check M3UA assoc @@
@SET {_cmd} = "M3ASP"
{_cmd};
@FIND {_m3asp_bk}{_lines} ".*INACTIVE.*"
@FIND {_m3asp}{_lines} ".*DOWN.*|.*ESTB.*|.*INACT.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_m3asp_bk} THEN COMMENT Some M3UA assoc have BLSTATE
@IFDEF {_m3asp_bk} THEN FOREACH {_m3asp_bk} COMMENT {_lines[{_m3asp_bk[{_CURRIDX}]}]}
@IFDEF {_m3asp} THEN COMMENT Some M3UA assoc is not ACTIVE
@IFDEF {_m3asp} THEN FOREACH {_m3asp} COMMENT {_lines[{_m3asp[{_CURRIDX}]}]}
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "M3RSP"
{_cmd}:DEST=ALL;
@FIND {_m3rsp}{_lines} ".*EN-ACT-UNAVA.*|.*EN-INAC-AVA.*|.*EN-INAC-UNAVA.*|.*DIS-ACT-AVA.*|.*DIS-ACT-UNAVA.*|.*DIS-INAC-AVA.*|.*DIS-INAC-UNAVA.*|.*EN-DOWN.*|.*DIS-DOWN.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_m3rsp} THEN COMMENT Some M3UA assoc have incorrect RST
@IFDEF {_m3rsp} THEN FOREACH {_m3rsp} COMMENT {_lines[{_m3rsp[{_CURRIDX}]}]}
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@ Check MGW status @@
@SET {_cmd} = "NRGWP"
{_cmd}:MG=ALL;
@FIND {_nrgwp}{_lines} ".*UNAV.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_nrgwp} THEN COMMENT Some MGW is unavailable
@IFDEF {_nrgwp} THEN FOREACH {_nrgwp} COMMENT {_lines[{_nrgwp[{_CURRIDX}]}]}
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@@ Check RPB-E status @@
@SET {_cmd} = "EXRNP"
{_cmd}:RP=ALL;
@SCRIPTLOG APPEND {_script_log_file}
@IF {_line3} = "NO RPB-E RP" THEN COMMENT No RPB-E there
@FIND {_exrnp_lnk}{_lines} ".*DOWN.*"
@FIND {_exrnp_rp}{_lines} ".*ABL.*|.*MBL.*"
@IFDEF {_exrnp_lnk} THEN COMMENT Some link is down
@IFDEF {_exrnp_lnk} THEN COMMENT RP   LNKA LNKB STATUS BRNO  MAGNO  SLOTNO
@IFDEF {_exrnp_lnk} THEN FOREACH {_exrnp_lnk} COMMENT {_lines[{_exrnp_lnk[{_CURRIDX}]}]}
@IFDEF {_exrnp_rp} THEN COMMENT Some RP is blocked
@IFDEF {_exrnp_rp} THEN COMMENT RP   LNKA LNKB STATUS BRNO  MAGNO  SLOTNO
@IFDEF {_exrnp_rp} THEN FOREACH {_exrnp_rp} COMMENT {_lines[{_exrnp_rp[{_CURRIDX}]}]}
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@RETURN

@@@@@@@@@@@@@@@@@@@@@@@@
@LABEL _BSS_check
@SET {_cmd} = "RLCRP"
@SCRIPTLOG APPEND {_script_log_file}
{_cmd}:CELL=ALL;
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "STBSP"
@SCRIPTLOG APPEND {_script_log_file}
{_cmd}:DETY=ALL;
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@UNSET {_FC}
@SET {_cmd} = "RRGBP"
{_cmd};
@FIND {_FC}{_lines} "FAULT CODE.*"
@SCRIPTLOG APPEND {_script_log_file}
@FIND {_BVCrrgbp}{_lines} ".*BLOCKED.*|.*CONFIG.*"
@FIND {_BVCrrgbp_T}{_lines} "^RADIO TRANSMISSION GB INTERFACE CONFIGURATION DATA$"
@FIND {_NSVCIrrgbp}{_lines} ".*BLOC.*|.*RECONFIG.*|.*LIBL.*"
@IFDEF {_BVCrrgbp} THEN GOSUB _BVC_check
@IFDEF {_NSVCIrrgbp} THEN COMMENT Some NSVCI not in ACTIVE state
@IFDEF {_NSVCIrrgbp} THEN FOREACH {_NSVCIrrgbp} COMMENT {_lines[{_CURRLINE}]}
@IFDEF {_FC} THEN COMMENT Command {_cmd} executed with {_lines[{_FC}]}
@IFNDEF {_FC} THEN COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "RRTPP"
@SCRIPTLOG APPEND {_script_log_file}
{_cmd}:TRAPOOL=ALL;
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "RRINP"
{_cmd}:NSEI=ALL;
@FIND {_rrinp}{_lines} ".*NONOP.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_rrinp} THEN COMMENT Some RIP/LIP is not in OPERATIONAL state
@IFDEF {_rrinp} THEN FOREACH {_rrinp} COMMENT {_lines[{_CURRLINE}]}
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "RRBVP"
@SCRIPTLOG APPEND {_script_log_file}
{_cmd}:NSEI=ALL;
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@RETURN

@LABEL _BVC_check
@IF {_BVCrrgbp[0]} <> {_BVCrrgbp_T[0]} THEN COMMENT Some BVC not in ACTIVE state
@IF {_BVCrrgbp[0]} <> {_BVCrrgbp_T[0]} THEN FOREACH {_BVCrrgbp} COMMENT {_lines[{_CURRLINE}]}
@RETURN

@@ AP check
@LABEL _AP_check

@SET {_cmd} = "aploc"
{_cmd};

@SET {_cmd} = "cd "
{_cmd}\
@SET {_cmd} = "alist"
{_cmd}

@@ Check cluster resources @@
@SET {_cmd} = "cluster node"
{_cmd}
@FIND {_nodes}{_lines} ".*Down"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_nodes} THEN COMMENT Some node is down
@IFDEF {_nodes} THEN FOREACH {_nodes} COMMENT {_lines[{_CURRLINE}]}
!@IFDEF {_nodes} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "cluster res"
{_cmd}
@FIND {_ress}{_lines} ".*Offline.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_ress} THEN COMMENT Some resources is Offline
@IFDEF {_ress} THEN FOREACH {_ress} COMMENT {_lines[{_ress[{_CURRIDX}]}]}
!@IFDEF {_ress} THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "hostname"
{_cmd}

@SET {_node_name} = {_line1}
@COMMENT {_node_name}

@SET {_cmd} = "prcstate"
{_cmd}
@SCRIPTLOG APPEND {_script_log_file}
@@IF {_line1} = "undefined" THEN COMMENT Node {_node_name} is {_line2}
@COMMENT Node {_node_name} is {_line1}
@@IF {_line1} = "undefined" THEN PAUSE
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

{_cmd} -l
@FIND {_pstate}{_lines} ".*down.*|.*but not all.*"
@SCRIPTLOG APPEND {_script_log_file}
@IFDEF {_pstate} THEN FOREACH {_pstate} COMMENT {_lines[{_CURRLINE}]}
@COMMENT Command {_cmd} -l executed
@SCRIPTLOG OFF

@SET {_cmd} = "hwver"
{_cmd}
@SET {_hwver} = 0
@IF {_line3} = "APG40C/4" THEN SET {_hwver} = 1
@IF {_line3} = "APG43" THEN SET {_hwver} = 2
@IF {_hwver} = 1 THEN GOTO _skip_C2
@IF {_hwver} = 2 THEN GOTO _skip_C4

@SET {_cmd} = raidutil -L raid
{_cmd}
@GOSUB _check_raid
@GOTO _skip_apg43

@LABEL _skip_C2
@SET {_cmd} = scsidisk /LD
{_cmd}
@GOSUB _check_raid
@SET {_cmd} = megarc -dispcfg -a0
{_cmd}
@GOSUB _check_raid
@GOTO _skip_apg43

@LABEL _skip_C4
@SET {_cmd} = "vxvol volinfo I:"
{_cmd}
@GOSUB _check_raid
@SET {_cmd} = "vxvol volinfo K:"
{_cmd}
@GOSUB _check_raid
@GOTO _skip_apg43

@LABEL _check_raid
@SCRIPTLOG APPEND {_script_log_file}
@COMMENT Command {_cmd} executed
@FIND {_raid}{_lines} ".*Degraded.*|.*Missing.*|.*Failed.*|.*Offline.*|.*OFFLINE.*"
@IFDEF {_raid} THEN COMMENT Some drivers not in optimal state
@IFDEF {_raid} THEN FOREACH {_raid} COMMENT {_lines[{_CURRLINE}]}
@SCRIPTLOG OFF
@RETURN
@LABEL _skip_apg43


@SET {_cmd} = "exalls"
{_cmd}
{_cmd} -l
@SCRIPTLOG APPEND {_script_log_file}
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "cpfls"
{_cmd}
@SCRIPTLOG APPEND {_script_log_file}
@COMMENT Command {_cmd} executed
@SCRIPTLOG OFF


@SET {_cmd} = ""
@IF {_sft} = 1 THEN SET {_cmd} = "swrprint"
@SCRIPTLOG APPEND {_script_log_file}
{_cmd}
@IF {_cmd} <> "" THEN COMMENT Command {_cmd} executed
@SCRIPTLOG OFF

@SET {_cmd} = "exit"
{_cmd}
@SET {_cmd} = ""

@IF {_sft} = 1 THEN CONCAT {_pcorp_log_file} {_path}"\"{_date}"_PCORP_"{_abf}"_"{exch_name}".res"
@IF {_sft} = 1 THEN SET {_cmd} = "PCORP:BLOCK=ALL;"
@IF {_sft} = 1 THEN SCRIPTLOG APPEND {_pcorp_log_file}
{_cmd}
@IF {_sft} = 1 THEN COMMENT Command {_cmd} executed
@IF {_sft} = 1 THEN SCRIPTLOG OFF   

@SET {_cmd} = ""
@IF {_msc} = 1 THEN GOSUB _check_TT_files
@@COMMENT Command {_cmd} executed
@RETURN

@LABEL _check_TT_files

@SET {_cmd} = ""
@IF {_msc} = 1 THEN SET {_cmd} = "SAAEP:BLOCK=CHOP,SAE=500;"
{_cmd}
@COMMENT Command {_cmd} executed

@COPY {exch_name} {_fst} 1 3
@COPY {exch_name} {_scd} 5 3
@TRIM {_scd}

@SET {_cmd} = "aploc"
{_cmd};

@SET {_cmd} = "cd "
{_cmd}\

@SET {_cmd} = "afpls"
{_cmd} -l -s {_fst}{_scd}
@T 20
{_cmd} -l -s {_fst}{_scd}
@SET {_cmd} = "cd"
@SET {_disk} = Y
@IF {_hwver} = 2 THEN SET {_disk} = K

{_cmd} /d {_disk}:\ACS\DATA\RTR\CHS_CP0EX\DATAFILES\REPORTED

@SET {_cmd} = "dir"
{_cmd}
@SET {_cmd} = "cd"
{_cmd} /d K:\aes\data\cdh\ftp\charging00\Ready\
@SET {_cmd} = "dir"
{_cmd}

@SET {_cmd} = "exit"
{_cmd}

@RETURN

@LABEL _SP_check
@RETURN