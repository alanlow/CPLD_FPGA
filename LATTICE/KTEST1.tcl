
########## Tcl recorder starts at 04/10/20 12:42:40 ##########

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
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 12:42:40 ###########


########## Tcl recorder starts at 04/10/20 12:52:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 12:52:24 ###########


########## Tcl recorder starts at 04/10/20 14:30:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open PPS_COUNT_lse.env w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open PPS_COUNT.synproj w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top PPS_COUNT
-vhd pps_count.vhd
-output_edif PPS_COUNT.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"PPS_COUNT.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete PPS_COUNT_lse.env
file delete PPS_COUNT.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf PPS_COUNT.edi -out PPS_COUNT.bl0 -err automake.err -log PPS_COUNT.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" PPS_COUNT.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"PPS_COUNT.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod PPS_COUNT @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod PPS_COUNT -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 14:30:09 ###########


########## Tcl recorder starts at 04/10/20 14:30:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 14:30:41 ###########


########## Tcl recorder starts at 04/10/20 14:30:44 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open PPS_COUNT_lse.env w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open PPS_COUNT.synproj w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top PPS_COUNT
-vhd pps_count.vhd
-output_edif PPS_COUNT.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"PPS_COUNT.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete PPS_COUNT_lse.env
file delete PPS_COUNT.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf PPS_COUNT.edi -out PPS_COUNT.bl0 -err automake.err -log PPS_COUNT.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" PPS_COUNT.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"PPS_COUNT.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod PPS_COUNT @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod PPS_COUNT -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 14:30:45 ###########


########## Tcl recorder starts at 04/10/20 14:31:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 14:31:32 ###########


########## Tcl recorder starts at 04/10/20 14:31:35 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open PPS_COUNT_lse.env w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open PPS_COUNT.synproj w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top PPS_COUNT
-vhd pps_count.vhd
-output_edif PPS_COUNT.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"PPS_COUNT.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete PPS_COUNT_lse.env
file delete PPS_COUNT.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf PPS_COUNT.edi -out PPS_COUNT.bl0 -err automake.err -log PPS_COUNT.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" PPS_COUNT.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"PPS_COUNT.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod PPS_COUNT @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod PPS_COUNT -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 14:31:35 ###########


########## Tcl recorder starts at 04/10/20 14:32:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 14:32:20 ###########


########## Tcl recorder starts at 04/10/20 14:32:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open PPS_COUNT_lse.env w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open PPS_COUNT.synproj w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top PPS_COUNT
-vhd pps_count.vhd
-output_edif PPS_COUNT.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"PPS_COUNT.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete PPS_COUNT_lse.env
file delete PPS_COUNT.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf PPS_COUNT.edi -out PPS_COUNT.bl0 -err automake.err -log PPS_COUNT.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" PPS_COUNT.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"PPS_COUNT.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod PPS_COUNT @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod PPS_COUNT -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 14:32:30 ###########


########## Tcl recorder starts at 04/10/20 14:41:12 ##########

# Commands to make the Process: 
# Timing Report
if [runCmd "\"$cpld_bin/timer\" -inp \"ktest1.tt4\" -lci \"ktest1.lct\" -trp \"ktest1.trp\" -exf \"PPS_COUNT.exf\" -lco \"ktest1.lco\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 14:41:12 ###########


########## Tcl recorder starts at 04/10/20 14:41:37 ##########

# Commands to make the Process: 
# Timing Analysis
# - none -
# Application to view the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/timing\" -prj \"ktest1\" -tti \"ktest1.tt4\" -gui -dir \"$proj_dir\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 14:41:37 ###########


########## Tcl recorder starts at 04/10/20 14:56:19 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src ktest1.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4e_64_32.dev\" -postfit -lci ktest1.lco
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

########## Tcl recorder end at 04/10/20 14:56:19 ###########


########## Tcl recorder starts at 04/10/20 15:09:33 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   pps_count.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:09:33 ###########


########## Tcl recorder starts at 04/10/20 15:15:29 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:15:29 ###########


########## Tcl recorder starts at 04/10/20 15:21:27 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:21:27 ###########


########## Tcl recorder starts at 04/10/20 15:22:42 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:22:42 ###########


########## Tcl recorder starts at 04/10/20 15:23:34 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:23:34 ###########


########## Tcl recorder starts at 04/10/20 15:24:19 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:24:19 ###########


########## Tcl recorder starts at 04/10/20 15:28:46 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:28:47 ###########


########## Tcl recorder starts at 04/10/20 15:31:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:31:20 ###########


########## Tcl recorder starts at 04/10/20 15:32:08 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open PPS_COUNT_lse.env w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open PPS_COUNT.synproj w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top PPS_COUNT
-vhd pps_count.vhd
-output_edif PPS_COUNT.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"PPS_COUNT.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete PPS_COUNT_lse.env
file delete PPS_COUNT.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf PPS_COUNT.edi -out PPS_COUNT.bl0 -err automake.err -log PPS_COUNT.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" PPS_COUNT.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"PPS_COUNT.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod PPS_COUNT @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod PPS_COUNT -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:32:09 ###########


########## Tcl recorder starts at 04/10/20 15:32:30 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhd2naf\" -tfi -proj ktest1 -mod PPS_COUNT -out PPS_COUNT -tpl \"$install_dir/ispcpld/generic/vhdl/testbnch.tft\" -ext vht pps_count.vhd"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:32:30 ###########


########## Tcl recorder starts at 04/10/20 15:36:59 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   pps_count.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:36:59 ###########


########## Tcl recorder starts at 04/10/20 15:37:55 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:37:55 ###########


########## Tcl recorder starts at 04/10/20 15:38:28 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:38:28 ###########


########## Tcl recorder starts at 04/10/20 15:42:40 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:42:40 ###########


########## Tcl recorder starts at 04/10/20 15:43:36 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:43:36 ###########


########## Tcl recorder starts at 04/10/20 15:44:56 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:44:56 ###########


########## Tcl recorder starts at 04/10/20 15:48:34 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:48:34 ###########


########## Tcl recorder starts at 04/10/20 15:49:30 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:49:30 ###########


########## Tcl recorder starts at 04/10/20 15:54:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:54:36 ###########


########## Tcl recorder starts at 04/10/20 15:54:44 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open PPS_COUNT_lse.env w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open PPS_COUNT.synproj w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top PPS_COUNT
-vhd pps_count.vhd
-output_edif PPS_COUNT.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"PPS_COUNT.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete PPS_COUNT_lse.env
file delete PPS_COUNT.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf PPS_COUNT.edi -out PPS_COUNT.bl0 -err automake.err -log PPS_COUNT.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" PPS_COUNT.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"PPS_COUNT.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod PPS_COUNT @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod PPS_COUNT -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:54:44 ###########


########## Tcl recorder starts at 04/10/20 15:55:01 ##########

# Commands to make the Process: 
# Timing Analysis
# - none -
# Application to view the Process: 
# Timing Analysis
if [runCmd "\"$cpld_bin/timing\" -prj \"ktest1\" -tti \"ktest1.tt4\" -gui -dir \"$proj_dir\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:55:01 ###########


########## Tcl recorder starts at 04/10/20 15:55:26 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 15:55:26 ###########


########## Tcl recorder starts at 04/10/20 16:00:32 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   pps_count.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   pps_count.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl PPS_COUNT pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 16:00:32 ###########


########## Tcl recorder starts at 04/10/20 16:10:01 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 16:10:01 ###########


########## Tcl recorder starts at 04/10/20 16:16:26 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 16:16:26 ###########


########## Tcl recorder starts at 04/10/20 16:22:40 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 16:22:40 ###########


########## Tcl recorder starts at 04/10/20 17:58:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" adc_buf.vhd -o adc_buf.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 17:58:31 ###########


########## Tcl recorder starts at 04/10/20 18:04:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" adc_buf.vhd -o adc_buf.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:04:43 ###########


########## Tcl recorder starts at 04/10/20 18:04:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open ADC_BUF_lse.env w} rspFile] {
	puts stderr "Cannot create response file ADC_BUF_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open ADC_BUF.synproj w} rspFile] {
	puts stderr "Cannot create response file ADC_BUF.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top ADC_BUF
-vhd adc_buf.vhd
-output_edif ADC_BUF.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"ADC_BUF.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ADC_BUF_lse.env
file delete ADC_BUF.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf ADC_BUF.edi -out ADC_BUF.bl0 -err automake.err -log ADC_BUF.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ADC_BUF.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"ADC_BUF.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod ADC_BUF @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod ADC_BUF -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:04:58 ###########


########## Tcl recorder starts at 04/10/20 18:07:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" adc_buf.vhd -o adc_buf.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:07:04 ###########


########## Tcl recorder starts at 04/10/20 18:07:13 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open ADC_BUF_lse.env w} rspFile] {
	puts stderr "Cannot create response file ADC_BUF_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open ADC_BUF.synproj w} rspFile] {
	puts stderr "Cannot create response file ADC_BUF.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top ADC_BUF
-vhd adc_buf.vhd
-output_edif ADC_BUF.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"ADC_BUF.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ADC_BUF_lse.env
file delete ADC_BUF.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf ADC_BUF.edi -out ADC_BUF.bl0 -err automake.err -log ADC_BUF.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ADC_BUF.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"ADC_BUF.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod ADC_BUF @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod ADC_BUF -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:07:13 ###########


########## Tcl recorder starts at 04/10/20 18:08:02 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhd2naf\" -tfi -proj ktest1 -mod ADC_BUF -out ADC_BUF -tpl \"$install_dir/ispcpld/generic/vhdl/testbnch.tft\" -ext vht adc_buf.vhd"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:08:02 ###########


########## Tcl recorder starts at 04/10/20 18:21:10 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: adc_buff_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open adc_buff_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   adc_buf.vhd
#vcom adc_buff_tb.vhd
#stimulus vhdl ADC_BUF adc_buff_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo adc_buff_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" adc_buff_tb.rsp adc_buff_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete adc_buff_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open adc_buff_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl adc_buff_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"adc_buff_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:21:10 ###########


########## Tcl recorder starts at 04/10/20 18:27:35 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   adc_buf.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: pps_counter_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open pps_counter_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   adc_buf.vhd
#vcom pps_counter_tb.vhd
#stimulus vhdl ADC_BUF pps_counter_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo pps_counter_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" pps_counter_tb.rsp pps_counter_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete pps_counter_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open pps_counter_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file pps_counter_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl pps_counter_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"pps_counter_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:27:35 ###########


########## Tcl recorder starts at 04/10/20 18:28:59 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: adc_buff_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open adc_buff_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   adc_buf.vhd
#vcom adc_buff_tb.vhd
#stimulus vhdl ADC_BUF adc_buff_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo adc_buff_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" adc_buff_tb.rsp adc_buff_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete adc_buff_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open adc_buff_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl adc_buff_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"adc_buff_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:28:59 ###########


########## Tcl recorder starts at 04/10/20 18:30:08 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open ktest1.rss w} rspFile] {
	puts stderr "Cannot create response file ktest1.rss: $rspFile"
} else {
	puts $rspFile "-i \"ktest1.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"ktest1.tt4\" -lci \"ktest1.lct\" -prj \"ktest1\" -dir \"$proj_dir\" -err automake.err -log \"ktest1.nrp\" -exf \"ADC_BUF.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@ktest1.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rss
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: adc_buff_tb_vhda.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open adc_buff_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do ktest1.vatd
#vcom ktest1.vho
#vcom adc_buff_tb.vhd
#stimulus vhdl ADC_BUF adc_buff_tb.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=ktest1.sdf
#youdo adc_buff_tb_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" adc_buff_tb.rsp adc_buff_tb.tado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete adc_buff_tb.rsp
# Application to view the Process: 
# Aldec VHDL Timing Simulation
if [catch {open adc_buff_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl adc_buff_tb.tado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"adc_buff_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:30:08 ###########


########## Tcl recorder starts at 04/10/20 18:31:12 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: adc_buff_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open adc_buff_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   adc_buf.vhd
#vcom adc_buff_tb.vhd
#stimulus vhdl ADC_BUF adc_buff_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo adc_buff_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" adc_buff_tb.rsp adc_buff_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete adc_buff_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open adc_buff_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl adc_buff_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"adc_buff_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:31:12 ###########


########## Tcl recorder starts at 04/10/20 18:32:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" adc_buf.vhd -o adc_buf.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:32:26 ###########


########## Tcl recorder starts at 04/10/20 18:32:36 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   adc_buf.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: adc_buff_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open adc_buff_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   adc_buf.vhd
#vcom adc_buff_tb.vhd
#stimulus vhdl ADC_BUF adc_buff_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo adc_buff_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" adc_buff_tb.rsp adc_buff_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete adc_buff_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open adc_buff_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl adc_buff_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"adc_buff_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:32:36 ###########


########## Tcl recorder starts at 04/10/20 18:33:28 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open adc_buff_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl adc_buff_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"adc_buff_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:33:28 ###########


########## Tcl recorder starts at 04/10/20 18:34:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" adc_buf.vhd -o adc_buf.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:34:13 ###########


########## Tcl recorder starts at 04/10/20 18:34:35 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open ADC_BUF_lse.env w} rspFile] {
	puts stderr "Cannot create response file ADC_BUF_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open ADC_BUF.synproj w} rspFile] {
	puts stderr "Cannot create response file ADC_BUF.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top ADC_BUF
-vhd adc_buf.vhd
-output_edif ADC_BUF.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"ADC_BUF.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ADC_BUF_lse.env
file delete ADC_BUF.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf ADC_BUF.edi -out ADC_BUF.bl0 -err automake.err -log ADC_BUF.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ADC_BUF.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"ADC_BUF.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod ADC_BUF @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod ADC_BUF -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:34:35 ###########


########## Tcl recorder starts at 04/10/20 18:34:52 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   adc_buf.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: adc_buff_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open adc_buff_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   adc_buf.vhd
#vcom adc_buff_tb.vhd
#stimulus vhdl ADC_BUF adc_buff_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo adc_buff_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" adc_buff_tb.rsp adc_buff_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete adc_buff_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open adc_buff_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file adc_buff_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl adc_buff_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"adc_buff_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 18:34:52 ###########


########## Tcl recorder starts at 04/10/20 20:13:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 20:13:11 ###########


########## Tcl recorder starts at 04/10/20 20:40:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 20:40:30 ###########


########## Tcl recorder starts at 04/10/20 20:56:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 20:56:49 ###########


########## Tcl recorder starts at 04/10/20 21:12:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:12:38 ###########


########## Tcl recorder starts at 04/10/20 21:15:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:15:40 ###########


########## Tcl recorder starts at 04/10/20 21:21:41 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:21:41 ###########


########## Tcl recorder starts at 04/10/20 21:22:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:22:31 ###########


########## Tcl recorder starts at 04/10/20 21:22:40 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:22:40 ###########


########## Tcl recorder starts at 04/10/20 21:25:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:25:51 ###########


########## Tcl recorder starts at 04/10/20 21:25:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:25:58 ###########


########## Tcl recorder starts at 04/10/20 21:27:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:27:16 ###########


########## Tcl recorder starts at 04/10/20 21:27:18 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:27:18 ###########


########## Tcl recorder starts at 04/10/20 21:27:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:27:44 ###########


########## Tcl recorder starts at 04/10/20 21:27:50 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:27:50 ###########


########## Tcl recorder starts at 04/10/20 21:37:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:37:23 ###########


########## Tcl recorder starts at 04/10/20 21:37:33 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:37:33 ###########


########## Tcl recorder starts at 04/10/20 21:38:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:38:34 ###########


########## Tcl recorder starts at 04/10/20 21:38:38 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:38:38 ###########


########## Tcl recorder starts at 04/10/20 21:49:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:49:01 ###########


########## Tcl recorder starts at 04/10/20 21:49:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:49:58 ###########


########## Tcl recorder starts at 04/10/20 21:50:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:50:01 ###########


########## Tcl recorder starts at 04/10/20 21:50:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:50:48 ###########


########## Tcl recorder starts at 04/10/20 21:51:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:51:06 ###########


########## Tcl recorder starts at 04/10/20 21:51:20 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:51:21 ###########


########## Tcl recorder starts at 04/10/20 21:56:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:56:05 ###########


########## Tcl recorder starts at 04/10/20 21:56:14 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:56:14 ###########


########## Tcl recorder starts at 04/10/20 21:56:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:56:34 ###########


########## Tcl recorder starts at 04/10/20 21:56:43 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 21:56:43 ###########


########## Tcl recorder starts at 04/10/20 22:02:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:02:11 ###########


########## Tcl recorder starts at 04/10/20 22:02:18 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:02:18 ###########


########## Tcl recorder starts at 04/10/20 22:03:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:03:25 ###########


########## Tcl recorder starts at 04/10/20 22:03:34 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:03:34 ###########


########## Tcl recorder starts at 04/10/20 22:08:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:08:01 ###########


########## Tcl recorder starts at 04/10/20 22:08:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:08:09 ###########


########## Tcl recorder starts at 04/10/20 22:09:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:09:02 ###########


########## Tcl recorder starts at 04/10/20 22:09:08 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:09:08 ###########


########## Tcl recorder starts at 04/10/20 22:10:20 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhd2naf\" -tfi -proj ktest1 -mod SPI_MOD -out SPI_MOD -tpl \"$install_dir/ispcpld/generic/vhdl/testbnch.tft\" -ext vht spi_mod.vhd"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:10:20 ###########


########## Tcl recorder starts at 04/10/20 22:32:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:32:31 ###########


########## Tcl recorder starts at 04/10/20 22:32:54 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i ktest1.bl5 -o ktest1.sif"] {
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
	puts $rspFile "-nodal -src ktest1.bl5 -type BLIF -presrc ktest1.bl3 -crf ktest1.crf -sif ktest1.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4e_64_32.dev\" -lci ktest1.lct
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

########## Tcl recorder end at 04/10/20 22:32:54 ###########


########## Tcl recorder starts at 04/10/20 22:33:07 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:33:07 ###########


########## Tcl recorder starts at 04/10/20 22:40:01 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:40:01 ###########


########## Tcl recorder starts at 04/10/20 22:41:43 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:41:43 ###########


########## Tcl recorder starts at 04/10/20 22:44:50 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:44:50 ###########


########## Tcl recorder starts at 04/10/20 22:45:59 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:45:59 ###########


########## Tcl recorder starts at 04/10/20 22:47:52 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:47:52 ###########


########## Tcl recorder starts at 04/10/20 22:51:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:51:43 ###########


########## Tcl recorder starts at 04/10/20 22:51:49 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:51:49 ###########


########## Tcl recorder starts at 04/10/20 22:55:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:55:53 ###########


########## Tcl recorder starts at 04/10/20 22:56:08 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 22:56:08 ###########


########## Tcl recorder starts at 04/10/20 23:12:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:12:38 ###########


########## Tcl recorder starts at 04/10/20 23:12:42 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:12:42 ###########


########## Tcl recorder starts at 04/10/20 23:13:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:13:06 ###########


########## Tcl recorder starts at 04/10/20 23:13:12 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:13:12 ###########


########## Tcl recorder starts at 04/10/20 23:16:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:16:35 ###########


########## Tcl recorder starts at 04/10/20 23:16:41 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:16:41 ###########


########## Tcl recorder starts at 04/10/20 23:17:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:17:43 ###########


########## Tcl recorder starts at 04/10/20 23:17:47 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:17:47 ###########


########## Tcl recorder starts at 04/10/20 23:18:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:18:03 ###########


########## Tcl recorder starts at 04/10/20 23:18:07 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:18:07 ###########


########## Tcl recorder starts at 04/10/20 23:22:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:22:21 ###########


########## Tcl recorder starts at 04/10/20 23:22:25 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:22:25 ###########


########## Tcl recorder starts at 04/10/20 23:28:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:28:24 ###########


########## Tcl recorder starts at 04/10/20 23:30:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:30:31 ###########


########## Tcl recorder starts at 04/10/20 23:30:34 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:30:34 ###########


########## Tcl recorder starts at 04/10/20 23:31:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:31:12 ###########


########## Tcl recorder starts at 04/10/20 23:31:17 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:31:17 ###########


########## Tcl recorder starts at 04/10/20 23:32:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:32:52 ###########


########## Tcl recorder starts at 04/10/20 23:32:55 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:32:55 ###########


########## Tcl recorder starts at 04/10/20 23:33:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:33:27 ###########


########## Tcl recorder starts at 04/10/20 23:33:34 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:33:34 ###########


########## Tcl recorder starts at 04/10/20 23:34:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:34:22 ###########


########## Tcl recorder starts at 04/10/20 23:34:25 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:34:25 ###########


########## Tcl recorder starts at 04/10/20 23:40:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:40:02 ###########


########## Tcl recorder starts at 04/10/20 23:41:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/10/20 23:41:06 ###########


########## Tcl recorder starts at 04/11/20 00:44:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:44:18 ###########


########## Tcl recorder starts at 04/11/20 00:44:22 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:44:22 ###########


########## Tcl recorder starts at 04/11/20 00:49:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:49:42 ###########


########## Tcl recorder starts at 04/11/20 00:49:49 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:49:49 ###########


########## Tcl recorder starts at 04/11/20 00:50:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:50:02 ###########


########## Tcl recorder starts at 04/11/20 00:50:05 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:50:05 ###########


########## Tcl recorder starts at 04/11/20 00:52:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:52:47 ###########


########## Tcl recorder starts at 04/11/20 00:52:50 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:52:50 ###########


########## Tcl recorder starts at 04/11/20 00:53:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:53:11 ###########


########## Tcl recorder starts at 04/11/20 00:53:19 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:53:19 ###########


########## Tcl recorder starts at 04/11/20 00:55:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:55:02 ###########


########## Tcl recorder starts at 04/11/20 00:55:04 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:55:04 ###########


########## Tcl recorder starts at 04/11/20 00:57:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:57:17 ###########


########## Tcl recorder starts at 04/11/20 00:57:22 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:57:22 ###########


########## Tcl recorder starts at 04/11/20 00:57:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:57:54 ###########


########## Tcl recorder starts at 04/11/20 00:57:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 00:57:58 ###########


########## Tcl recorder starts at 04/11/20 01:00:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:00:27 ###########


########## Tcl recorder starts at 04/11/20 01:00:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:00:31 ###########


########## Tcl recorder starts at 04/11/20 01:03:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:03:12 ###########


########## Tcl recorder starts at 04/11/20 01:03:17 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:03:17 ###########


########## Tcl recorder starts at 04/11/20 01:04:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:04:59 ###########


########## Tcl recorder starts at 04/11/20 01:05:02 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:05:02 ###########


########## Tcl recorder starts at 04/11/20 01:05:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:05:20 ###########


########## Tcl recorder starts at 04/11/20 01:05:23 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:05:23 ###########


########## Tcl recorder starts at 04/11/20 01:06:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:06:25 ###########


########## Tcl recorder starts at 04/11/20 01:06:29 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:06:29 ###########


########## Tcl recorder starts at 04/11/20 01:07:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:07:40 ###########


########## Tcl recorder starts at 04/11/20 01:07:46 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:07:46 ###########


########## Tcl recorder starts at 04/11/20 01:08:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:08:08 ###########


########## Tcl recorder starts at 04/11/20 01:08:13 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:08:13 ###########


########## Tcl recorder starts at 04/11/20 01:13:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:13:49 ###########


########## Tcl recorder starts at 04/11/20 01:13:53 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:13:53 ###########


########## Tcl recorder starts at 04/11/20 01:14:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:14:18 ###########


########## Tcl recorder starts at 04/11/20 01:14:23 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:14:23 ###########


########## Tcl recorder starts at 04/11/20 01:16:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:16:08 ###########


########## Tcl recorder starts at 04/11/20 01:16:12 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:16:12 ###########


########## Tcl recorder starts at 04/11/20 01:16:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:16:51 ###########


########## Tcl recorder starts at 04/11/20 01:16:54 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:16:54 ###########


########## Tcl recorder starts at 04/11/20 01:17:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:17:07 ###########


########## Tcl recorder starts at 04/11/20 01:17:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:17:09 ###########


########## Tcl recorder starts at 04/11/20 01:17:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:17:21 ###########


########## Tcl recorder starts at 04/11/20 01:17:24 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:17:24 ###########


########## Tcl recorder starts at 04/11/20 01:21:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:21:48 ###########


########## Tcl recorder starts at 04/11/20 01:21:53 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:21:53 ###########


########## Tcl recorder starts at 04/11/20 01:22:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:22:48 ###########


########## Tcl recorder starts at 04/11/20 01:22:52 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:22:52 ###########


########## Tcl recorder starts at 04/11/20 01:23:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:23:28 ###########


########## Tcl recorder starts at 04/11/20 01:23:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:23:30 ###########


########## Tcl recorder starts at 04/11/20 01:25:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:25:59 ###########


########## Tcl recorder starts at 04/11/20 01:26:04 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:26:04 ###########


########## Tcl recorder starts at 04/11/20 01:27:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:27:36 ###########


########## Tcl recorder starts at 04/11/20 01:27:39 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:27:39 ###########


########## Tcl recorder starts at 04/11/20 01:28:03 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:28:03 ###########


########## Tcl recorder starts at 04/11/20 01:32:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:32:10 ###########


########## Tcl recorder starts at 04/11/20 01:32:15 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:32:15 ###########


########## Tcl recorder starts at 04/11/20 01:32:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:32:26 ###########


########## Tcl recorder starts at 04/11/20 01:32:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:32:31 ###########


########## Tcl recorder starts at 04/11/20 01:33:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:33:12 ###########


########## Tcl recorder starts at 04/11/20 01:33:16 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:33:16 ###########


########## Tcl recorder starts at 04/11/20 01:33:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:33:41 ###########


########## Tcl recorder starts at 04/11/20 01:33:46 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:33:46 ###########


########## Tcl recorder starts at 04/11/20 01:34:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:34:28 ###########


########## Tcl recorder starts at 04/11/20 01:34:34 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:34:34 ###########


########## Tcl recorder starts at 04/11/20 01:43:22 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:43:22 ###########


########## Tcl recorder starts at 04/11/20 01:43:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:43:26 ###########


########## Tcl recorder starts at 04/11/20 01:44:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:44:52 ###########


########## Tcl recorder starts at 04/11/20 01:44:55 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:44:55 ###########


########## Tcl recorder starts at 04/11/20 01:45:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:45:18 ###########


########## Tcl recorder starts at 04/11/20 01:45:24 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 01:45:24 ###########


########## Tcl recorder starts at 04/11/20 08:50:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:50:35 ###########


########## Tcl recorder starts at 04/11/20 08:50:47 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:50:47 ###########


########## Tcl recorder starts at 04/11/20 08:51:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:51:04 ###########


########## Tcl recorder starts at 04/11/20 08:51:08 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:51:08 ###########


########## Tcl recorder starts at 04/11/20 08:53:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:53:27 ###########


########## Tcl recorder starts at 04/11/20 08:53:33 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:53:33 ###########


########## Tcl recorder starts at 04/11/20 08:54:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:54:08 ###########


########## Tcl recorder starts at 04/11/20 08:54:21 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:54:21 ###########


########## Tcl recorder starts at 04/11/20 08:56:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:56:30 ###########


########## Tcl recorder starts at 04/11/20 08:56:36 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:56:36 ###########


########## Tcl recorder starts at 04/11/20 08:58:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:58:44 ###########


########## Tcl recorder starts at 04/11/20 08:58:49 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 08:58:50 ###########


########## Tcl recorder starts at 04/11/20 09:03:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:03:23 ###########


########## Tcl recorder starts at 04/11/20 09:03:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:03:26 ###########


########## Tcl recorder starts at 04/11/20 09:05:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:05:54 ###########


########## Tcl recorder starts at 04/11/20 09:05:59 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:05:59 ###########


########## Tcl recorder starts at 04/11/20 09:08:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:08:23 ###########


########## Tcl recorder starts at 04/11/20 09:08:35 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:08:35 ###########


########## Tcl recorder starts at 04/11/20 09:18:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:18:51 ###########


########## Tcl recorder starts at 04/11/20 09:18:59 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:18:59 ###########


########## Tcl recorder starts at 04/11/20 09:19:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:19:20 ###########


########## Tcl recorder starts at 04/11/20 09:19:29 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:19:29 ###########


########## Tcl recorder starts at 04/11/20 09:19:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:19:43 ###########


########## Tcl recorder starts at 04/11/20 09:19:45 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:19:45 ###########


########## Tcl recorder starts at 04/11/20 09:20:16 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:20:16 ###########


########## Tcl recorder starts at 04/11/20 09:20:22 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:20:22 ###########


########## Tcl recorder starts at 04/11/20 09:34:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:34:39 ###########


########## Tcl recorder starts at 04/11/20 09:36:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:36:33 ###########


########## Tcl recorder starts at 04/11/20 09:36:48 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:36:48 ###########


########## Tcl recorder starts at 04/11/20 09:48:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:48:38 ###########


########## Tcl recorder starts at 04/11/20 09:52:37 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:52:37 ###########


########## Tcl recorder starts at 04/11/20 09:53:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:53:41 ###########


########## Tcl recorder starts at 04/11/20 09:54:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:54:57 ###########


########## Tcl recorder starts at 04/11/20 09:55:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:55:56 ###########


########## Tcl recorder starts at 04/11/20 09:55:59 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 09:55:59 ###########


########## Tcl recorder starts at 04/11/20 10:05:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:05:05 ###########


########## Tcl recorder starts at 04/11/20 10:05:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:05:46 ###########


########## Tcl recorder starts at 04/11/20 10:05:51 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:05:51 ###########


########## Tcl recorder starts at 04/11/20 10:06:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:06:39 ###########


########## Tcl recorder starts at 04/11/20 10:06:42 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:06:42 ###########


########## Tcl recorder starts at 04/11/20 10:07:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:07:02 ###########


########## Tcl recorder starts at 04/11/20 10:07:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:07:06 ###########


########## Tcl recorder starts at 04/11/20 10:07:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:07:44 ###########


########## Tcl recorder starts at 04/11/20 10:07:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:07:54 ###########


########## Tcl recorder starts at 04/11/20 10:08:12 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:08:12 ###########


########## Tcl recorder starts at 04/11/20 10:08:30 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:08:30 ###########


########## Tcl recorder starts at 04/11/20 10:08:40 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:08:40 ###########


########## Tcl recorder starts at 04/11/20 10:08:53 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:08:53 ###########


########## Tcl recorder starts at 04/11/20 10:09:14 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:09:14 ###########


########## Tcl recorder starts at 04/11/20 10:09:44 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:09:44 ###########


########## Tcl recorder starts at 04/11/20 10:10:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:10:02 ###########


########## Tcl recorder starts at 04/11/20 10:10:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:10:06 ###########


########## Tcl recorder starts at 04/11/20 10:10:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:10:20 ###########


########## Tcl recorder starts at 04/11/20 10:10:23 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:10:23 ###########


########## Tcl recorder starts at 04/11/20 10:11:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:11:27 ###########


########## Tcl recorder starts at 04/11/20 10:11:29 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:11:29 ###########


########## Tcl recorder starts at 04/11/20 10:12:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:12:33 ###########


########## Tcl recorder starts at 04/11/20 10:12:38 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:12:38 ###########


########## Tcl recorder starts at 04/11/20 10:37:23 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:37:23 ###########


########## Tcl recorder starts at 04/11/20 10:37:43 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:37:43 ###########


########## Tcl recorder starts at 04/11/20 10:38:15 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:38:15 ###########


########## Tcl recorder starts at 04/11/20 10:46:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:46:50 ###########


########## Tcl recorder starts at 04/11/20 10:46:54 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:46:54 ###########


########## Tcl recorder starts at 04/11/20 10:48:24 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:48:24 ###########


########## Tcl recorder starts at 04/11/20 10:48:48 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:48:48 ###########


########## Tcl recorder starts at 04/11/20 10:57:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:57:05 ###########


########## Tcl recorder starts at 04/11/20 10:57:38 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 10:57:38 ###########


########## Tcl recorder starts at 04/11/20 11:08:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 11:08:26 ###########


########## Tcl recorder starts at 04/11/20 11:08:32 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 11:08:32 ###########


########## Tcl recorder starts at 04/11/20 11:18:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 11:18:56 ###########


########## Tcl recorder starts at 04/11/20 11:19:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 11:19:01 ###########


########## Tcl recorder starts at 04/11/20 11:19:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 11:19:35 ###########


########## Tcl recorder starts at 04/11/20 11:19:40 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 11:19:40 ###########


########## Tcl recorder starts at 04/11/20 12:18:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:18:25 ###########


########## Tcl recorder starts at 04/11/20 12:18:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:18:31 ###########


########## Tcl recorder starts at 04/11/20 12:19:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:19:01 ###########


########## Tcl recorder starts at 04/11/20 12:19:05 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:19:05 ###########


########## Tcl recorder starts at 04/11/20 12:23:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:23:49 ###########


########## Tcl recorder starts at 04/11/20 12:23:54 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:23:54 ###########


########## Tcl recorder starts at 04/11/20 12:24:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:24:27 ###########


########## Tcl recorder starts at 04/11/20 12:24:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:24:31 ###########


########## Tcl recorder starts at 04/11/20 12:24:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:24:42 ###########


########## Tcl recorder starts at 04/11/20 12:24:46 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:24:46 ###########


########## Tcl recorder starts at 04/11/20 12:25:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:25:03 ###########


########## Tcl recorder starts at 04/11/20 12:25:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:25:07 ###########


########## Tcl recorder starts at 04/11/20 12:25:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:25:33 ###########


########## Tcl recorder starts at 04/11/20 12:25:38 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:25:38 ###########


########## Tcl recorder starts at 04/11/20 12:25:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:25:59 ###########


########## Tcl recorder starts at 04/11/20 12:26:03 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:26:03 ###########


########## Tcl recorder starts at 04/11/20 12:26:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:26:57 ###########


########## Tcl recorder starts at 04/11/20 12:27:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:27:01 ###########


########## Tcl recorder starts at 04/11/20 12:28:28 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:28:28 ###########


########## Tcl recorder starts at 04/11/20 12:28:32 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:28:32 ###########


########## Tcl recorder starts at 04/11/20 12:47:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:47:20 ###########


########## Tcl recorder starts at 04/11/20 12:47:23 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:47:23 ###########


########## Tcl recorder starts at 04/11/20 12:47:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:47:43 ###########


########## Tcl recorder starts at 04/11/20 12:47:47 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:47:47 ###########


########## Tcl recorder starts at 04/11/20 12:49:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:49:22 ###########


########## Tcl recorder starts at 04/11/20 12:49:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:49:26 ###########


########## Tcl recorder starts at 04/11/20 12:49:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:49:38 ###########


########## Tcl recorder starts at 04/11/20 12:49:41 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:49:41 ###########


########## Tcl recorder starts at 04/11/20 12:49:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:49:58 ###########


########## Tcl recorder starts at 04/11/20 12:50:02 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 12:50:02 ###########


########## Tcl recorder starts at 04/11/20 13:01:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:01:49 ###########


########## Tcl recorder starts at 04/11/20 13:01:53 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:01:53 ###########


########## Tcl recorder starts at 04/11/20 13:02:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:02:07 ###########


########## Tcl recorder starts at 04/11/20 13:02:11 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:02:11 ###########


########## Tcl recorder starts at 04/11/20 13:02:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:02:26 ###########


########## Tcl recorder starts at 04/11/20 13:02:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:02:30 ###########


########## Tcl recorder starts at 04/11/20 13:07:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:07:30 ###########


########## Tcl recorder starts at 04/11/20 13:07:37 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:07:37 ###########


########## Tcl recorder starts at 04/11/20 13:08:12 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:08:12 ###########


########## Tcl recorder starts at 04/11/20 13:36:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:36:33 ###########


########## Tcl recorder starts at 04/11/20 13:36:52 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:36:52 ###########


########## Tcl recorder starts at 04/11/20 13:37:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:37:41 ###########


########## Tcl recorder starts at 04/11/20 13:37:45 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:37:45 ###########


########## Tcl recorder starts at 04/11/20 13:39:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:39:55 ###########


########## Tcl recorder starts at 04/11/20 13:40:02 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:40:02 ###########


########## Tcl recorder starts at 04/11/20 13:40:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:40:47 ###########


########## Tcl recorder starts at 04/11/20 13:40:52 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:40:52 ###########


########## Tcl recorder starts at 04/11/20 13:41:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:41:30 ###########


########## Tcl recorder starts at 04/11/20 13:41:39 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:41:39 ###########


########## Tcl recorder starts at 04/11/20 13:51:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:51:25 ###########


########## Tcl recorder starts at 04/11/20 13:51:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:51:31 ###########


########## Tcl recorder starts at 04/11/20 13:53:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:53:36 ###########


########## Tcl recorder starts at 04/11/20 13:53:45 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open SPI_MOD_lse.env w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open SPI_MOD.synproj w} rspFile] {
	puts stderr "Cannot create response file SPI_MOD.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top SPI_MOD
-vhd spi_mod.vhd
-output_edif SPI_MOD.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"SPI_MOD.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete SPI_MOD_lse.env
file delete SPI_MOD.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf SPI_MOD.edi -out SPI_MOD.bl0 -err automake.err -log SPI_MOD.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" SPI_MOD.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"SPI_MOD.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod SPI_MOD @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod SPI_MOD -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:53:45 ###########


########## Tcl recorder starts at 04/11/20 13:55:20 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:55:20 ###########


########## Tcl recorder starts at 04/11/20 13:59:23 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 13:59:23 ###########


########## Tcl recorder starts at 04/11/20 14:00:36 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 14:00:36 ###########


########## Tcl recorder starts at 04/11/20 14:10:43 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 14:10:43 ###########


########## Tcl recorder starts at 04/11/20 14:16:22 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: spi_mod_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open spi_mod_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd
#vcom spi_mod_tb.vhd
#stimulus vhdl SPI_MOD spi_mod_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo spi_mod_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" spi_mod_tb.rsp spi_mod_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete spi_mod_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open spi_mod_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file spi_mod_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl spi_mod_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"spi_mod_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 14:16:22 ###########


########## Tcl recorder starts at 04/11/20 14:23:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 14:23:17 ###########


########## Tcl recorder starts at 04/11/20 14:38:21 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 14:38:21 ###########


########## Tcl recorder starts at 04/11/20 14:39:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 14:39:36 ###########


########## Tcl recorder starts at 04/11/20 14:39:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" adc_buf.vhd -o adc_buf.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 14:39:50 ###########


########## Tcl recorder starts at 04/11/20 14:45:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 14:45:02 ###########


########## Tcl recorder starts at 04/11/20 15:05:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:05:59 ###########


########## Tcl recorder starts at 04/11/20 15:06:24 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPPLER_TL_lse.env
file delete KEPPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPPLER_TL.edi -out KEPPLER_TL.bl0 -err automake.err -log KEPPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" KEPPLER_TL.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"KEPPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:06:24 ###########


########## Tcl recorder starts at 04/11/20 15:07:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:07:41 ###########


########## Tcl recorder starts at 04/11/20 15:07:47 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPPLER_TL_lse.env
file delete KEPPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPPLER_TL.edi -out KEPPLER_TL.bl0 -err automake.err -log KEPPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" KEPPLER_TL.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"KEPPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:07:47 ###########


########## Tcl recorder starts at 04/11/20 15:09:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:09:36 ###########


########## Tcl recorder starts at 04/11/20 15:09:40 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPPLER_TL_lse.env
file delete KEPPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPPLER_TL.edi -out KEPPLER_TL.bl0 -err automake.err -log KEPPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" KEPPLER_TL.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"KEPPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:09:40 ###########


########## Tcl recorder starts at 04/11/20 15:11:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:11:08 ###########


########## Tcl recorder starts at 04/11/20 15:11:13 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPPLER_TL
-vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPPLER_TL_lse.env
file delete KEPPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPPLER_TL.edi -out KEPPLER_TL.bl0 -err automake.err -log KEPPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" KEPPLER_TL.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"KEPPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:11:13 ###########


########## Tcl recorder starts at 04/11/20 15:12:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:12:14 ###########


########## Tcl recorder starts at 04/11/20 15:12:19 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPPLER_TL
-vhd kepler_tl.vhd
-output_edif KEPPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPPLER_TL_lse.env
file delete KEPPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPPLER_TL.edi -out KEPPLER_TL.bl0 -err automake.err -log KEPPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" KEPPLER_TL.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"KEPPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:12:19 ###########


########## Tcl recorder starts at 04/11/20 15:13:48 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:13:48 ###########


########## Tcl recorder starts at 04/11/20 15:13:56 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open PPS_COUNT_lse.env w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open PPS_COUNT.synproj w} rspFile] {
	puts stderr "Cannot create response file PPS_COUNT.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top PPS_COUNT
-vhd pps_count.vhd
-output_edif PPS_COUNT.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"PPS_COUNT.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete PPS_COUNT_lse.env
file delete PPS_COUNT.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf PPS_COUNT.edi -out PPS_COUNT.bl0 -err automake.err -log PPS_COUNT.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" PPS_COUNT.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"PPS_COUNT.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod PPS_COUNT @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod PPS_COUNT -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:13:56 ###########


########## Tcl recorder starts at 04/11/20 15:14:56 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:14:56 ###########


########## Tcl recorder starts at 04/11/20 15:14:59 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/mblflink\" \"PPS_COUNT.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod PPS_COUNT @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod PPS_COUNT -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:14:59 ###########


########## Tcl recorder starts at 04/11/20 15:27:56 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:27:56 ###########


########## Tcl recorder starts at 04/11/20 15:28:15 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src ktest1.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4e_64_32.dev\" -postfit -lci ktest1.lco
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

########## Tcl recorder end at 04/11/20 15:28:16 ###########


########## Tcl recorder starts at 04/11/20 15:29:11 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i ktest1.bl5 -o ktest1.sif"] {
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
	puts $rspFile "-nodal -src ktest1.bl5 -type BLIF -presrc ktest1.bl3 -crf ktest1.crf -sif ktest1.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4e_64_32.dev\" -lci ktest1.lct
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

########## Tcl recorder end at 04/11/20 15:29:11 ###########


########## Tcl recorder starts at 04/11/20 15:31:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:31:10 ###########


########## Tcl recorder starts at 04/11/20 15:31:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:31:31 ###########


########## Tcl recorder starts at 04/11/20 15:31:53 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:31:53 ###########


########## Tcl recorder starts at 04/11/20 15:31:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:31:58 ###########


########## Tcl recorder starts at 04/11/20 15:33:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:33:17 ###########


########## Tcl recorder starts at 04/11/20 15:33:20 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:33:20 ###########


########## Tcl recorder starts at 04/11/20 15:34:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:34:17 ###########


########## Tcl recorder starts at 04/11/20 15:34:23 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:34:23 ###########


########## Tcl recorder starts at 04/11/20 15:35:13 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:35:13 ###########


########## Tcl recorder starts at 04/11/20 15:35:16 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:35:16 ###########


########## Tcl recorder starts at 04/11/20 15:37:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:37:51 ###########


########## Tcl recorder starts at 04/11/20 15:37:55 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:37:55 ###########


########## Tcl recorder starts at 04/11/20 15:38:22 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src ktest1.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4e_64_32.dev\" -postfit -lci ktest1.lco
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

########## Tcl recorder end at 04/11/20 15:38:22 ###########


########## Tcl recorder starts at 04/11/20 15:39:33 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i ktest1.bl5 -o ktest1.sif"] {
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
	puts $rspFile "-nodal -src ktest1.bl5 -type BLIF -presrc ktest1.bl3 -crf ktest1.crf -sif ktest1.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4e_64_32.dev\" -lci ktest1.lct
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

########## Tcl recorder end at 04/11/20 15:39:33 ###########


########## Tcl recorder starts at 04/11/20 15:48:55 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:48:55 ###########


########## Tcl recorder starts at 04/11/20 15:49:09 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src ktest1.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4e_64_32.dev\" -postfit -lci ktest1.lco
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

########## Tcl recorder end at 04/11/20 15:49:09 ###########


########## Tcl recorder starts at 04/11/20 15:52:53 ##########

# Commands to make the Process: 
# VHDL Test Bench Template
if [runCmd "\"$cpld_bin/vhd2naf\" -tfi -proj ktest1 -mod KEPLER_TL -out KEPLER_TL -tpl \"$install_dir/ispcpld/generic/vhdl/testbnch.tft\" -ext vht kepler_tl.vhd"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 15:52:53 ###########


########## Tcl recorder starts at 04/11/20 16:07:51 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:07:51 ###########


########## Tcl recorder starts at 04/11/20 16:12:06 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:12:06 ###########


########## Tcl recorder starts at 04/11/20 16:13:20 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:13:20 ###########


########## Tcl recorder starts at 04/11/20 16:14:31 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:14:31 ###########


########## Tcl recorder starts at 04/11/20 16:15:28 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:15:29 ###########


########## Tcl recorder starts at 04/11/20 16:17:14 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:17:14 ###########


########## Tcl recorder starts at 04/11/20 16:21:06 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:21:06 ###########


########## Tcl recorder starts at 04/11/20 16:24:55 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:24:55 ###########


########## Tcl recorder starts at 04/11/20 16:27:13 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:27:13 ###########


########## Tcl recorder starts at 04/11/20 16:29:42 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:29:42 ###########


########## Tcl recorder starts at 04/11/20 16:41:45 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:41:45 ###########


########## Tcl recorder starts at 04/11/20 16:50:20 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:50:20 ###########


########## Tcl recorder starts at 04/11/20 16:55:58 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 16:55:58 ###########


########## Tcl recorder starts at 04/11/20 17:23:48 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 17:23:48 ###########


########## Tcl recorder starts at 04/11/20 17:25:00 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 17:25:00 ###########


########## Tcl recorder starts at 04/11/20 17:26:44 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 17:26:44 ###########


########## Tcl recorder starts at 04/11/20 17:29:05 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 17:29:05 ###########


########## Tcl recorder starts at 04/11/20 17:46:21 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 17:46:21 ###########


########## Tcl recorder starts at 04/11/20 17:47:22 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 17:47:22 ###########


########## Tcl recorder starts at 04/11/20 17:48:49 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 17:48:49 ###########


########## Tcl recorder starts at 04/11/20 17:50:03 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 17:50:03 ###########


########## Tcl recorder starts at 04/11/20 17:52:37 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 17:52:37 ###########


########## Tcl recorder starts at 04/11/20 18:04:25 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:04:25 ###########


########## Tcl recorder starts at 04/11/20 18:14:29 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:14:29 ###########


########## Tcl recorder starts at 04/11/20 18:16:34 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:16:34 ###########


########## Tcl recorder starts at 04/11/20 18:22:25 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:22:25 ###########


########## Tcl recorder starts at 04/11/20 18:38:45 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:38:45 ###########


########## Tcl recorder starts at 04/11/20 18:43:41 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:43:41 ###########


########## Tcl recorder starts at 04/11/20 18:52:08 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:52:08 ###########


########## Tcl recorder starts at 04/11/20 18:55:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:55:10 ###########


########## Tcl recorder starts at 04/11/20 18:55:25 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:55:25 ###########


########## Tcl recorder starts at 04/11/20 18:55:39 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 18:55:39 ###########


########## Tcl recorder starts at 04/11/20 19:09:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:09:54 ###########


########## Tcl recorder starts at 04/11/20 19:09:57 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:09:57 ###########


########## Tcl recorder starts at 04/11/20 19:10:22 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:10:22 ###########


########## Tcl recorder starts at 04/11/20 19:14:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:14:54 ###########


########## Tcl recorder starts at 04/11/20 19:16:00 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:16:00 ###########


########## Tcl recorder starts at 04/11/20 19:16:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:16:18 ###########


########## Tcl recorder starts at 04/11/20 19:16:24 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:16:24 ###########


########## Tcl recorder starts at 04/11/20 19:16:49 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:16:49 ###########


########## Tcl recorder starts at 04/11/20 19:21:23 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:21:23 ###########


########## Tcl recorder starts at 04/11/20 19:51:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:51:38 ###########


########## Tcl recorder starts at 04/11/20 19:51:54 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:51:54 ###########


########## Tcl recorder starts at 04/11/20 19:52:09 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 19:52:09 ###########


########## Tcl recorder starts at 04/11/20 20:24:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:24:25 ###########


########## Tcl recorder starts at 04/11/20 20:24:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:24:31 ###########


########## Tcl recorder starts at 04/11/20 20:33:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:33:35 ###########


########## Tcl recorder starts at 04/11/20 20:33:41 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:33:41 ###########


########## Tcl recorder starts at 04/11/20 20:34:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:34:06 ###########


########## Tcl recorder starts at 04/11/20 20:34:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:34:09 ###########


########## Tcl recorder starts at 04/11/20 20:35:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:35:14 ###########


########## Tcl recorder starts at 04/11/20 20:35:18 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:35:18 ###########


########## Tcl recorder starts at 04/11/20 20:38:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:38:15 ###########


########## Tcl recorder starts at 04/11/20 20:38:21 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:38:21 ###########


########## Tcl recorder starts at 04/11/20 20:38:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:38:43 ###########


########## Tcl recorder starts at 04/11/20 20:40:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:40:58 ###########


########## Tcl recorder starts at 04/11/20 20:41:12 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:41:12 ###########


########## Tcl recorder starts at 04/11/20 20:44:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:44:00 ###########


########## Tcl recorder starts at 04/11/20 20:44:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:44:36 ###########


########## Tcl recorder starts at 04/11/20 20:50:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:50:38 ###########


########## Tcl recorder starts at 04/11/20 20:50:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:50:52 ###########


########## Tcl recorder starts at 04/11/20 20:50:59 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:50:59 ###########


########## Tcl recorder starts at 04/11/20 20:51:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:51:47 ###########


########## Tcl recorder starts at 04/11/20 20:51:51 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:51:51 ###########


########## Tcl recorder starts at 04/11/20 20:52:02 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:52:02 ###########


########## Tcl recorder starts at 04/11/20 20:52:29 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:52:29 ###########


########## Tcl recorder starts at 04/11/20 20:53:03 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:53:03 ###########


########## Tcl recorder starts at 04/11/20 20:53:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:53:06 ###########


########## Tcl recorder starts at 04/11/20 20:53:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:53:50 ###########


########## Tcl recorder starts at 04/11/20 20:53:54 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:53:54 ###########


########## Tcl recorder starts at 04/11/20 20:54:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:54:32 ###########


########## Tcl recorder starts at 04/11/20 20:54:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" pps_count.vhd -o pps_count.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:54:57 ###########


########## Tcl recorder starts at 04/11/20 20:55:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:55:25 ###########


########## Tcl recorder starts at 04/11/20 20:55:33 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:55:33 ###########


########## Tcl recorder starts at 04/11/20 20:55:51 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 20:55:51 ###########


########## Tcl recorder starts at 04/11/20 21:01:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 21:01:45 ###########


########## Tcl recorder starts at 04/11/20 21:02:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 21:02:09 ###########


########## Tcl recorder starts at 04/11/20 21:02:24 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 21:02:24 ###########


########## Tcl recorder starts at 04/11/20 21:27:25 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 21:27:25 ###########


########## Tcl recorder starts at 04/11/20 21:27:38 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 21:27:38 ###########


########## Tcl recorder starts at 04/11/20 21:43:07 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 21:43:07 ###########


########## Tcl recorder starts at 04/11/20 21:43:27 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 21:43:27 ###########


########## Tcl recorder starts at 04/11/20 21:51:30 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 21:51:30 ###########


########## Tcl recorder starts at 04/11/20 21:52:57 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 21:52:57 ###########


########## Tcl recorder starts at 04/11/20 22:00:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" spi_mod.vhd -o spi_mod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 22:00:41 ###########


########## Tcl recorder starts at 04/11/20 22:00:47 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL_lse.env w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL_lse.env: $rspFile"
} else {
	puts $rspFile "FOUNDRY=$install_dir/lse
PATH=$install_dir/lse/bin/nt;%PATH%
"
	close $rspFile
}
if [catch {open KEPLER_TL.synproj w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.synproj: $rspFile"
} else {
	puts $rspFile "-a ispMACH400ZE
-d LC4064ZE
-top KEPLER_TL
-vhd spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
-output_edif KEPLER_TL.edi
-optimization_goal Area
-frequency  200
-fsm_encoding_style Auto
-use_io_insertion 1
-resource_sharing 1
-propagate_constants 1
-remove_duplicate_regs 1
-twr_paths  3
-resolve_mixed_drivers 0
"
	close $rspFile
}
if [runCmd "\"$install_dir/lse/bin/nt/synthesis\" -f \"KEPLER_TL.synproj\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete KEPLER_TL_lse.env
file delete KEPLER_TL.synproj
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj ktest1 -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"ktest1.bl2\" -omod \"ktest1\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj ktest1 -lci ktest1.lct -log ktest1.imp -err automake.err -tti ktest1.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -blifopt ktest1.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" ktest1.bl2 -sweep -mergefb -err automake.err -o ktest1.bl3 @ktest1.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -diofft ktest1.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" ktest1.bl3 -family AMDMACH -idev van -o ktest1.bl4 -oxrf ktest1.xrf -err automake.err @ktest1.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci ktest1.lct -dev lc4k -prefit ktest1.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp ktest1.bl4 -out ktest1.bl5 -err automake.err -log ktest1.log -mod KEPLER_TL @ktest1.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open ktest1.rs1 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs1: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -nojed -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open ktest1.rs2 w} rspFile] {
	puts stderr "Cannot create response file ktest1.rs2: $rspFile"
} else {
	puts $rspFile "-i ktest1.bl5 -lci ktest1.lct -d m4e_64_32 -lco ktest1.lco -html_rpt -fti ktest1.fti -fmt PLA -tto ktest1.tt4 -eqn ktest1.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@ktest1.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rs1
file delete ktest1.rs2
if [runCmd "\"$cpld_bin/tda\" -i ktest1.bl5 -o ktest1.tda -lci ktest1.lct -dev m4e_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj ktest1 -if ktest1.jed -j2s -log ktest1.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 22:00:47 ###########


########## Tcl recorder starts at 04/11/20 22:01:40 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#insert # End
"
	close $rspFile
}
if [catch {open ktest1.rsp w} rspFile] {
	puts stderr "Cannot create response file ktest1.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" ktest1.rsp ktest1.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete ktest1.rsp
file delete ktest1.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 22:01:40 ###########


########## Tcl recorder starts at 04/11/20 22:07:57 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 22:07:57 ###########


########## Tcl recorder starts at 04/11/20 22:10:12 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: kepler_tl_tb_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open kepler_tl_tb.rsp w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo ktest1.sty
#do 
#vcomSrc   spi_mod.vhd pps_count.vhd adc_buf.vhd kepler_tl.vhd
#vcom kepler_tl_tb.vhd
#stimulus vhdl KEPLER_TL kepler_tl_tb.vhd
#insert vsim +access +r %<StimModule>%
#youdo kepler_tl_tb_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" kepler_tl_tb.rsp kepler_tl_tb.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete kepler_tl_tb.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open kepler_tl_tb_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file kepler_tl_tb_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl kepler_tl_tb.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"kepler_tl_tb_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 04/11/20 22:10:12 ###########

