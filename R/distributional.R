#' Distributional weight for a recipient income
#'
#' Returns the Green Book distributional weight applied to net
#' benefits accruing to a recipient at income `income`, relative to
#' a reference income (median by default), under iso-elastic utility:
#'
#' \deqn{w_i = (y_{ref} / y_i) ^ \eta}
#'
#' Default `eta = 1.3` per HM Treasury Green Book Annex A3. Higher
#' eta places greater weight on lower-income recipients; sensitivity
#' tests at `eta = 0.8` and `eta = 2.0` are conventional.
#'
#' @param income Numeric vector of recipient incomes (positive).
#'   Equivalised household disposable income is the conventional
#'   measure.
#' @param eta Numeric scalar. Income elasticity of marginal utility
#'   of income. Default `1.3`.
#' @param reference Either `"median"` (default; use median of
#'   `income` or `income_data` if supplied) or a numeric scalar
#'   (use that income as reference).
#' @param income_data Optional numeric vector. Reference income
#'   distribution for computing the median. Use, e.g., the ONS
#'   household disposable income distribution. If `NULL` (default),
#'   the median of `income` is used.
#'
#' @return A numeric vector of weights, same length as `income`.
#'
#' @references
#' HM Treasury (2022). The Green Book, Annex A3 on distributional
#' analysis.
#'
#' Acland, D. and Greenberg, D.H. (2024). The Elasticity of Marginal
#' Utility of Income for Distributional Weighting and Social
#' Discounting: A Meta-Analysis. Journal of Benefit-Cost Analysis.
#'
#' @family distributional
#' @seealso [gb_dist_weighted_npv()].
#'
#' @export
#' @examples
#' # Weights across deciles of a stylised income distribution
#' income_deciles <- seq(10000, 100000, length.out = 10)
#' gb_dist_weight(income_deciles)
gb_dist_weight <- function(income, eta = 1.3, reference = "median",
                           income_data = NULL) {
  validate_numeric(income, "income", require_positive = TRUE)
  validate_numeric(eta, "eta")
  if (length(eta) != 1L) cli::cli_abort("{.arg eta} must be scalar.")

  if (is.character(reference) && length(reference) == 1L && reference == "median") {
    if (!is.null(income_data)) {
      validate_numeric(income_data, "income_data", require_positive = TRUE)
      ref_income <- stats::median(income_data)
    } else {
      ref_income <- stats::median(income)
    }
  } else if (is.numeric(reference) && length(reference) == 1L) {
    if (reference <= 0) cli::cli_abort("{.arg reference} must be > 0.")
    ref_income <- reference
  } else {
    cli::cli_abort("{.arg reference} must be {.val median} or a positive numeric scalar.")
  }

  (ref_income / income) ^ eta
}

#' Distributionally-weighted net present value
#'
#' Applies recipient-income distributional weights to a cashflow
#' before discounting under the STPR.
#'
#' @param cashflow Numeric vector of net cashflows (per period).
#' @param recipient_income Numeric vector. The income of the
#'   recipient (or representative recipient cell) in each period.
#'   Must have the same length as `cashflow`.
#' @param eta Numeric scalar. Default `1.3`.
#' @param schedule One of `"standard"`, `"health"`, `"catastrophic"`.
#' @param reference Reference income strategy passed to
#'   `gb_dist_weight()`.
#' @param income_data Optional reference income distribution.
#' @param vintage Methodology vintage label. Default `"2022"`.
#' @param base_year Optional integer base year stored on the result.
#'
#' @return A `gb_appraisal` object with extra fields `weights`,
#'   `eta`, and `unweighted_npv`.
#'
#' @references HM Treasury (2022). The Green Book, Annex A3 on
#'   distributional analysis.
#'
#' @family distributional
#' @seealso [gb_dist_weight()], [gb_npv()].
#'
#' @export
#' @examples
#' # 5-year benefit stream of GBP 30 going to a low-decile recipient
#' gb_dist_weighted_npv(
#'   cashflow = rep(30, 5),
#'   recipient_income = rep(15000, 5),
#'   income_data = seq(10000, 100000, length.out = 10)
#' )
gb_dist_weighted_npv <- function(cashflow, recipient_income, eta = 1.3,
                                 schedule = "standard",
                                 reference = "median",
                                 income_data = NULL,
                                 vintage = "2022",
                                 base_year = NULL) {
  validate_numeric(cashflow, "cashflow")
  if (length(cashflow) != length(recipient_income)) {
    cli::cli_abort("{.arg cashflow} and {.arg recipient_income} must have equal length.")
  }

  weights <- gb_dist_weight(recipient_income, eta = eta,
                            reference = reference,
                            income_data = income_data)
  weighted_cashflow <- cashflow * weights

  unweighted <- gb_npv(cashflow, schedule = schedule,
                      base_year = base_year, vintage = vintage)
  weighted <- gb_npv(weighted_cashflow, schedule = schedule,
                    base_year = base_year, vintage = vintage)

  weighted$weights <- weights
  weighted$eta <- eta
  weighted$unweighted_npv <- unweighted$npv
  weighted
}
