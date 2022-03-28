# SSC 2022 Case Competition

Team Members: Sonny Min, Daisy Yu, Olga Vishnyakova, and Renny Doig  
Faculty Supervisor: Lloyd Elliott  


### Goals (stated on the case-study website):
* A statistical analysis of the current realized and forecasted internet speeds (upload and download) for rural and underserved communities in terms of progress towards the Commitment;
* A comparative analysis of rural and underserved communities in terms of progress towards the Commitment; and
* The identification of statistically reliable methods to assess and compare rural and underserved communities's realized internet access.

<br />


### What do we want to achieve?
* We want to help policy makers identify the regions that need more attention to achieve the **minimum speeds of 50 Mbps download and 10 Mbps upload (hereinafter referred to as the “Commitment”) by 2026, and 100% by 2030**. 
  * Identify which regions currently have poor internet qualities.
  * Identify which regions are showing relatively slower increases in the internet quality over time.

<br />

### Terminology
* tiles: refer to each observation.
* regions, clusters: refer to groups of tiles.

<br />


### Tasks

#### 1. Tile classification / regionalization
* A lot of tiles have missing download/upload/latency data. We can choose to impute them or aggregate the tiles.
* How to merge (dissolve) nearby tiles together?
  * Use existing classifications: Municipality, census division, etc
    * Why choose one over the other?
      * In the policy-making perspective, division by municipalities would make more sense.
      * But we do not have the municipality boundary data. Must find and import from external sources. May be not feasible. 
    * Olga and Daisy's explorations on Canada & Alberta look good.
    * Do we have unique CDNAME or CDUID for all provinces?
      * NW territories: looks good
      * Yukon: has only one CDNAME across the province.
  * Other ways to merge(dissolve) the nearest-k tiles together.
    * 'Spatial Regionalization': clustering where the objective is to group observations which are similar in their statistical attributes, but also in their spatial location.
      * Daisy's method showed that there were many clusters with only one tile.
  * For now, we shall use the census division. We can test different clustering methods and see which one gives us the best result later.
  

<br />

### 2. Model selection
* Forecasting internet speeds (upload and download): time-series problem.
  * Metric:
    * We can use 'leave-the-latest-out'. Fit our models using t to T-1 data, and test the model performance on the 2021-Q4 data.
  * The most intuitive model would be the ARIMA-type model.
    * Recursive AR using scikit-learn: https://www.cienciadedatos.net/documentos/py27-time-series-forecasting-python-scikitlearn.html
  * The mixed effects model.
>    $ Y_{d} = \alpha + \beta_1 X_1 + \beta_2 X_2 $

    where $Y_d$: download speed, $X_1$: time (fixed effect), $X_2$:  a category (random effect). $\beta_2 \sim N(\mu, \sigma)$.
* Comparison between the regions.
  * ANOVA between the nearby regions?
