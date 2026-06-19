#!/bin/bash

#conda activate ilamb

export ILAMB_ROOT=/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb
export QT_QPA_PLATFORM=offscreen

export ILAMB_DEBUG=True

ilamb-run --config setup_expanded_nocci_newLAI_seasonal_relationships.cfg --model_root /home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/models --build_dir /home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/build_expanded_nocci_newLAI_seasonal_relationships_v2 --rmse_score_basis "series"
