# Free-roaming dog movement and demography in Andasibe-Mantadia, Madagascar

## Objectives
1. Describe home range sizes, movement kernels, and resource preference of free-roaming dogs in Andasibe-Mantadia, Madagascar
2. Determine whether movement characteristics are significantly associated with village characteristics

## Pipeline Overview   

### Processing    
1. Link spatial village polygons to village data
2. Determine distance to Andasibe for each polygon
3. Join dog geolocation data to village metadata based on dog collaring location
4. Join dog geolocation data to land cover data

### Analysis    
1. Run integrated step-selection function for each individual-- pull distribution of RSF coefs
2. Compare resource preference coefficients for forest and open for each dog...
	a. between villages
	b. within housing densities
	c. with varying distance to Andasibe
	d. with distance from forest