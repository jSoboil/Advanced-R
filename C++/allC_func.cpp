#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
bool allC(LogicalVector x) {
 int n = x.size();
 
 for (int i = 0; i < n; ++i) {
  if (!x[i]) return false;
 }
 return true;
}