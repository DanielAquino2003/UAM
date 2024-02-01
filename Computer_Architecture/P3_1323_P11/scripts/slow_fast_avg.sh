fDAT=time_slow_fast.dat

awk '{ sum += $2 } END { if (NR > 0) print sum / NR }' $fDAT