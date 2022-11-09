data {
  int<lower=0> N; // number of data points
  int<lower=0> K; // number of trends
  int<lower=0> n_pos;
  int<lower=0> n_years;
  int<lower=0> n_ts; // number of time series
  int int_year[n_pos]; // data, sex in training set (1,2)
  int int_ts[n_pos];
  vector[n_pos] y; // data
}
parameters {
  vector[K] x0; // initial state
  vector<lower=0>[K] sigma_pro;
  vector[K] u;
  vector<lower=0>[1] sigma_obs;
  vector[K] devs[n_years-1];
  simplex[K] theta[n_ts];
}
transformed parameters {
  matrix[K,n_years] x; //vector[N] x[P]; // random walk-trends
  vector[K] log_theta[n_ts];
  for(k in 1:n_ts) {log_theta[k] = log(theta[k]);}
  for(k in 1:K) {  
    x[k,1] = x0[k];
    for(t in 2:n_years) {
      x[k,t] = x[k,t-1] + u[k] + devs[t-1,k]*sigma_pro[k];
    }
  }

}
model {
  x0 ~ normal(0, 1); // initial state estimate at t=1
  for(k in 1:K) devs[k] ~ normal(0,1);
  u ~ normal(0,1);
  sigma_pro ~ student_t(3,0,2);
  sigma_obs ~ student_t(3,0,2);
  
  for (n in 1:n_pos) {
    vector[K] lps = log_theta[int_ts[n]];
    // calculate likelihood over all groups
    for (j in 1:K) { 
      lps[j] += normal_lpdf(y[n] | x[j, int_year[n]], sigma_obs[1]);
    }
    target += log_sum_exp(lps);
  }
}
