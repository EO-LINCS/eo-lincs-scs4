library(ncdf4)

n = c(0,31,59,90,120,151,181,212,243,273,304,334,365)
nyrs = 30
len = nyrs*12
tbnd = array(NA,dim=c(2,len))

for(y in 1:nyrs){
  ni = n + ((y-1)*365)
  for(z in 1:12){
    tbnd[,((y-1)*12+1)+(z-1)] = ni[z:(z+1)]
  }
}
time = apply(tbnd,c(2),mean)

nc = nc_open("LAI_monthly_1991_2020.nc",write=T)
time_units <- ncatt_get(nc, "time", "units")$value
time_cal   <- ncatt_get(nc, "time", "calendar")$value

ncvar_put(nc, "time", time)
ncvar_put(nc, "time_bnds", tbnd)

ncatt_put(nc, "time", "bounds", "time_bnds")
ncatt_put(nc, "time", "calendar", "365_day")

nc_close(nc)

