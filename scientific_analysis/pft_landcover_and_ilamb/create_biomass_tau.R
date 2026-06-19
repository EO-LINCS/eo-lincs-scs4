library(ncdf4)

parse_origin <- function(units_string) {
  origin_str <- sub("^.*since\\s+", "", units_string)
  origin <- as.POSIXct(origin_str, tz = "UTC")
  if (is.na(origin)) stop("Couldn't parse origin from: ", units_string)
  origin
}

time_to_year <- function(time_vals, time_units) {
  origin <- parse_origin(time_units)
  dates <- origin + as.numeric(time_vals) * 86400
  as.integer(format(dates, "%Y"))
}

align_time_for_tau <- function(time_gpp, tunits_gpp, time_veg, tunits_veg) {
  yr_gpp <- time_to_year(time_gpp, tunits_gpp)
  yr_veg <- time_to_year(time_veg, tunits_veg)

  # years y where veg has both y and y-1
  veg_has_prev <- yr_veg[(yr_veg - 1L) %in% yr_veg]

  # tau years must also exist in gpp
  tau_years <- sort(intersect(yr_gpp, veg_has_prev))
  if (length(tau_years) == 0) stop("No overlapping years with cVeg(y) & cVeg(y-1) and GPP(y).")

  list(
    tau_years = tau_years,
    idx_gpp_y = match(tau_years, yr_gpp),
    idx_veg_y = match(tau_years, yr_veg),
    idx_veg_y1 = match(tau_years - 1L, yr_veg)
  )
}


## manually create time and time_bnds to use:
nyrs = 325
tbnd = array(NA,dim=c(2,nyrs))  
years_full = seq(nyrs)+1699
#for(y in 1:nyrs){
#  in1 = (365*y)-364
#  in2 = (365*y)
#  tbnd[,y] = c(in1,in2)
#}
for (y in 1:nyrs){
  tbnd[1,y] = (y-1)*365
  tbnd[2,y] = y*365
}
time = apply(tbnd,c(2),mean)


create_tau_file = function(f_gpp, f_cVeg, f_tau, target_years = NULL){

if (file.exists(f_tau)) {
  file.remove(f_tau)  
}

ncin = nc_open(f_gpp)
if("gpp" %in% names(ncin$var)){
  gpp = ncvar_get(ncin,"gpp")
}
if("GPP" %in% names(ncin$var)){
  gpp = ncvar_get(ncin,"GPP")
}
tunits   <- ncatt_get(ncin, "time", "units")$value
tcal_att <- ncatt_get(ncin, "time", "calendar")
time_in  <- ncvar_get(ncin, "time")

if("lon" %in% names(ncin$dim)){
  lon = ncvar_get(ncin,"lon")
  lat = ncvar_get(ncin,"lat")
} else {
  lon = ncvar_get(ncin,"longitude")
  lat = ncvar_get(ncin,"latitude")
}
nc_close(ncin)

gpp = gpp*60*60*24*365 # kg/m2/s -> kg/m2/yr

# mask low gpp
gpp[gpp < 0.01] = NA

ncin = nc_open(f_cVeg)
if("cVeg" %in% names(ncin$var)){
  cVeg = ncvar_get(ncin,"cVeg") # kg/m2
}
if("biomass" %in% names(ncin$var)){
  cVeg = ncvar_get(ncin,"biomass") # kg/m2
}
if("lon" %in% names(ncin$dim)){
  lon_veg = ncvar_get(ncin,"lon")
  lat_veg = ncvar_get(ncin,"lat")
} else {
  lon_veg = ncvar_get(ncin,"longitude")
  lat_veg = ncvar_get(ncin,"latitude")
}
tunits_veg   <- ncatt_get(ncin, "time", "units")$value
tcal_att_veg <- ncatt_get(ncin, "time", "calendar")
time_in_veg  <- ncvar_get(ncin, "time")
nc_close(ncin)

## align gpp and cVeg:
if(min(lon) >= -1){
 lon = lon-179.95
 nx = dim(gpp)[1]
 gpp = gpp[c((nx/2+1):nx,1:(nx/2)),,]
}
if(min(lon_veg) >= -1){
 lon_veg = lon_veg-179.95
 nx = dim(cVeg)[1]
 cVeg = cVeg[c((nx/2+1):nx,1:(nx/2)),,]
}

if(lat[1] > 0){
  lat = rev(lat)
  gpp = gpp[,rev(seq(lat)),]
}
if(lat_veg[1] > 0){
  lat_veg = rev(lat_veg)
  cVeg = cVeg[,rev(seq(lat_veg)),]
}

##
# ---- time alignment (NEW) ----
A <- align_time_for_tau(time_in, tunits, time_in_veg, tunits_veg)

# Subset arrays to matched years
gpp_y   <- gpp[,, A$idx_gpp_y, drop = FALSE]
cVeg_y  <- cVeg[,,A$idx_veg_y, drop = FALSE]
cVeg_y1 <- cVeg[,,A$idx_veg_y1, drop = FALSE]

# delta cVeg for matched years
cVeg_delta <- cVeg_y - cVeg_y1

# tau for matched years
tau <- cVeg_y / (gpp_y - cVeg_delta)
tau[!is.finite(tau)] <- NA

# set upper and lower limits:
tau[tau < 0] = 0
tau[tau > 15] = 15

#cVeg_delta_total = cVeg_y[,,dim(cVeg_y)[3]] - cVeg_y1[,,1]

#tau_total = apply(cVeg_y,c(1,2),sum,na.rm=T) / (apply(gpp_y,c(1,2),sum,na.rm=T) - cVeg_delta_total)

# Use explicit annual bounds for ILAMB comparability
tau_years <- A$tau_years
time_tau = time[years_full %in% tau_years]
time_bnds <- tbnd[,years_full %in% tau_years]
# ------------------------------

# create ncdf
londim <- ncdim_def("lon","degrees_east",as.double(lon))
latdim <- ncdim_def("lat","degrees_north",as.double(lat))
timedim <- ncdim_def("time", "days since 1700-01-01 00:00:00", as.double(time_tau),
                     unlim = TRUE, calendar = "365_day")

nbdim <- ncdim_def("nb", "", 1:2, create_dimvar = FALSE)

var_tau <- ncvar_def("biomass_tau","years", list(londim, latdim, timedim),
                     -999., "biomass turnover time")

var_tbnd <- ncvar_def("time_bnds", tunits_veg, list(nbdim, timedim),
                      -999., "time interval bounds")
##

ncout <- nc_create(f_tau, list(var_tau, var_tbnd), force_v4 = TRUE) # , var_tbnd

# write data
ncvar_put(ncout, "biomass_tau", tau)
ncvar_put(ncout, "time_bnds", time_bnds)

# CF metadata: tell ILAMB that time has bounds
ncatt_put(ncout, "time", "bounds", "time_bnds")

nc_close(ncout)
}


# JULES 0.125
fil_gpp = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/models/JULES_0.125/gpp_annual.nc"
fil_cVeg = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/models/JULES_0.125/cVeg.nc"
fil_tau = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/models/JULES_0.125/biomass_tau.nc"

create_tau_file(fil_gpp,fil_cVeg,fil_tau)

# JULES GCB2025:
fil_gpp = "/home/links/mo339/shared/mo339/data/JULES_RUNS/trendy-gcb2025/JULES_S3_gpp_annual.nc"
fil_cVeg = "/home/links/mo339/shared/mo339/data/JULES_RUNS/trendy-gcb2025/JULES_S3_cVeg.nc"
fil_tau = "/home/links/mo339/shared/mo339/data/JULES_RUNS/trendy-gcb2025/JULES_S3_biomass_tau.nc"

create_tau_file(fil_gpp,fil_cVeg,fil_tau)

# JULES MRLC:
fil_gpp = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/S3_EU/process/create_diagnostic_vars/gpp_annual_MRLC.nc"
fil_cVeg = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/S3_EU/process/create_diagnostic_vars/cVeg_annual_MRLC.nc"
fil_tau = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/S3_EU/process/create_diagnostic_vars/biomass_tau_MRLC.nc"

create_tau_file(fil_gpp,fil_cVeg,fil_tau)

# JULES HILDA:
f_gpp = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/S3_EU/process/create_diagnostic_vars/gpp_annual_HILDA.nc"
f_cVeg = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/S3_EU/process/create_diagnostic_vars/cVeg_annual_HILDA.nc"
f_tau = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/S3_EU/process/create_diagnostic_vars/biomass_tau_HILDA.nc"

create_tau_file(f_gpp,f_cVeg,f_tau)

# Xu_FLUXCOM:
f_gpp = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/data/GPP_0.1d_annual.nc"
f_cVeg = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/data/biomass_xu_ilamb.nc"
f_tau = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/data/tau_biomass_xu_fluxcom.nc"

create_tau_file(f_gpp,f_cVeg,f_tau)

# ESA_FLUXCOM:
fil_gpp = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/data/GPP_0.1d_annual.nc"
fil_cVeg = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/data/esa_cci_biomass_ilamb.nc"
fil_tau = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/data/tau_biomass_esa-cci_fluxcom.nc"

create_tau_file(fil_gpp,fil_cVeg,fil_tau)

# ESA6.0_FLUXCOM:
fil_gpp = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/data/GPP_0.1d_annual.nc"
fil_cVeg = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/data/ESA_biomass_2007-2022.nc"
fil_tau = "/home/links/mo339/shared/mo339/JULES_run/EU_highres/ilamb/data/tau_biomass_esa6.0_fluxcom.nc"

create_tau_file(fil_gpp,fil_cVeg,fil_tau)
