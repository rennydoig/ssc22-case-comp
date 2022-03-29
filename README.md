SC 2022 Case Competition

Website: https://ssc.ca/en/case-study/towards-a-clear-understanding-rural-internet-what-statistical-measures-can-be-used-assess

Team Members: Sonny Min, Daisy Yu, Olga Vishnyakova, and Renny Doig  
Faculty Supervisor: Lloyd Elliott  

<br />


## Goals (stated on the case-study website):
* A statistical analysis of the current realized and forecasted internet speeds (upload and download) for rural and underserved communities in terms of progress towards the Commitment;
* A comparative analysis of rural and underserved communities in terms of progress towards the Commitment; and
* The identification of statistically reliable methods to assess and compare rural and underserved communities's realized internet access.

<br />


## What do we want to achieve?
* We want to help policy makers identify the regions that need more attention to achieve the **minimum speeds of 50 Mbps download and 10 Mbps upload (hereinafter referred to as the “Commitment”) by 2026, and 100% by 2030**. 
  * Identify which regions currently have poor internet qualities.
  * Identify which regions are showing relatively slower increases in the internet quality over time.

<br />

## Terminology and variables
* tiles: refer to each observation.
* regions, clusters: refer to groups of tiles.
* Variables: see https://ssc.ca/en/case-study/towards-a-clear-understanding-rural-internet-what-statistical-measures-can-be-used-assess for detailed descriptions
    
<br />


## Tasks

### 1. Tile clustering / regionalization
* A lot of tiles have missing download/upload/latency data. We can choose to impute them or aggregate the tiles.
* How to merge (dissolve, aggregate) nearby tiles together?
  * Use the existing classifications: Municipality, census division, etc
    * In terms of the number of observations we can work with, DA > municipalities (or electorial divisions) >= census divisions > Provinces.
    * DA vs CD vs. Municipalities: 
      * Have not tried aggregation by DA yet but we can expect the largest number of training instances from DA.
      * In the policy-making perspective, division by municipalities would make more sense.
         * However, we do not have the municipality boundary data in the original dataset. Must find and import from external sources. May be not feasible. 
      * Olga and Daisy's explorations using the census division on Canada & Alberta data look good.
      * Do we have many unique CDNAME or CDUID for all provinces?
        * Some provinces have only 1(Yukon) or 3(Nunavut) CDNAME across the provinces.
        * Some CDNAMEs could be repeated in some provinces. Better to use CDUID.
  * Other ways to merge(dissolve) the nearest-k tiles together.
    * 'Spatial Regionalization': clustering where the objective is to group observations which are similar in their statistical attributes, but also in their spatial location. 
    * Clustering based only on the polygon data showed that there were many clusters with only one tile.
    * DBSCAN clustering looks okay.
    * Can try the k-nearest neighbours method described on https://geographicdata.science/book/notebooks/10_clustering_and_regionalization.html
  * For now, we shall use the census division and try several models first. We can test different clustering methods once we have some solid model.
  

### 2. Model selection
* We want our model parameters and outputs to be interpretable to be able to produce some actionable statement.
  * Rules out DNN, random forests, etc  
* Forecasting internet speeds (upload and download): 
  * Models to consider:
    * Since it looks like a time-series problem the most intuitive model would be the ARIMA-type models.
    * (Olga) Recursive AR using scikit-learn: https://www.cienciadedatos.net/documentos/py27-time-series-forecasting-python-scikitlearn.html
    * (Sonny) Spatial Autocorrelation and regression: 
      * https://geographicdata.science/book/notebooks/06_spatial_autocorrelation.html
      * https://geographicdata.science/book/notebooks/11_regression.html
    * (Daisy) The mixed effects model Y<sub>d</sub> = &alpha; + &beta;<sub>1</sub> X<sub>1</sub> + U<sub>j</sub> + W<sub>ij</sub>
      * where Y<sub>d</sub>: download speed, X<sub>1</sub>: time (fixed effect), U<sub>j</sub> a category-specific random effect, W<sub>ij</sub>: an individual-specific random effect.
    * (Renny) Beta regression: 
      * https://sst-stats-sfu.slack.com/files/U010MPK0QHM/F039QQ1S916/beta_regression_for_modelling_rates_and_proportions.pdf
    * Bayesian methods? (need ref) Too niche?
  * conn_type seems to be an important factor to include in the models
* Comparison between the regions.
  * ANOVA between the nearby regions?

### 3. Model performance
* We can use 'leave-the-latest-out'. Fit our models using t to T-1 data, and test the model performance on the 2021-Q4 data.


---

(28 March 2022)
* Each member tries a forecasting model using data aggregated by DAUID, CDUID

