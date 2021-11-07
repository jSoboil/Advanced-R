# include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector diffC(NumericVector x, int lag = 1) {
 int n = x.size();
 
 if (lag >= n) stop("`lag` must be less than `length(x)`.");
 
 NumericVector out(n - lag);
 
 for (int i = lag; i < n; ++i) {
  out[i - lag] = x[i] - x[i - lag];
 }
 return out;
}