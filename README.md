## Ensembles of mixed-effects and ARIMA models for forecasting and comparing internet access in underserved Canadian communities

For [**2022 SSC Annual Meeting Case Competition #2**](https://ssc.ca/en/case-study/towards-a-clear-understanding-rural-internet-what-statistical-measures-can-be-used-assess)

* [Sonny Min](https://www.linkedin.com/in/joosung-sonny-min-35370b9b/), [Renny Doig](https://www.linkedin.com/in/renny-doig-b6b162a5/), [Daisy Yu](https://www.linkedin.com/in/ying-daisy-yu-50b8bb103/) and [Olga Vishnyakova](https://www.linkedin.com/in/olgavishnyakova/) (supervisor: Dr. [Lloyd T. Elliott](https://elliottlab.ca/))
* Selected for **Cybera's choice award**
* [Interactive web application](https://shiny.rcg.sfu.ca/u/rennyd/internet_5speed_canada/)

![This is an image](/poster_SFU.png)


<br />

<!------ To be edited 
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
    * In terms of the number of observations we can work with, dissemination blocks > dissemination areas (>50k instances) > municipalities (='census subdivisions'. >5k instances) > census divisions (~293 instances) > Provinces.
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
      * <s>https://geographicdata.science/book/notebooks/11_regression.html</s> > did not work...
      * https://ranasinghiitkgp.medium.com/time-series-forecasting-using-lstm-arima-moving-average-use-case-single-multi-variate-with-code-5dd41e32d1fc
    * (Daisy) The mixed effects model Y<sub>d</sub> = &alpha; + &beta;<sub>1</sub> X<sub>1</sub> + U<sub>j</sub> + W<sub>ij</sub>
      * where Y<sub>d</sub>: download speed, X<sub>1</sub>: time (fixed effect), U<sub>j</sub> a category-specific random effect, W<sub>ij</sub>: an individual-specific random effect.
      * https://watermark.silverchair.com/kxh014.pdf?token=AQECAHi208BE49Ooan9kkhW_Ercy7Dm3ZL_9Cf[…]OvVzFjg_NEYgj8OjvJwjHJKs6AuvhqMfsPRp3NRIoAMdjZuVtl1VGlRJ
    * (Renny) Beta regression: 
      * https://sst-stats-sfu.slack.com/files/U010MPK0QHM/F039QQ1S916/beta_regression_for_modelling_rates_and_proportions.pdf
    * Bayesian methods? (need ref) Too niche?
  * conn_type seems to be an important factor to include in the models
* Comparison between the regions.
  * ANOVA between the nearby regions?

### 3. Model performance
* We can use 'leave-the-latest-out'. Fit our models using t to T-1 data, and test the model performance on the 2021-Q4 data



### 4. Comparing regions

* The second and third outcomes for the case competition are:
  * "comparative analysis of rural and underserved communities in terms of progress towards the Commitment"
  * "identification of statistically reliable methods to assess and compare rural and underserved communities' realized internet access"
* The first point seems to be looking for results that compare several regions in terms of the Commitment; the second for a statistically sound method (e.g. hypothesis test) for comparing internet access between regions
* Key distinctions are: 1) first emphasizes results and second emphasizes methodology, and 2) first is concerned exclusively with the Commitment while the second is focused on internet access more generally
* 1) To assess whether or not a region has achieved the target we could generate confidence/prediction intervals and check whether they capture the target
  * For the "in terms of progress" part we could perform a similar test for 25\%, 50\%, etc. of the Commitment and compare results at each level
* This interval could also be used for pairwise comparisons between regions
  * Might need to consider whether a Bonferroni-style correction would result in numerical issues given the large number of regions
* Need to look into hypothesis testing for mixed effect models

---->
