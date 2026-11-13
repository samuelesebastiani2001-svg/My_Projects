# S&P 500 Implied Volatility Plots

## Introduction

This script visualizes S&P 500 option data stored in a CSV file (`SP500_dataset.csv`). It uses `pandas` and `matplotlib` to plot implied volatility against strike for two specific trading days, one in September 2018 and one in September 2017.

## What the code does

1. Loads `SP500_dataset.csv` from the same folder as the script and converts the `Date` column to a proper datetime format.
2. Keeps only the rows that fall on a Friday in September (this was an assignment request).
3. Reads the numeric column names (the strike values, e.g. 0.8, 0.9, ...) and uses them as the labels of the x-axis. The ticks are placed at equal distances from each other, regardless of the numeric gap between strikes.
4. Splits the data into two days: 28 September 2018 and 29 September 2017.
5. For each of the two days, sorts the rows by `T` and draws one scatter plot per row, where each point is the implied volatility at a given strike.

## Output

The script opens two figures, one after the other:

- **Figure 1:** the data of Friday 28 September 2018.
- **Figure 2:** the data of Friday 29 September 2017.

Each figure is laid out as a 2x4 grid with 7 plots (the last empty slot is removed), arranged in order of increasing `T`:

- Each plot has its own title showing the corresponding `T` value.
- The x-axis shows the strike and the y-axis shows the implied volatility ("Imp Vol"). Each red dot is the implied volatility observed at one strike.
- Plotting the points of each `T` separately makes it possible to see how the shape of the implied volatility changes across different `T` values on the same day.

