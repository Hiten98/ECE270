
########## Tcl recorder starts at 04/11/18 08:08:02 ##########

set version "1.7"
set proj_dir "W:/Lab12"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" lab12.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:08:02 ###########


########## Tcl recorder starts at 04/11/18 08:12:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" lab12.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:12:04 ###########


########## Tcl recorder starts at 04/11/18 08:12:12 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lab12_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab12_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab12.sty
PROJECT: lab12_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab12_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab12.h lab12.v
OUTPUT_FILE_NAME: lab12_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab12_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab12_top.edi -out lab12_top.bl0 -err automake.err -log lab12_top.log -prj lab12 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab12_top.bl1\" -o \"lab12.bl2\" -omod \"lab12\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab12 -lci lab12.lct -log lab12.imp -err automake.err -tti lab12.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -blifopt lab12.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12.bl2 -sweep -mergefb -err automake.err -o lab12.bl3 @lab12.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -diofft lab12.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab12.bl3 -family AMDMACH -idev van -o lab12.bl4 -oxrf lab12.xrf -err automake.err @lab12.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -prefit lab12.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab12.bl4 -out lab12.bl5 -err automake.err -log lab12.log -mod lab12_top @lab12.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab12.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs1: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -nojed -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab12.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs2: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab12.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12.rs1
file delete lab12.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab12.bl5 -o lab12.tda -lci lab12.lct -dev m4e_256_96 -family lc4k -mod lab12_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab12 -if lab12.jed -j2s -log lab12.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:12:12 ###########


########## Tcl recorder starts at 04/11/18 08:38:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" lab12.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:38:10 ###########


########## Tcl recorder starts at 04/11/18 08:38:16 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lab12_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab12_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab12.sty
PROJECT: lab12_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab12_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab12.h lab12.v
OUTPUT_FILE_NAME: lab12_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab12_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab12_top.edi -out lab12_top.bl0 -err automake.err -log lab12_top.log -prj lab12 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab12_top.bl1\" -o \"lab12.bl2\" -omod \"lab12\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab12 -lci lab12.lct -log lab12.imp -err automake.err -tti lab12.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -blifopt lab12.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12.bl2 -sweep -mergefb -err automake.err -o lab12.bl3 @lab12.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -diofft lab12.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab12.bl3 -family AMDMACH -idev van -o lab12.bl4 -oxrf lab12.xrf -err automake.err @lab12.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -prefit lab12.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab12.bl4 -out lab12.bl5 -err automake.err -log lab12.log -mod lab12_top @lab12.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab12.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs1: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -nojed -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab12.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs2: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab12.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12.rs1
file delete lab12.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab12.bl5 -o lab12.tda -lci lab12.lct -dev m4e_256_96 -family lc4k -mod lab12_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab12 -if lab12.jed -j2s -log lab12.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:38:16 ###########


########## Tcl recorder starts at 04/11/18 08:39:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" lab12.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:39:42 ###########


########## Tcl recorder starts at 04/11/18 08:39:52 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab12_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab12_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab12.sty
PROJECT: lab12_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab12_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab12.h lab12.v
OUTPUT_FILE_NAME: lab12_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab12_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab12_top.edi -out lab12_top.bl0 -err automake.err -log lab12_top.log -prj lab12 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab12_top.bl1\" -o \"lab12.bl2\" -omod \"lab12\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab12 -lci lab12.lct -log lab12.imp -err automake.err -tti lab12.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -blifopt lab12.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12.bl2 -sweep -mergefb -err automake.err -o lab12.bl3 @lab12.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -diofft lab12.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab12.bl3 -family AMDMACH -idev van -o lab12.bl4 -oxrf lab12.xrf -err automake.err @lab12.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -prefit lab12.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab12.bl4 -out lab12.bl5 -err automake.err -log lab12.log -mod lab12_top @lab12.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab12.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs1: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -nojed -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab12.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs2: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab12.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12.rs1
file delete lab12.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab12.bl5 -o lab12.tda -lci lab12.lct -dev m4e_256_96 -family lc4k -mod lab12_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab12 -if lab12.jed -j2s -log lab12.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:39:52 ###########


########## Tcl recorder starts at 04/11/18 08:41:41 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lab12_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab12_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab12.sty
PROJECT: lab12_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab12_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab12.h lab12.v
OUTPUT_FILE_NAME: lab12_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab12_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab12_top.edi -out lab12_top.bl0 -err automake.err -log lab12_top.log -prj lab12 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab12_top.bl1\" -o \"lab12.bl2\" -omod \"lab12\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab12 -lci lab12.lct -log lab12.imp -err automake.err -tti lab12.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -blifopt lab12.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12.bl2 -sweep -mergefb -err automake.err -o lab12.bl3 @lab12.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -diofft lab12.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab12.bl3 -family AMDMACH -idev van -o lab12.bl4 -oxrf lab12.xrf -err automake.err @lab12.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -prefit lab12.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab12.bl4 -out lab12.bl5 -err automake.err -log lab12.log -mod lab12_top @lab12.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab12.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs1: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -nojed -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab12.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs2: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab12.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12.rs1
file delete lab12.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab12.bl5 -o lab12.tda -lci lab12.lct -dev m4e_256_96 -family lc4k -mod lab12_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab12 -if lab12.jed -j2s -log lab12.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:41:41 ###########


########## Tcl recorder starts at 04/11/18 08:43:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" lab12.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:43:03 ###########


########## Tcl recorder starts at 04/11/18 08:43:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lab12_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab12_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab12.sty
PROJECT: lab12_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab12_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab12.h lab12.v
OUTPUT_FILE_NAME: lab12_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab12_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab12_top.edi -out lab12_top.bl0 -err automake.err -log lab12_top.log -prj lab12 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab12_top.bl1\" -o \"lab12.bl2\" -omod \"lab12\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab12 -lci lab12.lct -log lab12.imp -err automake.err -tti lab12.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -blifopt lab12.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12.bl2 -sweep -mergefb -err automake.err -o lab12.bl3 @lab12.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -diofft lab12.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab12.bl3 -family AMDMACH -idev van -o lab12.bl4 -oxrf lab12.xrf -err automake.err @lab12.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -prefit lab12.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab12.bl4 -out lab12.bl5 -err automake.err -log lab12.log -mod lab12_top @lab12.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab12.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs1: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -nojed -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab12.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs2: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab12.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12.rs1
file delete lab12.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab12.bl5 -o lab12.tda -lci lab12.lct -dev m4e_256_96 -family lc4k -mod lab12_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab12 -if lab12.jed -j2s -log lab12.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:43:09 ###########


########## Tcl recorder starts at 04/11/18 08:51:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" lab12.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:51:47 ###########


########## Tcl recorder starts at 04/11/18 08:53:55 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lab12_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab12_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab12.sty
PROJECT: lab12_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab12_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab12.h lab12.v
OUTPUT_FILE_NAME: lab12_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab12_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab12_top.edi -out lab12_top.bl0 -err automake.err -log lab12_top.log -prj lab12 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab12_top.bl1\" -o \"lab12.bl2\" -omod \"lab12\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab12 -lci lab12.lct -log lab12.imp -err automake.err -tti lab12.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -blifopt lab12.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12.bl2 -sweep -mergefb -err automake.err -o lab12.bl3 @lab12.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -diofft lab12.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab12.bl3 -family AMDMACH -idev van -o lab12.bl4 -oxrf lab12.xrf -err automake.err @lab12.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -prefit lab12.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab12.bl4 -out lab12.bl5 -err automake.err -log lab12.log -mod lab12_top @lab12.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab12.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs1: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -nojed -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab12.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs2: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab12.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12.rs1
file delete lab12.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab12.bl5 -o lab12.tda -lci lab12.lct -dev m4e_256_96 -family lc4k -mod lab12_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab12 -if lab12.jed -j2s -log lab12.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 08:53:55 ###########


########## Tcl recorder starts at 04/11/18 09:35:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" button.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 09:35:43 ###########


########## Tcl recorder starts at 04/11/18 09:41:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" lab12.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 09:41:16 ###########


########## Tcl recorder starts at 04/11/18 09:42:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" lab12.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 09:42:05 ###########


########## Tcl recorder starts at 04/11/18 09:42:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cla4.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 09:42:23 ###########


########## Tcl recorder starts at 04/11/18 09:43:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" cla4.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 09:43:27 ###########


########## Tcl recorder starts at 04/11/18 09:43:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" k.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 09:43:41 ###########


########## Tcl recorder starts at 04/11/18 09:43:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vlog2jhd\" k.v -p \"$install_dir/ispcpld/generic\" -predefine lab12.h"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 09:43:43 ###########


########## Tcl recorder starts at 04/11/18 09:43:51 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lab12_top.cmd w} rspFile] {
	puts stderr "Cannot create response file lab12_top.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lab12.sty
PROJECT: lab12_top
WORKING_PATH: \"$proj_dir\"
MODULE: lab12_top
VERILOG_FILE_LIST: \"$install_dir/ispcpld/../cae_library/synthesis/verilog/mach.v\" lab12.h cla4.v k.v lab12.v
OUTPUT_FILE_NAME: lab12_top
SUFFIX_NAME: edi
Vlog_std_v2001: true
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DUP: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -rem -e lab12_top -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12_top.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lab12_top.edi -out lab12_top.bl0 -err automake.err -log lab12_top.log -prj lab12 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12_top.bl0 -collapse none -reduce none -err automake.err  -keepwires"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lab12_top.bl1\" -o \"lab12.bl2\" -omod \"lab12\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lab12 -lci lab12.lct -log lab12.imp -err automake.err -tti lab12.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -blifopt lab12.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lab12.bl2 -sweep -mergefb -err automake.err -o lab12.bl3 @lab12.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -diofft lab12.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lab12.bl3 -family AMDMACH -idev van -o lab12.bl4 -oxrf lab12.xrf -err automake.err @lab12.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lab12.lct -dev lc4k -prefit lab12.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lab12.bl4 -out lab12.bl5 -err automake.err -log lab12.log -mod lab12_top @lab12.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lab12.rs1 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs1: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -nojed -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lab12.rs2 w} rspFile] {
	puts stderr "Cannot create response file lab12.rs2: $rspFile"
} else {
	puts $rspFile "-i lab12.bl5 -lci lab12.lct -d m4e_256_96 -lco lab12.lco -html_rpt -fti lab12.fti -fmt PLA -tto lab12.tt4 -eqn lab12.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lab12.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lab12.rs1
file delete lab12.rs2
if [runCmd "\"$cpld_bin/tda\" -i lab12.bl5 -o lab12.tda -lci lab12.lct -dev m4e_256_96 -family lc4k -mod lab12_top -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lab12 -if lab12.jed -j2s -log lab12.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/18 09:43:51 ###########

