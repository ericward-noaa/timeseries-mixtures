library(MARSS)

set.seed(123)
# generate matrix of values (x) -- underlying trends
x <- matrix(0, 2, 50)
x[,1] <- rnorm(2,0,1)
for(i in 2:ncol(x)) {
  x[1,i] = rnorm(1, 0.8*x[1,i-1], 0.1)
  x[2,i] = rnorm(1, 0.8*x[2,i-1], 0.1)
}
# yys 
y1 <- data.frame(id = 1, y = rnorm(100, x[1,], 0.01), year = 1:100)
y2 <- data.frame(id = 2, y = rnorm(100, x[1,], 0.01), year = 1:100)
y3 <- data.frame(id = 3, y = rnorm(100, x[2,], 0.01), year = 1:100)
y4 <- data.frame(id = 4, y = rnorm(100, x[2,], 0.01), year = 1:100)
y5 <- data.frame(id = 5, y = rnorm(100, x[2,], 0.01), year = 1:100)
yy <- rbind(y1,y2,y3,y4,y5)

d <- y1$y
N <- length(d)

y <- yy$y

data_list <- list(
N = nrow(yy),
K = 2,
n_pos = length(y),
n_ts = 5,
n_years = 100,
int_ts = yy$id,
int_year = yy$year,
y = y)

library(rstan)
fit <- stan(file = "cluster_ts.stan", chains = 1, iter=1000, data = data_list)
pars <- rstan::extract(fit)
plot(apply(pars$x[,1,],2,mean), type="l")
plot(apply(pars$x[,2,],2,mean), type="l")

apply(pars$theta,c(2,3),mean)