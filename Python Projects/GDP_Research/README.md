# GDP and Life Expectancy Analysis (Gapminder)

A Python script that explores the dataset using `pandas` and `matplotlib`. It looks at how GDP per capita evolves over time, worldwide and by continent, and at how strongly life expectancy correlates with GDP per capita in each country.

## What the script does

1. **Worldwide GDP per capita over time.** Computes total GDP for each country, sums GDP and population by year, and divides them. This gives a population-weighted average rather than a simple mean of country values. The result is shown as a line plot.
2. **GDP per capita by continent over time.** Applies the same weighted calculation to each (continent, year) pair and plots one line per continent.
3. **Correlation between life expectancy and GDP per capita.** Computes the Pearson correlation between `lifeExp` and `gdpPercap` for every (continent, country) pair.
4. **Scatter plots.** Draws two grids of 2x5 scatter plots (life expectancy vs. GDP per capita), one for the 10 lowest and one for the 10 highest correlations. Each subplot shows the country, its continent and its correlation coefficient.

## Output

Four figures are displayed:

1. Line plot of the worldwide average GDP per capita by year
2. Line plot of the average GDP per capita by year, one line per continent
3. Grid of scatter plots for the 10 countries with the lowest correlation
4. Grid of scatter plots for the 10 countries with the highest correlation


