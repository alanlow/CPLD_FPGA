
########## Tcl recorder starts at 05/05/20 16:50:05 ##########

set version "2.0"
set proj_dir "C:/Users/alanlow/Documents/GitHub/CPLD_FPGA/LATTICE"
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
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler-bypass.sty
PROJECT: KEPLER_TL
WORKING_PATH: \"$proj_dir\"
MODULE: KEPLER_TL
VHDL_FILE_LIST: kepler_tl.vhd
OUTPUT_FILE_NAME: KEPLER_TL
SUFFIX_NAME: edi
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
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e KEPLER_TL -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler-bypass -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" KEPLER_TL.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler-bypass.bl2\" -omod \"kepler-bypass\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler-bypass -lci kepler-bypass.lct -log kepler-bypass.imp -err automake.err -tti kepler-bypass.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler-bypass.lct -blifopt kepler-bypass.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler-bypass.bl2 -sweep -mergefb -err automake.err -o kepler-bypass.bl3 @kepler-bypass.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler-bypass.lct -dev lc4k -diofft kepler-bypass.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler-bypass.bl3 -family AMDMACH -idev van -o kepler-bypass.bl4 -oxrf kepler-bypass.xrf -err automake.err @kepler-bypass.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler-bypass.lct -dev lc4k -prefit kepler-bypass.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler-bypass.bl4 -out kepler-bypass.bl5 -err automake.err -log kepler-bypass.log -mod KEPLER_TL @kepler-bypass.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler-bypass.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler-bypass.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler-bypass.bl5 -lci kepler-bypass.lct -d m4s_64_32 -lco kepler-bypass.lco -html_rpt -fti kepler-bypass.fti -fmt PLA -tto kepler-bypass.tt4 -nojed -eqn kepler-bypass.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler-bypass.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler-bypass.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler-bypass.bl5 -lci kepler-bypass.lct -d m4s_64_32 -lco kepler-bypass.lco -html_rpt -fti kepler-bypass.fti -fmt PLA -tto kepler-bypass.tt4 -eqn kepler-bypass.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler-bypass.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler-bypass.rs1
file delete kepler-bypass.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler-bypass.bl5 -o kepler-bypass.tda -lci kepler-bypass.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler-bypass -if kepler-bypass.jed -j2s -log kepler-bypass.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 16:50:05 ###########


########## Tcl recorder starts at 05/05/20 16:50:30 ##########

# Commands to make the Process: 
# ISC-1532 File
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler-bypass -if kepler-bypass.jed -j2i "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 16:50:30 ###########


########## Tcl recorder starts at 05/05/20 16:50:37 ##########

# Commands to make the Process: 
# Timing Analysis
# - none -
# Application to view the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/timing\" -prj \"kepler-bypass\" -tti \"kepler-bypass.tt4\" -gui -dir \"$proj_dir\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 16:50:37 ###########


########## Tcl recorder starts at 05/05/20 16:50:50 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src kepler-bypass.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_32.dev\" -postfit -lci kepler-bypass.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 16:50:50 ###########


########## Tcl recorder starts at 05/05/20 16:52:22 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i kepler-bypass.bl5 -o kepler-bypass.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src kepler-bypass.bl5 -type BLIF -presrc kepler-bypass.bl3 -crf kepler-bypass.crf -sif kepler-bypass.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_32.dev\" -lci kepler-bypass.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 16:52:22 ###########


########## Tcl recorder starts at 05/05/20 17:02:07 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open kepler-bypass.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler-bypass.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler-bypass.bl5 -lci kepler-bypass.lct -d m4s_64_32 -lco kepler-bypass.lco -html_rpt -fti kepler-bypass.fti -fmt PLA -tto kepler-bypass.tt4 -nojed -eqn kepler-bypass.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler-bypass.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler-bypass.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler-bypass.bl5 -lci kepler-bypass.lct -d m4s_64_32 -lco kepler-bypass.lco -html_rpt -fti kepler-bypass.fti -fmt PLA -tto kepler-bypass.tt4 -eqn kepler-bypass.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler-bypass.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler-bypass.rs1
file delete kepler-bypass.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler-bypass.bl5 -o kepler-bypass.tda -lci kepler-bypass.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler-bypass -if kepler-bypass.jed -j2s -log kepler-bypass.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 17:02:07 ###########


########## Tcl recorder starts at 05/05/20 17:02:11 ##########

# Commands to make the Process: 
# Timing Analysis
# - none -
# Application to view the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/timing\" -prj \"kepler-bypass\" -tti \"kepler-bypass.tt4\" -gui -dir \"$proj_dir\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 17:02:11 ###########


########## Tcl recorder starts at 05/05/20 17:02:53 ##########

# Commands to make the Process: 
# ISC-1532 File
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler-bypass -if kepler-bypass.jed -j2i "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 17:02:53 ###########


########## Tcl recorder starts at 05/05/20 17:02:59 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src kepler-bypass.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_32.dev\" -postfit -lci kepler-bypass.lco
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 17:02:59 ###########


########## Tcl recorder starts at 05/05/20 17:03:12 ##########

# Commands to make the Process: 
# Post-Fit Re-Compile
# - none -
# Application to view the Process: 
# Post-Fit Re-Compile
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src kepler-bypass.bl5 -type BLIF -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_32.dev\" -lci kepler-bypass.lct -prc kepler-bypass.lco -log kepler-bypass.log -touch kepler-bypass.fti
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/05/20 17:03:12 ###########

