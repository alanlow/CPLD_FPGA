
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

