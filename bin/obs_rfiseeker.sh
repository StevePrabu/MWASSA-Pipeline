#!/bin/bash

usage()
{
echo "autoSubmitJobs.sh [-o obsnum] [-a account] [-t tlePath]
        -a account 		: the account to process
	-t tlePath		: the absolute path to TLE files
        -o obsnum               : the obsid" 1>&2;
exit 1;
}

account=
obsnum=
timeSteps=56
channels=768
tlePath=

while getopts 'o:a:t:' OPTION
do
    case "$OPTION" in
	a)
	    account=${OPTARG}
            ;;
	t)
	    tlePath=${OPTARG}
	    ;;
        o)
            obsnum=${OPTARG}
            ;;
        ? | : | h)
            usage
            ;;
    esac
done

# set the obsid to be the first non option
shift  "$(($OPTIND -1))"

# if obsid is empty then just pring help
if [[ -z ${obsnum} ]]
then
    usage
fi


base=/astro/mwasci/sprabu/satellites/MWASSA-Pipeline/

## copy data ##
script="${base}queue/rfiseeker_${obsnum}.sh"
cat ${base}bin/rfiseeker.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/rfiseeker_${obsnum}.o%A"
error="${base}queue/logs/rfiseeker_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -A ${account} ${script} -t ${tlePath} -s ${timeSteps} -f ${channels} "
jobid=($(${sub}))
jobid=${jobid[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid}/"`
output=`echo ${output} | sed "s/%A/${jobid}/"`

echo "Submitter RFISeeker job as ${jobid}"


