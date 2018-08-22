#!/bin/bash

if [ $# -ne 4 ];then
    echo "$0 <setup.sh> <model-dir> <date-test-dir> <decode-dir> "
    exit 1
fi

setup=$1
mdldir=$2
data_test_dir=$3
decode_dir=$4
stage=0

[ -f $setup ] && . $setup

mkdir -p $decode_dir/log

mdl=$mdldir/final.mdl
pdf_mapping=$mdldir/pdf_mapping.txt
for f in $mdl $pdf_mapping ; do
    [ ! -f $f ] && echo "No such file: $f" && exit 1;
done

if [ ! -f $decode_dir/decode_phone_ids.npz ];then
    echo "Decoding"
    python utils/decode_hmm.py $mdl $data_test_dir/feats.npz | \
        python utils/pdf2unit.py --phone-level $pdf_mapping | \
        python utils/prepare_trans.py $langdir/phones.txt \
        $decode_dir/decode_phone_ids.npz
fi


if [ ! -f $decode_dir/decode_result.txt ];then
    python utils/score.py \
        $data_test_dir/phones.int.npz \
        $decode_dir/decode_phone_ids.npz \
        > $decode_dir/decode_result.txt || exit 1
fi

cat $decode_dir/decode_result.txt

