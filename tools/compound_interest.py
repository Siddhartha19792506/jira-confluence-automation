import argparse


def calculate_compound_interest(principal, annual_rate_percent, compounds_per_year, years):
    rate = annual_rate_percent / 100.0
    exponent = compounds_per_year * years
    final_amount = principal * (1 + rate / compounds_per_year) ** exponent
    interest_earned = final_amount - principal
    return final_amount, interest_earned


def parse_args():
    parser = argparse.ArgumentParser(
        description="Calculate compound interest and interest earned."
    )
    parser.add_argument("principal", type=float, help="Initial principal amount")
    parser.add_argument(
        "annual_rate",
        type=float,
        help="Annual interest rate in percent (for example, 5 for 5%%)",
    )
    parser.add_argument(
        "compounds_per_year",
        type=int,
        help="Number of compounding periods per year",
    )
    parser.add_argument("years", type=float, help="Total number of years")
    return parser.parse_args()


def validate_inputs(principal, compounds_per_year, years):
    if principal < 0:
        raise ValueError("Principal must be non-negative.")
    if compounds_per_year <= 0:
        raise ValueError("Compounds per year must be greater than zero.")
    if years < 0:
        raise ValueError("Years must be non-negative.")


def main():
    args = parse_args()

    validate_inputs(args.principal, args.compounds_per_year, args.years)

    final_amount, interest_earned = calculate_compound_interest(
        args.principal,
        args.annual_rate,
        args.compounds_per_year,
        args.years,
    )

    print(f"Final Amount: {final_amount:.2f}")
    print(f"Interest Earned: {interest_earned:.2f}")


if __name__ == "__main__":
    main()
