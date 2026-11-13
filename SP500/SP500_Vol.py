import pandas as pd
from matplotlib import pyplot as plt
from pathlib import Path

dataset = Path(__file__).parent / "SP500_dataset.csv" # import the file
df = pd.read_csv(dataset)

df["Date"] = df["Date"].astype(str) # used to correctly convert the date in order for pandas to read it.
df["Date"] = pd.to_datetime(df["Date"]) # we convert the column in a datetype format.


target_df = df[(df["Date"].dt.weekday == 4) & (df["Date"].dt.month == 9)] # creates a dataframe only with the information we need.

x_axis_list = [] # created a list to save all the column names like "0.8, 0.9".
for col in target_df.columns:
    if target_df[col].dtype in ['float64', 'int64']: # we filter the non-float/int values to appear in the list.
        x_axis_list.append(float(col))
    else:
        continue
# the list will be used to manually insert ticks in the x-axis.

x_labels = [str(x) for x in x_axis_list] # code used to have equal spacing among ticks in the x-axis.
x_pos = list(range(len(x_axis_list))) # x_pos will be a list of integers, being the position of each tick in the x-axis.


# splits the dataframe in 2 parts based on the date.
target_df_2018 = target_df[target_df["Date"] == "2018-09-28"]
target_df_2017 = target_df[target_df["Date"] == "2017-09-29"].reset_index(drop = True)


def plot(ax, input_data, date): # function used to plot a specific row.
    numeric_input = pd.to_numeric(input_data, errors="coerce").dropna().astype(float) # used to create a pandas series out of the input.
    y_values = numeric_input.values

    ax.plot(x_pos, y_values, marker='.', linestyle='None', color='red', markersize=4)
    ax.set_xticks(x_pos) # we manually set the ticks.
    ax.set_xticklabels(x_labels, fontsize=9)

    ax.set_title(f"Date {date}", fontsize=10)
    ax.set_xlabel("Strike", fontsize=8)
    ax.set_ylabel("Imp Vol", fontsize=8)
    ax.tick_params(axis='both', labelsize=7)
    ax.set_facecolor("white")




def image_plots(dataframe): # function that, given the dataframe, will create a number of plots as a 2x4 format.
    fig, ax = plt.subplots(2, 4, figsize = (16, 8), facecolor = "lemonchiffon")

    date_value = dataframe["Date"].iloc[0] # used to automatically set the title of the picture.
    formatted_date = date_value.strftime("%A %d of %B, %Y")
    fig.suptitle(formatted_date)

    fig.delaxes(ax.flat[7]) # del. the last empty graph.
    fig.subplots_adjust(left=0.05, right=0.98, top=0.92,bottom = 0.1, hspace=0.25, wspace=0.25)
    # sort the values by T so we have the correct ordering.
    dataframe = dataframe.sort_values(by = "T").reset_index(drop = True)
    n = 0
    for x in range(7): # for loop used to put all the graphs in the picture.
        if x < 4:
            plot(ax[0, n], dataframe.loc[x], dataframe["T"].loc[x])
            n += 1
        elif x == 4:
            n = 0
            plot(ax[1, n], dataframe.loc[x], dataframe["T"].loc[x])
            n += 1
        else:
            plot(ax[1, n], dataframe.loc[x], dataframe["T"].loc[x])
            n += 1
    plt.show()

image_plots(target_df_2018)
image_plots(target_df_2017)
