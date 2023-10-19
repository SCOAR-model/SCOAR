#!/bin/sh
#set -ax

YYYYi=`echo $1 | cut -d':' -f1`
MMi=`echo $1 | cut -d':' -f2`
DDi=`echo $1 | cut -d':' -f3`
HHi=`echo $1 | cut -d':' -f4`

YYYYe=`echo $2 | cut -d':' -f1`
MMe=`echo $2 | cut -d':' -f2`
DDe=`echo $2 | cut -d':' -f3`
HHe=`echo $2 | cut -d':' -f4`

WRF_RESTART=$3

# end year/months are not relevent if run_days are specified in namelist.input

#cat testnamelist | awk '(NR==6){$1=" start_year"; $2="                         ="; $3 = "9999,"}{print $0}' > testnamelistnew

cat << INN > awktemp
{
        if (NR==6)
        {
                \$1=" start_year"; 
                \$2="                         ="; 
                \$3 = "$YYYYi,"
        }
        if (NR==7)
        {
                \$1=" start_month"; 
                \$2="                        ="; 
                \$3 = "$MMi,"
        }
        if (NR==8)
        {
                \$1=" start_day"; 
                \$2="                          ="; 
                \$3 = "$DDi,"
        }
        if (NR==9)
        {
                \$1=" start_hour"; 
                \$2="                          ="; 
                \$3 = "$HHi,"
	}
        if (NR==12)
        {
                \$1=" end_year"; 
                \$2="                         ="; 
                \$3 = "$YYYYe,"
                \$4 = "$YYYYe,"
                \$5 = "$YYYYe,"
        }
        if (NR==13)
        {
                \$1=" end_month"; 
                \$2="                        ="; 
                \$3 = "$MMe,"
                \$4 = "$MMe,"
                \$5 = "$MMe,"
        }
        if (NR==14)
        {
                \$1=" end_day"; 
                \$2="                          ="; 
                \$3 = "$DDe,"
                \$4 = "$DDe,"
                \$5 = "$DDe,"
        }
        if (NR==15)
        {
                \$1=" end_hour"; 
                \$2="                          ="; 
                \$3 = "$HHe,"
                \$4 = "$HHe,"
                \$5 = "$HHe,"
        }
        if (NR==22)
        {
                \$1=" restart"; 
                \$2="                         ="; 
                \$3 = "$WRF_RESTART,"
        }
	{print \$0}
}
INN

cat $Couple_Lib_exec_WRF_Dir/$WRF_Namelist_input | awk -f awktemp > testnamelistnew || exit 8
cp testnamelistnew $WRF_NamelistInput_Dir/namelist.input.$YYYYi$MMi$DDi$HHi
mv testnamelistnew $Model_WRF_Dir/namelist.input
rm awktemp

