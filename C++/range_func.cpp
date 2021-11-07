# include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector rangeC(NumericVector x) {
 double omin = x[0], omax = x[0];
 int n = x.size();
 
 if (n == 0) stop("`length(x)` must be greater than 0.");
 
 for (int i = 1; i < n; i++) {
  omin = std::min(x[i], omin);
  omax = std::max(x[i], omax);
 }
 
 NumericVector out(2);
 out[0] = omin;
 out[1] = omax;
 return out;
}