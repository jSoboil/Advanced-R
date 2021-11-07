# include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector diffC(NumericVector x) {
 int n = x.size();
 NumericVector out(n - 1);
 
 for (int i = 1; i < n; ++i) {
  out[i - 1] = x[i] - x[i - 1];
 }
 return out;
}