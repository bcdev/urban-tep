#!/bin/bash
set -e

input=$(basename $1)
id=${input%.tar.gz}
id=${id%.tgz}
metadatafile=${id}_MTL.txt
mask=${id}_MTLFmask.hdr
output=${id}-fmask.nc

wd=$(pwd)
SNAP_DIR=/urbantep/software/snap-5.0.0
MCR_DIR=/urbantep/software/mcr_root-v81
FMASK_DIR=$(cd $(dirname $0); pwd)

if [ ! -e $wd/$metadatafile ]; then
    echo 'unpacking tgz input ...'
    tar xf $1
fi

if [ ! -e $wd/$mask ]; then
    echo 'masking with Fmask ...'
    export MCR_CACHE_ROOT=${wd}/mcrcache
    mkdir -p ${MCR_CACHE_ROOT}
    $FMASK_DIR/run_Fmask.sh $MCR_DIR
fi

if [ ! -e $wd/$output ]; then
    echo 'merging mask into product ...'
    ${SNAP_DIR}/bin/gpt -c 4G $FMASK_DIR/merge-graph.xml -PmasterProduct=$wd/$metadatafile $wd/$mask -f NetCDF4-BEAM -t $wd/$output
fi

echo OUTPUT_PRODUCT $output


