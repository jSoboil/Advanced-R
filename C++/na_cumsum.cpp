# include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector cumsumC(NumericVector x, bool na_rm = false) {
 int n = x.size();
 NumericVector out(n);
 
 out[0] = x[0];
 for (int i = 1; i < n; ++i) {
  if (na_rm == true && NumericVector::is_na(x[i])) {
   out[i] = NA_REAL;
   warning("Warning: Contains missing values.");
  } else {
   out[i] = out[i - 1] + x[i];
  }
 }
 return out;
}