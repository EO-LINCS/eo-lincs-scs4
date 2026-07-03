 library(raster)
 library(terra)
 
 nyrs = 121
 
 hilda_pfts = array(NA,dim=c(560,304,17,121))
 
for(y in 1:121){
 print(y)
   
  r=raster("hildaplus_GLOB-1-0-f_states.nc", band = y)
 
 e = extent(-25,45,35,73)
 
 re <- crop(r, e)
 
 r01 <- rast(re)

# Make a 0.125° template grid over the same extent
tmpl <- rast(ext(r01), resolution = 0.125, crs = crs(r01))
# Align template nicely (optional but helps)
tmpl <- resample(tmpl, tmpl)  # no-op but keeps it explicit

# Helper to make fraction layer for a code
frac_code <- function(code) {
  x <- (r01 == code)          # logical SpatRaster
  x <- as.numeric(x)          # 0/1
  resample(x, tmpl, method = "bilinear")  # bilinear on 0/1 -> fraction
}

# HILDA code fractions at 0.125°
f_urban   <- frac_code(11)
f_crop    <- frac_code(22)
f_pasture <- frac_code(33)
f_unkfor  <- frac_code(40)
f_enl     <- frac_code(41)
f_ebl     <- frac_code(42)
f_dnl     <- frac_code(43)
f_dbl     <- frac_code(44)
f_mixed   <- frac_code(45)
f_grass   <- frac_code(55)
f_other   <- frac_code(66)
f_water   <- frac_code(77)

# Stack into JULES 17 tiles (SpatRaster with 17 layers)
j <- rast(tmpl)

j <- c(j, j, j, j, j, j, j, j, j, j, j, j, j, j, j, j, j) # total 17
            
j[[1]]  <- f_dbl + 0.5*(f_mixed + f_unkfor)          # BL Decid
j[[2]]  <- 0                                         # BL Everg Trop
j[[3]]  <- f_ebl                                     # BL Everg Temp
j[[4]]  <- f_dnl                                     # NL Decid
j[[5]]  <- f_enl + 0.5*(f_mixed + f_unkfor)          # NL Everg
j[[6]]  <- f_grass                                   # C3 grass
j[[7]]  <- f_crop                                    # C3 crop
j[[8]]  <- f_pasture                                 # C3 pasture
j[[9]]  <- 0; j[[10]] <- 0; j[[11]] <- 0             # C4 splits later
j[[12]] <- 0; j[[13]] <- 0                           # shrubs = 0
j[[14]] <- f_urban
j[[15]] <- f_water
j[[16]] <- f_other                                   # bare
j[[17]] <- 0                                         # ice = 0

names(j) <- c("BD","BET","BETemp","ND","NE","C3G","C3C","C3P","C4G","C4C","C4P","SD","SE","Urban","Water","Bare","Ice")

ar = as.array(j)
ar = aperm(ar,c(2,1,3))
ar = ar[,rev(seq(304)),]

ar[is.na(ar)] = 0.0

hilda_pfts[,,,y] = ar

}

save(hilda_pfts,file="hilda_pfts_Europe.RData")


library(ncdf4)

lon = seq(-24.9375,44.9375,length.out = 560)
lat = seq(35.0625,72.9375,length.out = 304)

londim <- ncdim_def("lon","degrees_east",as.double(lon))
latdim <- ncdim_def("lat","degrees_north",as.double(lat))

tbnd = array(NA,dim=c(2,nyrs))
        
        for(y in 1:nyrs){
          in1 = (365*y)-364
          in2 = (365*y)
          tbnd[,y] = c(in1,in2)
        }
time = apply(tbnd,c(2),mean)
        
timedim <- ncdim_def("time","days since 1899-01-01 00:00:00",as.double(time),unlim = T,calendar = "noleap") 

pdim <- ncdim_def("tile","",seq(17))
info = "BL Decid, BL Everg - Trop, BL Everg - Temp, NL Decid, NL Everg, C3 Grass, C3 Crop, C3 Pasture, C4 Grass, C4 Crop, C4 Pasture, Shrub Decid, Shrub Everg, Urban, Water, Bare Ground, Ice"

var_def <- ncvar_def("PFT_frac","fraction",list(londim,latdim,pdim,timedim),-999.,"PFT fractions")

ncout <- nc_create("hilda_pfts_Europe.nc",list(var_def),force_v4=T)

ncvar_put(ncout,"PFT_frac",hilda_pfts)

ncatt_put(ncout,0,pdim$name,info)
ncatt_put(ncout,0,"contact","m.osullivan@exeter.ac.uk")
nc_close(ncout)
