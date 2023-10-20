set -ax
YYYYi=`echo $1 | cut -d':' -f1`
MMi=`echo $1 | cut -d':' -f2`
DDi=`echo $1 | cut -d':' -f3`
HHi=`echo $1 | cut -d':' -f4`

YYYYin=`echo $5 | cut -d':' -f1`
MMin=`echo $5 | cut -d':' -f2`
DDin=`echo $5 | cut -d':' -f3`
HHin=`echo $5 | cut -d':' -f4`

WRF_RESTART=$2
write_hist_at_0h_rst=$3
io_form_restart=$4

namelist_input_file=$Model_WRF_Dir/namelist.input
cp $Couple_Lib_exec_WRF_Dir/$WRF_Namelist_input $namelist_input_file
#find the line with pattern and delete it
###    sed -i -e '/pattern/d' file

#insert new line at N line (once the previous was deleted you can add the new one anywhere(?)..)
###    sed "N i the new line" file

## use double quote when shell variables 

l1=$(grep -n 'start_year' $namelist_input_file | grep -Eo '^[0-9]{1,3}') 
sed -i "$l1 d" $namelist_input_file 
sed -i -e  "$l1 i start_year             =  $YYYYi,$YYYYi,$YYYYi," $namelist_input_file

l2=$(grep -n 'start_month' $namelist_input_file | grep -Eo '^[0-9]{1,3}') 
sed -i "$l2 d" $namelist_input_file 
sed -i -e  "$l2 i start_month              =  $MMi,$MMi,$MMi," $namelist_input_file

l3=$(grep -n 'start_day' $namelist_input_file | grep -Eo '^[0-9]{1,3}') 
sed -i "$l3 d" $namelist_input_file 
sed -i -e  "$l3 i start_day                =  $DDi,$DDi,$DDi," $namelist_input_file

l4=$(grep -n 'start_hour' $namelist_input_file | grep -Eo '^[0-9]{1,3}') 
sed -i "$l4 d" $namelist_input_file 
sed -i -e  "$l4 i start_hour               =  $HHi,$HHi,$HHi," $namelist_input_file

#sed -i -e 's/^[ \t]*//'                 $namelist_input_file

l5=$(grep -n 'restart' $namelist_input_file | grep 'false' | grep -Eo '^[0-9]{1,3}') 
if [ -z "$l5" ] #check if empty, if restart is already .true. l5 is empty and it messed up the namelist..... 
then #l5 is empty
	dummy="do nothing" #restart already .true.
else #
	sed -i "$l5 d" $namelist_input_file 
	sed -i -e "$l5 i restart                  =  $WRF_RESTART," $namelist_input_file
fi

l6=$(grep -n 'io_form_restart' $namelist_input_file | grep -Eo '^[0-9]{1,3}') 
sed -i "$l6 d" $namelist_input_file 
sed -i -e "$l6 i io_form_restart          =  $io_form_restart," $namelist_input_file

l7=$(grep -n 'write_hist_at_0h_rst' $namelist_input_file | grep -Eo '^[0-9]{1,3}') 
sed -i "$l7 d" $namelist_input_file 
sed -i -e "$l7 i write_hist_at_0h_rst     =  $write_hist_at_0h_rst," $namelist_input_file

l8=$(grep -n 'isftcflx' $namelist_input_file | grep -Eo '^[0-9]{1,3}') 
sed -i "$l8 d" $namelist_input_file 


if [ $parameter_run_WW3 = yes ]; then
        if [ $isftcflx = 351 ]; then 
#isftcflx=351; peak wave age only formula
                sed -i -e "$l8 i isftcflx                 =  351," $namelist_input_file
        elif [ $isftcflx = 352 ]; then 
#isftcflx=352; peak wave age and wave height formula
                sed -i -e "$l8 i isftcflx                 =  352," $namelist_input_file
        elif [ $isftcflx = 353 ]; then 
#isftcflx=353; peak wave age and wave height formula + angle between wind and wave
                sed -i -e "$l8 i isftcflx                 =  353," $namelist_input_file
        elif [ $isftcflx = 354 ]; then 
#default, isftcflx=354; mean wave age and wave height formula
                sed -i -e "$l8 i isftcflx                 =  354," $namelist_input_file
        elif [ $isftcflx = 355 ]; then #default, isftcflx=355; wave age and wave height formula
                sed -i -e "$l8 i isftcflx                 =  355," $namelist_input_file
        elif [ $isftcflx = 3500 ]; then 
#isftcflx=3500; UST from WW3 for wind stress, use wave age and wave height formula for heat flux
                sed -i -e "$l8 i isftcflx                 =  3500," $namelist_input_file
	else
	echo "isftcflx is not defined. Exiting"
	exit 8
        fi

else #COARE3.5 wind only dependant, isftcflx=0
        sed -i -e "$l8 i isftcflx                 =  0," $namelist_input_file
fi


l9=$(grep -n 'end_year' $namelist_input_file | grep -Eo '^[0-9]{1,3}')
sed -i "$l9 d" $namelist_input_file
sed -i -e  "$l9 i end_year             =  $YYYYin,$YYYYin," $namelist_input_file

l10=$(grep -n 'end_month' $namelist_input_file | grep -Eo '^[0-9]{1,3}')
sed -i "$l10 d" $namelist_input_file
sed -i -e  "$l10 i end_month              =  $MMin,$MMin," $namelist_input_file

l11=$(grep -n 'end_day' $namelist_input_file | grep -Eo '^[0-9]{1,3}')
sed -i "$l11 d" $namelist_input_file
sed -i -e  "$l11 i end_day                =  $DDin,$DDin," $namelist_input_file

l12=$(grep -n 'end_hour' $namelist_input_file | grep -Eo '^[0-9]{1,3}')
sed -i "$l12 d" $namelist_input_file
sed -i -e  "$l12 i end_hour               =  $HHin,$HHin," $namelist_input_file

