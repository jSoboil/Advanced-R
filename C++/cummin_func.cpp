# include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector cumminC(NumericVector x) {
 int n = x.size();
 NumericVector out(n);
 
 // Vector indices start at 0!
 out[0] = x[0];
 for(int i = 1; i < n; ++i) {
  // Use standard C++ function library:
  out[i] = std::min(out[i - 1], x[i]);
 }
 return out;
}