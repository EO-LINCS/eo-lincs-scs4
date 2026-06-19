#!/bin/bash

## Process FLUXCOM-X data for ILAMB.

for var in GPP ET; do # ET GPP
  for year in $(seq 2001 2021); do
    echo ">>> Processing $var $year"

    in="/jaguar/data/mo339/ilamb/HRLC_SouthAm/data/icos_downloads/${var}_${year}_005_monthly.nc"
    fixed="fixed_${var}_${year}_005_monthly.nc"
    out="${var}_${year}_0.125d_monthly.nc"
    sub="${var}_${year}_0.125d_monthly_Europe.nc"

    # 1. Convert time from int64 -> double
    ncap2 -O -s 'time=double(time)' "$in" "$fixed"

    # 2. Fix lon attributes
    ncatted -O \
      -a long_name,lon,m,c,"longitude" \
      -a standard_name,lon,m,c,"longitude" \
      -a units,lon,m,c,"degrees_east" \
      "$fixed"

    # 3. Fix lat attributes
    ncatted -O \
      -a long_name,lat,m,c,"latitude" \
      -a standard_name,lat,m,c,"latitude" \
      -a units,lat,m,c,"degrees_north" \
      "$fixed"

    # 4. Remap only the main variable
    cdo -L remapcon,r2880x1440 -selvar,$var "$fixed" "$out"


    # 5. Subset to Europe
    # -24.9375 or 335.0625
    ncks -O -d lon,335.0625,45. -d lat,35.0625,72.9375 "$out" "$sub" # 44.9375

    # 6. Clean
    rm $in
    mv $fixed $in

  done
done

cdo mergetime GPP_20*monthly_Europe.nc temp.nc
ncap2 -O -s 'GPP=GPP/(60*60*24*1000)' temp.nc GPP_0.125d_monthly_Europe.nc
ncatted -O -a units,GPP,m,c,"kg m-2 s-1" GPP_0.125d_monthly_Europe.nc
rm temp.nc

cdo mergetime ET_20*monthly_Europe.nc temp.nc
ncap2 -O -s 'ET=ET/(60*60)' temp.nc ET_0.125d_monthly_Europe.nc
ncatted -O -a units,ET,m,c,"kg m-2 s-1" ET_0.125d_monthly_Europe.nc
rm temp.nc


