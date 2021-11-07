# include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double varC(NumericVector x) {
 int n = x.size();
 
 if (n < 2) {
  return NA_REAL;
 }
 
 double mx = 0;
 for (int i = 0; i < n; ++i) {
  mx += x[i] / n;
 }
 
 double out = 0;
 for (int i = 0; i < n; ++i) {
  out += pow(x[i] - mx, 2);
 }
 
 return out / (n - 1);
}