#! /bin/bash -l
#SBATCH --export=NONE
#SBATCH -M zeus  
#SBATCH -p workq 
#SBATCH --time=16:00:00
#SBATCH --ntasks=28
#SBATCH --mem=120GB
#SBATCH -J RFISeeker
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user sirmcmissile47@gmail.com

set -x

{

obsnum=OBSNUM
base=BASE
tlePath=
timeSteps=
channels=

while getopts 't:s:f:' OPTION
do
    case "$OPTION" in
        s)
            timeSteps=${OPTARG}
            ;;
        f)
            channels=${OPTARG}
            ;;
        t)
            tlePath=${OPTARG}
            ;;
    esac
done

datadir=${base}processing/${obsnum}
cd ${datadir}
rm noDetections*.csv

for q in $(seq ${timeSteps})
do
  while [[ $(jobs | wc -l) -ge 28 ]]
  do
    wait -n $(jobs -p)
  done
  RFISeekerNeg --obs ${obsnum} --freqChannels ${channels} --seedSigma 6 --floodfillSigma 1 --timeStep ${q} --prefix Neg6Sigma1Floodfill1p24amin --DSNRS=False &
  
done

i=0
for job in `jobs -p`
do
        pids[${i}]=${job}
        i=$((i+1))
done
for pid in ${pids[*]}; do
        wait ${pid}
done

#RFICombinedPlot --obs ${obsnum} --timeStep ${timeSteps} --prefix 6Sigma3floodfill --FULLTLE ${tlePath}/FULLTLE.txt --LEOTLE ${tlePath}/LEOTLE.txt --MEOTLE ${tlePath}/MEOTLE.txt --HEOTLE ${tlePath}/HEOTLE.txt

}
