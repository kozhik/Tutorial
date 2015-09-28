@GETDATE {_date} YYMMDD
@SET {_correct} = 0
@SET {_flag} = 1
@WHILE {_correct} = 0
@ASK {oss_num} "Enter OSS number as 1 or 2 or 3"
@TRIM {oss_num}
@IF {oss_num} = 1 THEN CONCAT {_flag} "001"
@IF {oss_num} = 2 THEN CONCAT {_flag} "010"
@IF {oss_num} = 3 THEN CONCAT {_flag} "011"
@IF {oss_num} = 1 THEN CONCAT {_oss} "OSS-1"
@IF {oss_num} = 2 THEN CONCAT {_oss} "OSS-2"
@IF {oss_num} = 3 THEN CONCAT {_oss} "OSS-3"

@@COMMENT {_flag}
@IF {_flag} IN ["001","010","011"] THEN SET {_correct} = 1
@IF {_correct} = 0 THEN CONCAT {_comm} "No OSS with no "{oss_num}
@IF {_correct} = 0 THEN CONFIRM {_comm}
@ENDWHILE

@TRIM {oss_num}
@CONCAT {_filename} "C:\Logs\OSS_"{oss_num}".csv"
@READ {_filename} {_nes}
@CONCAT {_logfile} "C:\Logs\"{_date}"_ActivateSTSOnOSS.log"

@SIZE {_nes} {_NE_lines}
@SET {i} = 0

@@ -- User request What NE types need to be checked -- @@
@SET {_checkMSC} = 1
@SET {_checkMSS} = 1
@SET {_checkBSC} = 1
@SET {_checkTSS} = 1
@SET {_checkSTP} = 1
@SET {_checkHLR} = 1

@FORM CREATE "NE types to check!"
@FORM TEXT "NE types to check:" 1 1 30 10
@FORM TEXT "MSC (1 = yes/0 = no)" 1 4 30 10
@FORM EDITTEXT {_checkMSC} 1 7 30
@FORM TEXT "MSS (1 = yes/0 = no)" 1 10 30 10
@FORM EDITTEXT {_checkMSS} 1 13  30
@FORM TEXT "BSC (1 = yes/0 = no)" 1 16 30 10
@FORM EDITTEXT {_checkBSC} 1 19 30
@FORM TEXT "TSC/TSS (1 = yes/0 = no)" 1 22 30 10
@FORM EDITTEXT {_checkTSS} 1 25 30
@FORM TEXT "STP (1 = yes/0 = no)" 1 28  30 10
@FORM EDITTEXT {_checkSTP} 1 31 30
@FORM TEXT "HLR (1 = yes/0 = no)" 1 34  30 10
@FORM EDITTEXT {_checkHLR} 1 37 30
@FORM RUN

@WHILE {i} < {_NE_lines}
@SET {_cmd} = ""
@UNSET {_conn_failed}
@UNSET {_Otypes}
@UNSET {_OT_lines}
@UNSET {_OT_inf}
@UNSET {_OT_state}
@UNSET {_fileheader}
@UNSET {_filedata}

@@ -- calculate progress -- @@
@CALC {_progr} = (100*({i}+1))/{_NE_lines}
@COMMENT PROGRESS: {_progr} of 100

@@ -- get Exchange name as on OSS -- @@
@ITEM {_exch_name} {_nes[{i}]} ";" 2

@@ -- define type of current NE -- @@
@COPY {_exch_name} {_netype} 1 3
@TRIM {_netype}

@@ -- undefine all markers for NE type -- @@
@SET {_isMSC} = "0"
@SET {_isMSS} = "0"
@SET {_isBSC} = "0"
@SET {_isTSS} = "0"
@SET {_isSTP} = "0"
@SET {_isHLR} = "0"

@@ -- check NE type and define marker -- @@
@IF {_netype} = "MSC" THEN SET {_isMSC} = "1"
@IF {_netype} = "MSS" THEN SET {_isMSS} = "1"
@IF {_netype} = "BSC" THEN SET {_isBSC} = "1"
@IF {_netype} IN ["TSS","TSC"] THEN SET {_isTSS} = "1"
@IF {_netype} = "STP" THEN SET {_isSTP} = "1"
@IF {_netype} = "HLR" THEN SET {_isHLR} = "1"
@IF {_isTSS} = 1 THEN SET {_netype} = "TSS"

@CONCAT {_isMSC} {_isMSC} {_checkMSC}
@CONCAT {_isMSS} {_isMSS} {_checkMSS}
@CONCAT {_isBSC} {_isBSC} {_checkBSC}
@CONCAT {_isTSS} {_isTSS} {_checkTSS}
@CONCAT {_isSTP} {_isSTP} {_checkSTP}
@CONCAT {_isHLR} {_isHLR} {_checkHLR}

@@COMMENT MSC = {_isMSC}
@@COMMENT MSS = {_isMSS}
@@COMMENT BSC = {_isBSC}
@@COMMENT TSS = {_isTSS}
@@COMMENT STP = {_isSTP}
@@COMMENT HLR = {_isHLR}

@IF {_isMSC} = 11 THEN GOTO checkMSC
@IF {_isMSS} = 11 THEN GOTO checkMSS
@IF {_isBSC} = 11 THEN GOTO checkBSC
@IF {_isTSS} = 11 THEN GOTO checkTSS
@IF {_isSTP} = 11 THEN GOTO checkSTP
@IF {_isHLR} = 11 THEN GOTO checkHLR

@GOTO _fin

@LABEL checkMSC
@COMMENT check MSC

@CONCAT {_fileheader} "OSS #;NE;"
@CONCAT {_filedata} "OSS-"{oss_num}";"{_exch_name}";"
eaw {_exch_name}
@GREP {_conn_failed} {_lines} ".*Connection failed.*"
@SCRIPTLOG APPEND {_logfile}
@IFDEF {_conn_failed} THEN SET {_exch_name} = {_exch_name}+" Not defined on "+{_oss}
@COMMENT ================== {_exch_name} ==================
@SCRIPTLOG OFF
@IFNDEF {_conn_failed} THEN SET {_cmd} = "exit;"
@IFDEF {_conn_failed} THEN GOTO _skipMSC
ioexp;
@SET {_cmd} = "ioexp;"
{_cmd}
@copy {_line4} {exch_name} 1 6
@SET {_path} = C:\Logs\{exch_name}
@TRIM {_path}
@GETDATE {_date} YYMMD
@COMMENT Command {_cmd} executed
@COMMENT {_path}
@EXECWAIT cmd /c mkdir {_path}
@CONCAT {_log_file} {_path}"\"{_date}"_STS_"{exch_name} ".log"
@Log ON {_log_file} 
allip;
APLOC;
hostname
prcstate -l 
time /t
date /t
stmmp -l -L
stmrp -l -L
stmmp -D 1001
stmmp -D 1000
stmrp -D 2001
stmrp -D 2000 
stmmp -l -L
stmrp -l -L     
stmrp SDMMSC{oss_num} BSCSTAT C7DPC C7OPC C7SCCPUSE C7SCSUBSYS CHASSIGNT CP DIGPATH DIP DISCCALL
stmrp -M 2000 DTISTAT ECPOOL EQIDCON HLRSTAT L3CCMSG LOCAREAST LSCC M3ASPSM M3ASPTM M3ASSOC
stmrp -M 2000 M3PERF M3SSNM MBASTRAFTY MTSFB NBRCELLST NMROUTE PAGING RP SERVFEAT SNT
stmrp -M 2000 SUPPLSERV TCABO TCCMP TCDIA TCREJ TCUSE TRAFFDEST1
             
stmrp SDMMAP{oss_num} C7SCPERF C7SCQOS C7SL1 C7SL2 EOS HNDOVER HS7SL1 ISDNESG L3CCMSG LOAS
stmrp -M 2001 LOSSROUTE M3DATA M3DEST1 M3MGMT MAPSIGIWRK MTRAFTYPE NBRMSCLST SAE SCTPAM SCTPLM
stmrp -M 2001 SCTPTM SECHAND SHAM SHIST SHMSGSERV TCMSG TRAFFDEST1 TRUNKROUTE UPDLOCAT HS7SL1 ISDNESG   
stmrp -l -L
stmmp -z ASN.1 -p 60 -b 201110201500 -t SDMMSC{oss_num} 60 2000
stmmp -z ASN.1 -p 15 -b 201110201500 -t SDMMAP{oss_num} 15 2001 
stmmp -l -L 
exit;
exit;          
@GOTO _fin

@LABEL checkMSS
@COMMENT check MSS

@CONCAT {_fileheader} "OSS #;NE;"
@CONCAT {_filedata} "OSS-"{oss_num}";"{_exch_name}";"
eaw {_exch_name}
@GREP {_conn_failed} {_lines} ".*Connection failed.*"
@SCRIPTLOG APPEND {_logfile}
@IFDEF {_conn_failed} THEN SET {_exch_name} = {_exch_name}+" Not defined on "+{_oss}
@COMMENT ================== {_exch_name} ==================
@SCRIPTLOG OFF
@IFNDEF {_conn_failed} THEN SET {_cmd} = "exit;"
@IFDEF {_conn_failed} THEN GOTO _skipMSS
ioexp;
@SET {_cmd} = "ioexp;"
{_cmd}
@copy {_line4} {exch_name} 1 6
@SET {_path} = C:\Logs\{exch_name}
@TRIM {_path}
@GETDATE {_date} YYMMD
@COMMENT Command {_cmd} executed
@COMMENT {_path}
@EXECWAIT cmd /c mkdir {_path}
@CONCAT {_log_file} {_path}"\"{_date}"_STS_"{exch_name} ".log"
@Log ON {_log_file} 
allip;
APLOC;
hostname
prcstate -l 
time /t
date /t
stmmp -l -L
stmrp -l -L
stmmp -D 1001
stmmp -D 1000
stmrp -D 2001
stmrp -D 2000 
stmmp -l -L
stmrp -l -L     
stmrp SDMMSS{oss_num} APPLATFORM APDISKS BSCSTAT C7DPC C7OPC C7SCCPUSE C7SCSUBSYS CHASSIGNT CP DIGPATH    
stmrp -M 2000 DIP DISCCALL DTISTAT ECPOOL EQIDCON GCPHQ HLRSTAT L3CCMSG LOCAREAST LSCC
stmrp -M 2000 M3ASPSM M3ASPTM M3ASSOC M3PERF M3SSNM MBASTRAFTY MTSFB NBRCELLST NMROUTE OOBTCSTAT
stmrp -M 2000 PAGING PMROUTE RP SERVFEAT SNT SUPPLSERV TCABO TCCMP TCDIA TCREJ
stmrp -M 2000 TCUSE                        
stmrp SDMMAP{oss_num} C7SCPERF C7SCQOS C7SL1 C7SL2 DEFMGW1 EOS GCPHQ GCPHRP HNDOVER HS7SL1
stmrp -M 2001 ISDNESG LOAS LOSSROUTE M3DATA M3DEST1 M3MGMT MAPSIGIWRK MTRAFTYPE NBRMSCLST SAE
stmrp -M 2001 SCTPAM SCTPLM SCTPTM SECHAND SHAM SHIST SHMSGSERV TCMSG TRAFFDEST1 TRUNKROUTE
stmrp -M 2001 UPDLOCAT    
stmrp -l -L
stmmp -z ASN.1 -p 60 -b 201110201500 -t SDMMSS{oss_num} 60 2000
stmmp -z ASN.1 -p 15 -b 201110201500 -t SDMMAP{oss_num} 15 2001 
stmmp -l -L 
exit;
exit;             
@GOTO _fin

@LABEL checkBSC
@COMMENT check BSC
@CONCAT {_fileheader} "OSS #;NE;"
@CONCAT {_filedata} "OSS-"{oss_num}";"{_exch_name}";"

eaw {_exch_name}
@GREP {_conn_failed} {_lines} ".*Connection failed.*"
@SCRIPTLOG APPEND {_logfile}
@IFDEF {_conn_failed} THEN SET {_exch_name} = {_exch_name}+" Not defined on "+{_oss}
@COMMENT ================== {_exch_name} ==================
@SCRIPTLOG OFF
@IFNDEF {_conn_failed} THEN SET {_cmd} = "exit;"
@IFDEF {_conn_failed} THEN GOTO _skipBSC
ioexp;
@SET {_cmd} = "ioexp;"
{_cmd}
@copy {_line4} {exch_name} 1 6
@SET {_path} = C:\Logs\{exch_name}
@TRIM {_path}
@GETDATE {_date} YYMMD
@COMMENT Command {_cmd} executed
@COMMENT {_path}
@EXECWAIT cmd /c mkdir {_path}
@CONCAT {_log_file} {_path}"\"{_date}"_STS_"{exch_name} ".log"
@Log ON {_log_file} 
allip;
APLOC;
hostname
prcstate -l 
time /t
date /t  
stmmp -l -L
stmrp -l -L
stmmp -D 1001
stmmp -D 1000
stmrp -D 2001
stmrp -D 2000 
stmmp -l -L
stmrp -l -L     
stmrp SDMBSC{oss_num} ATERTRANS BSC BSCGPRS BSCGPRS2 BSCQOS C7SCCPUSE CCCHLOAD CELEVENTD CELEVENTH CELEVENTI
stmrp -M 2000 CELEVENTS CELLCCHDR CELLCCHHO CELLDUALT CELLFERF CELLFERH CELLFLXAB CELLGPRS CELLGPRS2 CELLGPRS3
stmrp -M 2000 CELLGPRSO CELLPAG CELLQOSEG CELLQOSG CELLSQI CHGRP0F CLDTMEST CLDTMPER CLDTMQOS CLRATECHG
stmrp -M 2000 CLRXQUAL CLSMS CLTCHDRAF CLTCHDRAH CLTCHDRF CLTCHDRH CLTCHFV1 CLTCHFV2 CLTCHFV3 CLTCHFV3C
stmrp -M 2000 CLTCHHV1 CLTCHHV2 CLTCHHV3 CLTCHHV3C DIGPATH DIP DOWNTIME EMGPRS GPRSGEN IDLEUTCHF
stmrp -M 2000 IDLEUTCHH LAPD LOADREG LOASMISC MOTS NCELLREL NECELASS NECELHO NECELHOEX NECELLREL
stmrp -M 2000 NICELASS NICELHO NICELHOEX NONRES64K RANDOMACC RES64K RLINKBITR RNDACCEXT SDIPHP SDIPLP
stmrp -M 2000 SDIPMS TRAFDLGPRS TRAFGPRS2 TRAPEVENT
stmrp SDMCEL{oss_num} CELTCHF CELTCHH CLSDCCH CLTCH RANDOMACC  
stmrp -l -L
stmmp -z ASN.1 -p 60 -b 201110201500 -t SDMBSC{oss_num} 60 2000
stmmp -z ASN.1 -p 15 -b 201110201500 -t SDMBSC{oss_num} 15 2001
stmmp -l -L     
exit;
exit;
@GOTO _fin

@LABEL checkTSS
@COMMENT check TSS

@CONCAT {_fileheader} "OSS #;NE;"
@CONCAT {_filedata} "OSS-"{oss_num}";"{_exch_name}";"
eaw {_exch_name}
@GREP {_conn_failed} {_lines} ".*Connection failed.*"
@SCRIPTLOG APPEND {_logfile}
@IFDEF {_conn_failed} THEN SET {_exch_name} = {_exch_name}+" Not defined on "+{_oss}
@COMMENT ================== {_exch_name} ==================
@SCRIPTLOG OFF
@IFNDEF {_conn_failed} THEN SET {_cmd} = "exit;"
@IFDEF {_conn_failed} THEN GOTO _skipTSS
ioexp;
@SET {_cmd} = "ioexp;"
{_cmd}
@copy {_line4} {exch_name} 1 6
@SET {_path} = C:\Logs\{exch_name}
@TRIM {_path}
@GETDATE {_date} YYMMD
@COMMENT Command {_cmd} executed
@COMMENT {_path}
@EXECWAIT cmd /c mkdir {_path}
@CONCAT {_log_file} {_path}"\"{_date}"_STS_"{exch_name} ".log"
@Log ON {_log_file} 
allip;
APLOC;
hostname
prcstate -l 
time /t
date /t  
stmmp -l -L
stmrp -l -L
stmmp -D 1001
stmmp -D 1000
stmrp -D 2001
stmrp -D 2000
stmmp -l -L
stmrp -l -L     
stmrp SDMTSS{oss_num} APPLATFORM APDISKS C7DPC C7OPC CHASSIGNT CP DIGPATH DIP DISCCALL                  
stmrp -M 2000 DTISTAT ECPOOL EQIDCON HLRSTAT LSCC M3ASPSM M3ASPTM M3ASSOC M3PERF M3SSNM               
stmrp -M 2000 MBASTRAFTY MTSFB NMROUTE RP SNT TCABO 
stmrp SDMMAP{oss_num} C7SCPERF C7SCQOS C7SL1 C7SL2 DEFMGW1 EOS GCPHRP GCPHQ HS7SL1 ISDNESG
stmrp -M 2001 LOAS LOSSROUTE M3DATA M3DEST1 M3MGMT MAPSIGIWRK MTRAFTYPE SAE SCTPAM SCTPLM 
stmrp -M 2001 SCTPTM SECHAND SHAM SHIST SHMSGSERV TCMSG TRAFFDEST1 TRUNKROUTE UPDLOCAT HS7SL1
stmrp -l -L
stmmp -z ASN.1 -p 60 -b 201110201500 -t SDMTSS{oss_num} 60 2000
stmmp -z ASN.1 -p 15 -b 201110201500 -t SDMMAP{oss_num} 15 2001     
stmmp -l -L     
exit;
exit; 
@GOTO _fin

@LABEL checkSTP
@COMMENT check STP

@CONCAT {_fileheader} "OSS #;NE;"
@CONCAT {_filedata} "OSS-"{oss_num}";"{_exch_name}";"
eaw {_exch_name}
@GREP {_conn_failed} {_lines} ".*Connection failed.*"
@SCRIPTLOG APPEND {_logfile}
@IFDEF {_conn_failed} THEN SET {_exch_name} = {_exch_name}+" Not defined on "+{_oss}
@COMMENT ================== {_exch_name} ==================
@SCRIPTLOG OFF
@IFNDEF {_conn_failed} THEN SET {_cmd} = "exit;"
@IFDEF {_conn_failed} THEN GOTO _skipSTP
ioexp;
@SET {_cmd} = "ioexp;"
{_cmd}
@copy {_line4} {exch_name} 1 6
@SET {_path} = C:\Logs\{exch_name}
@TRIM {_path}
@GETDATE {_date} YYMMD
@COMMENT Command {_cmd} executed
@COMMENT {_path}
@EXECWAIT cmd /c mkdir {_path}
@CONCAT {_log_file} {_path}"\"{_date}"_STS_"{exch_name} ".log"
@Log ON {_log_file} 
allip;
APLOC;
hostname
prcstate -l 
time /t
date /t  
stmmp -l -L
stmrp -l -L
stmmp -D 1001
stmmp -D 1000
stmrp -D 2001
stmrp -D 2000
stmmp -l -L
stmrp -l -L     
stmrp SDMSTP3 APPLATFORM APDISKS CP DIGPATH DIP L3CCMSG MTSFB RP SNT GCPHQ SHSCF
stmrp -M 2000 SHSCF
stmrp SDMMAP3 C7SCPERF C7SL1 C7SL2 EOS GCPHRP GCPHQ HNDOVER M3DATA M3DEST1 L3CCMSG 
stmrp -M 2001 LOAS LOSSROUTE MTRAFTYPE NBRMSCLST SAE SCTPAM SCTPTM SCTPLM SECHAND SHMSGSERV
stmrp -M 2001 TRAFFDEST1 TRUNKROUTE  
stmrp -l -L
stmmp -z ASN.1 -p 60 -b 201110201500 -t SDMSTP3 60 2000
stmmp -z ASN.1 -p 15 -b 201110201500 -t SDMMAP3 15 2001 
stmmp -l -L     
exit;
exit;      

@GOTO _fin

@LABEL checkHLR
@COMMENT check HLR

@CONCAT {_fileheader} "OSS #;NE;"
@CONCAT {_filedata} "OSS-"{oss_num}";"{_exch_name}";"
eaw {_exch_name}
@GREP {_conn_failed} {_lines} ".*Connection failed.*"
@SCRIPTLOG APPEND {_logfile}
@IFDEF {_conn_failed} THEN SET {_exch_name} = {_exch_name}+" Not defined on "+{_oss}
@COMMENT ================== {_exch_name} ==================
@SCRIPTLOG OFF
@IFNDEF {_conn_failed} THEN SET {_cmd} = "exit;"
@IFDEF {_conn_failed} THEN GOTO _skipHLR
ioexp;
@SET {_cmd} = "ioexp;"
{_cmd}
@copy {_line4} {exch_name} 1 6
@SET {_path} = C:\Logs\{exch_name}
@TRIM {_path}
@GETDATE {_date} YYMMD
@COMMENT Command {_cmd} executed
@COMMENT {_path}
@EXECWAIT cmd /c mkdir {_path}
@CONCAT {_log_file} {_path}"\"{_date}"_STS_"{exch_name} ".log"
@Log ON {_log_file} 
allip;
APLOC;
hostname
prcstate -l 
time /t
date /t  
stmmp -l -L
stmrp -l -L
stmmp -D 1001
stmmp -D 1000
stmrp -D 2001
stmrp -D 2000
stmmp -l -L
stmrp -l -L     
stmrp SDMHLR3 APPLATFORM APDISKS AUTHEN C7DPC C7OPC C7SCCPUSE CP DIGPATH DIP M3ASPSM
stmrp -M 2000 M3ASPTM M3ASSOC  M3PERF M3SSNM  NAMSUBS ODBINV PDPDEF PLMNSUB RP SGSN
stmrp SDMMAP3 C7SL1 C7SL2 HLRMAP HS7SL1 C7SCPERF M3DATA M3DEST1 M3MGMT MAPSIGIWRK SAE
stmrp -M 2001 SCTPAM SCTPTM SCTPLM LOAS VLR  
stmrp -l -L
stmmp -z ASN.1 -p 60 -b 201110201500 -t SDMHLR3 60 2000
stmmp -z ASN.1 -p 15 -b 201110201500 -t SDMMAP3 15 2001 
stmmp -l -L     
exit;
exit;      

@LABEL _fin

@INC {i}
@ENDWHILE

@SCRIPTLOG APPEND {_logfile}
@COMMENT Results is stored in files:
@COMMENT {_filename} - table
@COMMENT {_logfile} - log file
@IFDEF {_resfileBSC} THEN COMMENT {_resfileBSC}
@IFDEF {_resfileMSC} THEN COMMENT {_resfileMSC}
@IFDEF {_resfileMSS} THEN COMMENT {_resfileMSS}
@IFDEF {_resfileSTP} THEN COMMENT {_resfileSTP}
@IFDEF {_resfileTSS} THEN COMMENT {_resfileTSS}
@IFDEF {_resfileHLR} THEN COMMENT {_resfileHLR}
@SCRIPTLOG OFF