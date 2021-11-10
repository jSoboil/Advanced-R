# include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
LogicalVector is_naC(NumericVector x) {
 int n = x.size();
 LogicalVector out(n);
 
 for (int i = 0; i < n; ++i) {
  out[i] = NumericVector::is_na(x[i]);
 }
 
 return out;
}