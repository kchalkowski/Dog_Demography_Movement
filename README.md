# Free-roaming dog movement and demography in Andasibe-Mantadia, Madagascar

## Objectives
1. Describe home range sizes, movement kernels, and resource preference of free-roaming dogs in Andasibe-Mantadia, Madagascar
2. Determine whether movement characteristics are significantly associated with village characteristics

## Pipeline Overview   

### Data 
1. Village polygons   
2. Village info (N houses)
3. Dog geolocation data
4. Dog collaring metadata
5. Land class raster

### Processing    
1. Pull in all data objects
2. Link spatial village polygons to village data
3. Determine distance to Andasibe for each polygon
4. Join dog geolocation data to village metadata based on dog collaring location
5. Join dog geolocation data to land cover data

### Movement Analysis 
1. Resample geolocation data
2. Run integrated step-selection function for each individual on resampled tracks
3. Compare resource preference coefficients for forest and open for each dog...    
	a. between villages.   
	b. within housing densities.   
	c. with varying distance to Andasibe.   
	d. with distance from forest.   

### Home range Analysis    
1. Run CTMMs for each individual
2. Determine home range size... other stuff?
