import pandas as pd
from matplotlib import pyplot as plt


dataset = "GDP_Research_Data.csv" # import the file
df = pd.read_csv(dataset)



# we create a new column to compute the total GDP (pop * per capita GDP)
df["gdp"] = (df["pop"] * df["gdpPercap"])

# using group by, we group all data by year, to compute worldwide weighted gdp and population.
Grouped1 = df.groupby("year").agg(
    total_gdp=("gdp", "sum"),
    total_pop=("pop", "sum")
)

# compute the average per capita GDP
Grouped1["avg_percap_gdp"] = Grouped1["total_gdp"] / Grouped1["total_pop"]


# plot the results
plt.figure(figsize=(10, 6))
plt.plot(Grouped1.index, Grouped1["avg_percap_gdp"], marker='o')
plt.title("Worldwide average per capita GDP over the years")
plt.xlabel("Year")
plt.ylabel("Average percap GDP")
plt.show()



# we now use again group by to firstly group by each continent, and then by the year,
grouped2 = df.groupby(["continent", "year"]).agg(
    total_gdp=("gdp", "sum"),
    total_pop=("pop", "sum")
).reset_index()

# we add a new column "avg_percap_GDP" that computes the per capita GDP for each continent and for each year
grouped2["avg_percap_gdp"] = grouped2["total_gdp"] / grouped2["total_pop"]



plt.figure(figsize=(12, 7))

for continent in grouped2["continent"].unique(): # this loop will create a line for each continent.
    continent_df = grouped2[grouped2["continent"] == continent] # continent_df is a temporary dataframe used to plot data for each continent.
    plt.plot(continent_df["year"], continent_df["avg_percap_gdp"], marker='o', label=continent)

plt.title("Average per capita GDP, for each Continent over the years")
plt.xlabel("Year")
plt.ylabel("Average per capita GDP")
plt.legend(title="Continent")
plt.show()



def correlation(dataframe, var1, var2):
    """
    var1 and var2 are the 2 variables used for correlation values;
    we grouped up the dataframe for each continent and country, we applied a function to each group using .apply
    for each group we compute the correlation coefficient between var1 and var2, for each continent/country pair.
    """


    corr_df = (
        dataframe.groupby(["continent", "country"],group_keys = False).apply(
            lambda group: group[var1].corr(group[var2]), include_groups = False                                                                 )
          .reset_index(name="correlation")
    )
    # group_keys and include_groups are used to prevent a warning that in future versions, .apply will no
    # longer include grouping columns inside each group automatically.
    return corr_df

corr_results = correlation(df,"lifeExp", "gdpPercap")


# 2 dataframes with the lowest and highest correlation values
lowest_corr = corr_results.nsmallest(10, "correlation")
highest_corr = corr_results.nlargest(10, "correlation")


# this function will be used to scatter values of life expectancy and per capita GDP for 20 countries.
# plots will be rearranged in 2 different images, with the 10 lowest and 10 highest correlating country/continent pairs.
def scatterplot_grid(target_dataframe, total_data, title):

    fig, axes = plt.subplots(2, 5, figsize=(16, 6))
    fig.patch.set_facecolor("lemonchiffon")
    axes = axes.flatten()

    n = len(target_dataframe)
    for i in range(n):
        row = target_dataframe.iloc[i]
        country_name = row["country"]
        continent_name = row["continent"]

        country_data = total_data[total_data["country"] == country_name]
        corr = country_data["lifeExp"].corr(country_data["gdpPercap"])

        ax = axes[i]
        ax.scatter(country_data["gdpPercap"], country_data["lifeExp"], alpha=0.8, marker="o", s = 15, color = "red")
        ax.set_title(f"{country_name}, {continent_name}", fontsize=8)
        ax.set_xlabel("GDP per Capita", fontsize = 8)
        ax.set_ylabel("Life Expectancy", fontsize = 8)
        ax.legend([f"Corr: {corr:.2f}"], loc="upper left", fontsize=7)
        ax.tick_params(axis='both', labelsize=8)


    plt.suptitle(title, fontsize=14)
    plt.tight_layout(rect=[0.0, 0.0, 1.0, 0.95])
    plt.show()

scatterplot_grid(lowest_corr, df, title="10 Countries with Lowest Correlation")
scatterplot_grid(highest_corr, df, title="10 Countries with Highest Correlation")
