#!/bin/sh
set -ax
# 6/20//2017: added the 3rd argument write_hist_at_0h_rst: set .true. for restart; otherwise, wrfout file has the time-stamp end of the forecast instead of the beginning of the forecast

YYYYi=`echo $1 | cut -d':' -f1`
MMi=`echo $1 | cut -d':' -f2`
DDi=`echo $1 | cut -d':' -f3`
HHi=`echo $1 | cut -d':' -f4`

WRF_RESTART=$2
write_hist_at_0h_rst=$3
io_form_restart=$4

# end year/months are not relevent if run_days are specified in namelist.input

#cat testnamelist | awk '(NR==6){$1=" start_year"; $2="                         ="; $3 = "9999,"}{print $0}' > testnamelistnew

cat << INN > awktemp
{
        if (NR==6)
        {
                \$1=" start_year"; 
                \$2="                         ="; 
                \$3 = "$YYYYi, "
                \$4 = "$YYYYi, "
                \$5 = "$YYYYi, "
        }
        if (NR==7)
        {
                \$1=" start_month"; 
                \$2="                        ="; 
                \$3 = "$MMi, "
                \$4 = "$MMi, "
                \$5 = "$MMi, "
        }
        if (NR==8)
        {
                \$1=" start_day"; 
                \$2="                          ="; 
                \$3 = "$DDi, "
                \$4 = "$DDi, "
                \$5 = "$DDi, "
        }
        if (NR==9)
        {
                \$1=" start_hour"; 
                \$2="                          ="; 
                \$3 = "$HHi, "
                \$4 = "$HHi, "
                \$5 = "$HHi, "
        }
        if (NR==22)
        {
                \$1=" restart"; 
                \$2="                          ="; 
                \$3 = "$WRF_RESTART,"
        }
        if (NR==25)
        {
                \$1=" io_form_restart"; 
                \$2="                          ="; 
                \$3 = "$io_form_restart,"
        }
        if (NR==32)
        {
                \$1=" write_hist_at_0h_rst"; 
                \$2="                          ="; 
                \$3 = "$write_hist_at_0h_rst,"
        }
        {print \$0}
}
INN

cat $Couple_Lib_exec_WRF_Dir/$WRF_Namelist_input | awk -f awktemp > testnamelistnew || exit 8
cp testnamelistnew $WRF_NamelistInput_Dir/namelist.input.$YYYYi$MMi$DDi$HHi
mv testnamelistnew $Model_WRF_Dir/namelist.input
rm awktemp

