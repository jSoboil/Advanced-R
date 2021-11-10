# include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector na_rangeC(NumericVector x, bool na_rm = false) {
 double omin = x[0], omax = x[0];
 int n = x.size();
 
 if (n == 0) stop("`length(x)` must be greater than 0.");
 
 for (int i = 0; i < n; ++i) {
  if (na_rm == true && NumericVector::is_na(x[i])) {
   NumericVector out_na(1);
   out_na = NA_REAL;
   return out_na;
   } else {
    omin = std::min(x[i], omin);
    omax = std::max(x[i], omax);
    }
   }
 NumericVector out(2);
 out[0] = omin;
 out[1] = omax;
 return out;
 }