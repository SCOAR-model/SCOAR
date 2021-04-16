set -ax
YYYYi=`echo $1 | cut -d':' -f1`
MMi=`echo $1 | cut -d':' -f2`
DDi=`echo $1 | cut -d':' -f3`
HHi=`echo $1 | cut -d':' -f4`

WRF_RESTART=$2
write_hist_at_0h_rst=$3
io_form_restart=$4

namelist_input_file=$Model_WRF_Dir/namelist.input
cp $Couple_Lib_exec_WRF_Dir/$WRF_Namelist_input $namelist_input_file

#cp namelist.input~ namelist.input
#namelist_input_file=$Model_WRF_Dir/namelist.input
#namelist_input_file=./namelist.input

sed -i -e '/start_year/d'               $namelist_input_file    -e  "6 i start_year             =  $YYYYi,$YYYYi,$YYYYi," $namelist_input_file
sed -i -e '/start_month/d'              $namelist_input_file  -e  "7 i start_month              =  $MMi,$MMi,$MMi," $namelist_input_file
sed -i -e '/start_day/d'                $namelist_input_file  -e  "8 i start_day                =  $DDi,$DDi,$DDi," $namelist_input_file
sed -i -e '/start_hour/d'               $namelist_input_file  -e  "9 i start_hour               =  $HHi,$HHi,$HHi," $namelist_input_file

sed -i -e 's/^[ \t]*//'                 $namelist_input_file
sed -i -e '/^restart /d'                $namelist_input_file  -e "22 i restart                  =  $WRF_RESTART," $namelist_input_file
sed -i -e '/io_form_restart/d'          $namelist_input_file  -e "25 i io_form_restart          =  $io_form_restart," $namelist_input_file
sed -i -e '/write_hist_at_0h_rst/d'     $namelist_input_file  -e "33 i write_hist_at_0h_rst     =  $write_hist_at_0h_rst," $namelist_input_file

if [ $parameter_run_WW3 = on ]; then
	sed -i -e '/isftcflx/d' 	$namelist_input_file  -e "91 i isftcflx 	=  35," $namelist_input_file
else
	sed -i -e '/isftcflx/d' 	$namelist_input_file  -e "91 i isftcflx 	=  0," $namelist_input_file
fi

