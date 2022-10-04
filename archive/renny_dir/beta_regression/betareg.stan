// Project: SSC 2022 Case Study Competition
// Purpose: Stan file for the one-inflated beta regression
// Date: March 30, 2022
// Author: Renny Doig


data {
  int<lower=0> n;
  vector[n] y;
  matrix[n, 4] x;
}


parameters {
  vector[4] beta;
  vector[4] alpha;
  real<lower=0> phi;
}

model {
  for(i in 1:n)
  {
    real p = inv_logit(sum(alpha * x[i,]));
    
    if(y[i] == 1){
      target += log(p);
    } else{
      real mu = inv_logit(sum(beta * x[i,]));
      
      target += log(1-p) + beta_lpdf(y[i] | mu*phi , (1-mu)*phi);
    }
  }
}

