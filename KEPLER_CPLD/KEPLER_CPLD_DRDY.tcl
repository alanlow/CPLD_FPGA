
########## Tcl recorder starts at 05/12/20 13:08:23 ##########

set version "2.0"
set proj_dir "C:/Users/alanlow/Documents/GitHub/CPLD_FPGA/KEPLER_CPLD"
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
if [runCmd "\"$cpld_bin/vhd2jhd\" kepler_tl.vhd -o kepler_tl.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:08:23 ###########


########## Tcl recorder starts at 05/12/20 13:08:27 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.sif"] {
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
	puts $rspFile "-nodal -src kepler_cpld_drdy.bl5 -type BLIF -presrc kepler_cpld_drdy.bl3 -crf kepler_cpld_drdy.crf -sif kepler_cpld_drdy.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_32.dev\" -lci kepler_cpld_drdy.lct
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

########## Tcl recorder end at 05/12/20 13:08:27 ###########


########## Tcl recorder starts at 05/12/20 13:33:22 ##########

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

########## Tcl recorder end at 05/12/20 13:33:22 ###########


########## Tcl recorder starts at 05/12/20 13:33:33 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:33:33 ###########


########## Tcl recorder starts at 05/12/20 13:34:19 ##########

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

########## Tcl recorder end at 05/12/20 13:34:19 ###########


########## Tcl recorder starts at 05/12/20 13:34:21 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:34:21 ###########


########## Tcl recorder starts at 05/12/20 13:34:58 ##########

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

########## Tcl recorder end at 05/12/20 13:34:58 ###########


########## Tcl recorder starts at 05/12/20 13:35:00 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:35:00 ###########


########## Tcl recorder starts at 05/12/20 13:36:25 ##########

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

########## Tcl recorder end at 05/12/20 13:36:25 ###########


########## Tcl recorder starts at 05/12/20 13:36:27 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:36:27 ###########


########## Tcl recorder starts at 05/12/20 13:40:06 ##########

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

########## Tcl recorder end at 05/12/20 13:40:06 ###########


########## Tcl recorder starts at 05/12/20 13:40:09 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:40:09 ###########


########## Tcl recorder starts at 05/12/20 13:41:38 ##########

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

########## Tcl recorder end at 05/12/20 13:41:38 ###########


########## Tcl recorder starts at 05/12/20 13:41:43 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:41:43 ###########


########## Tcl recorder starts at 05/12/20 13:42:17 ##########

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

########## Tcl recorder end at 05/12/20 13:42:17 ###########


########## Tcl recorder starts at 05/12/20 13:42:20 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:42:20 ###########


########## Tcl recorder starts at 05/12/20 13:43:30 ##########

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

########## Tcl recorder end at 05/12/20 13:43:30 ###########


########## Tcl recorder starts at 05/12/20 13:43:36 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:43:36 ###########


########## Tcl recorder starts at 05/12/20 13:44:04 ##########

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

########## Tcl recorder end at 05/12/20 13:44:04 ###########


########## Tcl recorder starts at 05/12/20 13:44:06 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:44:06 ###########


########## Tcl recorder starts at 05/12/20 13:45:25 ##########

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

########## Tcl recorder end at 05/12/20 13:45:25 ###########


########## Tcl recorder starts at 05/12/20 13:45:31 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:45:31 ###########


########## Tcl recorder starts at 05/12/20 13:46:09 ##########

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

########## Tcl recorder end at 05/12/20 13:46:09 ###########


########## Tcl recorder starts at 05/12/20 13:46:11 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:46:11 ###########


########## Tcl recorder starts at 05/12/20 13:46:50 ##########

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

########## Tcl recorder end at 05/12/20 13:46:50 ###########


########## Tcl recorder starts at 05/12/20 13:46:53 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:46:53 ###########


########## Tcl recorder starts at 05/12/20 13:49:27 ##########

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

########## Tcl recorder end at 05/12/20 13:49:27 ###########


########## Tcl recorder starts at 05/12/20 13:49:36 ##########

# Commands to make the Process: 
# Compiled Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" KEPLER_TL.bl0 -o KEPLER_TL.eq0  -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:49:36 ###########


########## Tcl recorder starts at 05/12/20 13:51:01 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/mblifopt\" KEPLER_TL.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 13:51:01 ###########


########## Tcl recorder starts at 05/12/20 14:02:49 ##########

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

########## Tcl recorder end at 05/12/20 14:02:49 ###########


########## Tcl recorder starts at 05/12/20 14:02:54 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:02:54 ###########


########## Tcl recorder starts at 05/12/20 14:04:41 ##########

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

########## Tcl recorder end at 05/12/20 14:04:41 ###########


########## Tcl recorder starts at 05/12/20 14:04:51 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:04:51 ###########


########## Tcl recorder starts at 05/12/20 14:07:19 ##########

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

########## Tcl recorder end at 05/12/20 14:07:19 ###########


########## Tcl recorder starts at 05/12/20 14:07:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:07:26 ###########


########## Tcl recorder starts at 05/12/20 14:20:13 ##########

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

########## Tcl recorder end at 05/12/20 14:20:13 ###########


########## Tcl recorder starts at 05/12/20 14:20:17 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:20:17 ###########


########## Tcl recorder starts at 05/12/20 14:22:24 ##########

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

########## Tcl recorder end at 05/12/20 14:22:24 ###########


########## Tcl recorder starts at 05/12/20 14:22:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:22:26 ###########


########## Tcl recorder starts at 05/12/20 14:22:55 ##########

# Commands to make the Process: 
# Compile EDIF File
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:22:55 ###########


########## Tcl recorder starts at 05/12/20 14:24:26 ##########

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

########## Tcl recorder end at 05/12/20 14:24:26 ###########


########## Tcl recorder starts at 05/12/20 14:24:36 ##########

# Commands to make the Process: 
# Compile EDIF File
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:24:36 ###########


########## Tcl recorder starts at 05/12/20 14:29:45 ##########

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

########## Tcl recorder end at 05/12/20 14:29:45 ###########


########## Tcl recorder starts at 05/12/20 14:29:57 ##########

# Commands to make the Process: 
# Compile EDIF File
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:29:57 ###########


########## Tcl recorder starts at 05/12/20 14:30:32 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:30:32 ###########


########## Tcl recorder starts at 05/12/20 14:32:00 ##########

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

########## Tcl recorder end at 05/12/20 14:32:00 ###########


########## Tcl recorder starts at 05/12/20 14:32:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:32:09 ###########


########## Tcl recorder starts at 05/12/20 14:33:36 ##########

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

########## Tcl recorder end at 05/12/20 14:33:36 ###########


########## Tcl recorder starts at 05/12/20 14:33:40 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:33:40 ###########


########## Tcl recorder starts at 05/12/20 14:34:14 ##########

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

########## Tcl recorder end at 05/12/20 14:34:14 ###########


########## Tcl recorder starts at 05/12/20 14:34:17 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/12/20 14:34:17 ###########


########## Tcl recorder starts at 05/14/20 10:21:27 ##########

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

########## Tcl recorder end at 05/14/20 10:21:27 ###########


########## Tcl recorder starts at 05/14/20 10:21:34 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/14/20 10:21:34 ###########


########## Tcl recorder starts at 05/14/20 10:24:36 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.eq2 -use_short -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/14/20 10:24:36 ###########


########## Tcl recorder starts at 05/14/20 10:24:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open KEPLER_TL.cmd w} rspFile] {
	puts stderr "Cannot create response file KEPLER_TL.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: kepler_cpld_drdy.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf KEPLER_TL.edi -out KEPLER_TL.bl0 -err automake.err -log KEPLER_TL.log -prj kepler_cpld_drdy -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"KEPLER_TL.bl1\" -o \"kepler_cpld_drdy.bl2\" -omod \"kepler_cpld_drdy\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj kepler_cpld_drdy -lci kepler_cpld_drdy.lct -log kepler_cpld_drdy.imp -err automake.err -tti kepler_cpld_drdy.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -blifopt kepler_cpld_drdy.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" kepler_cpld_drdy.bl2 -sweep -mergefb -err automake.err -o kepler_cpld_drdy.bl3 @kepler_cpld_drdy.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -diofft kepler_cpld_drdy.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" kepler_cpld_drdy.bl3 -family AMDMACH -idev van -o kepler_cpld_drdy.bl4 -oxrf kepler_cpld_drdy.xrf -err automake.err @kepler_cpld_drdy.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci kepler_cpld_drdy.lct -dev lc4k -prefit kepler_cpld_drdy.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp kepler_cpld_drdy.bl4 -out kepler_cpld_drdy.bl5 -err automake.err -log kepler_cpld_drdy.log -mod KEPLER_TL @kepler_cpld_drdy.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open kepler_cpld_drdy.rs1 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs1: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -nojed -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open kepler_cpld_drdy.rs2 w} rspFile] {
	puts stderr "Cannot create response file kepler_cpld_drdy.rs2: $rspFile"
} else {
	puts $rspFile "-i kepler_cpld_drdy.bl5 -lci kepler_cpld_drdy.lct -d m4s_64_32 -lco kepler_cpld_drdy.lco -html_rpt -fti kepler_cpld_drdy.fti -fmt PLA -tto kepler_cpld_drdy.tt4 -eqn kepler_cpld_drdy.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@kepler_cpld_drdy.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete kepler_cpld_drdy.rs1
file delete kepler_cpld_drdy.rs2
if [runCmd "\"$cpld_bin/tda\" -i kepler_cpld_drdy.bl5 -o kepler_cpld_drdy.tda -lci kepler_cpld_drdy.lct -dev m4s_64_32 -family lc4k -mod KEPLER_TL -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj kepler_cpld_drdy -if kepler_cpld_drdy.jed -j2s -log kepler_cpld_drdy.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 05/14/20 10:24:58 ###########


########## Tcl recorder starts at 05/14/20 10:25:24 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src kepler_cpld_drdy.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_64_32.dev\" -postfit -lci kepler_cpld_drdy.lco
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

########## Tcl recorder end at 05/14/20 10:25:24 ###########

