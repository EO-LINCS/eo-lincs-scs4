#!/bin/bash

export JAVA_TOOL_OPTIONS="\
--add-opens=java.base/java.util=ALL-UNNAMED \
--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
--add-opens=java.base/java.text=ALL-UNNAMED \
--add-opens=java.desktop/java.awt=ALL-UNNAMED \
--add-opens=java.desktop/java.awt.font=ALL-UNNAMED"



for y in {1993..2015}; do 

~/shared/mo339/data/ESA_CCI/landcover/LC/cross_walk/lc-user-tools-5.0/bin/aggregate-map.sh -PgridName=GEOGRAPHIC_LAT_LON -PnumRows=1440 -Pnorth=72.9375 -Psouth=35.0625 -Peast=44.9375 -Pwest=-24.9375 -PoutputLCCSClasses=false -PuserPFTConversionTable="/home/links/mo339/shared/mo339/data/ESA_CCI/landcover/LC/cross_walk/lc-user-tools-3.14/resources/LC-CCI-LUT-LCCStoPFT_KG_Default_LSCE_v2.4.csv" -PtargetDir="/home/links/mo339/shared/mo339/data/ESA_CCI/landcover/LC/cross_walk/output/Europe_0.125d/" "ESACCI-LC-L4-LCCS-Map-300m-P1Y-"$y"-v2.0.7b.nc"

done

for y in {2016..2022}; do

~/shared/mo339/data/ESA_CCI/landcover/LC/cross_walk/lc-user-tools-5.0/bin/aggregate-map.sh -PgridName=GEOGRAPHIC_LAT_LON -PnumRows=1440 -Pnorth=72.9375 -Psouth=35.0625 -Peast=44.9375 -Pwest=-24.9375 -PoutputLCCSClasses=false -PuserPFTConversionTable="/home/links/mo339/shared/mo339/data/ESA_CCI/landcover/LC/cross_walk/lc-user-tools-3.14/resources/LC-CCI-LUT-LCCStoPFT_KG_Default_LSCE_v2.4.csv" -PtargetDir="/home/links/mo339/shared/mo339/data/ESA_CCI/landcover/LC/cross_walk/output/Europe_0.125d/" "C3S-LC-L4-LCCS-Map-300m-P1Y-$y-v2.1.1.nc"

done
