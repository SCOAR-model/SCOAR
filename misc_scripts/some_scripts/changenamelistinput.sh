#!/bin/sh
set -ax
NRREC=$1
run_minutes=`echo $1 | cut -d':' -f3`
YYYYi=`echo $2 | cut -d':' -f1`
MMi=`echo $2 | cut -d':' -f2`
DDi=`echo $2 | cut -d':' -f3`
HHi=`echo $2 | cut -d':' -f4`
WRF_RESTART=$3
restart_interval=$4

# end year/months are not relevent if run_days are specified in namelist.input
#cat testnamelist | awk '(NR==6){$1=" start_year"; $2="                         ="; $3 = "9999,"}{print $0}' > testnamelistnew

cat << INN > awktemp
{
       if (NR==136)
        {
                \$1=" run_days"; 
                \$2="                         ="; 
                \$3 = "$run_days,"
        }
        if (NR==3)
        {
                \$1=" run_hours"; 
                \$2="                         ="; 
                \$3 = "$run_hours,"
        }
        if (NR==4)
        {
                \$1=" run_minutes"; 
                \$2="                         ="; 
                \$3 = "$run_minutes,"
        }
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
        if (NR==20)
        {
                \$1=" restart"; 
                \$2="                         ="; 
                \$3 = "$WRF_RESTART,"
        }
        if (NR==21)
        {
                \$1=" restart_interval"; 
                \$2="                         ="; 
                \$3 = "$restart_interval"
        }
	{print \$0}
}
INN

cat namelist.input | awk -f awktemp > testnamelistnew || exit 8
cp testnamelistnew namelist.input.$YYYYi$MMi$DDi$HHi
mv testnamelistnew namelist.input
rm awktemp

