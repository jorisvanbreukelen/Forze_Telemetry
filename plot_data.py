import matplotlib.pyplot as plt
import matplotlib.dates as md
import numpy as np
import os
import csv
from datetime import datetime

# Which day to plot.
DAY_INDEX = 8
# Moving average window size.
MOVING_AVERAGE_WINDOW = 20
DAYS = [
    ("Monday", "2023-02-27", "Monday 02-27"),
    ("Tuesday", "2023-02-28", "Tuesday 02-28 and Wednesday 03-01"),
    ("Wednesday", "2023-03-01", "Wednesday 03-01 and Thursday 03-02"),
    ("Thursday", "2023-03-02", "Thursday 03-02"),
    ("Friday", "2023-03-03", "Friday 03-03 and Saturday 03-04"),
    ("Saturday", "2023-03-04", "Saturday 03-04"),
    ("Sunday", "2023-03-05", "Sunday 03-05"),
    ("Monday", "2023-03-06", "Monday 03-06"),
    ("All", "all", "Monday 02-27 until Monday 03-06"),
    ("All2", "Tue-Thu", "Tuesday 02-28 until Thursday 03-02")
]
LECTURE_TIMES = [
    "08:45",
    "10:45",
    "12:30",
    "13:45",
    "15:45",
    "17:30"
]
DAY = DAYS[DAY_INDEX]
DATA_FILE_NAME = os.path.join("plotting_data", "data_" + DAY[1] + "_binned.csv")

def get_bus_data():
    # TODO
    pass

def get_lecture_data():
    lecture_data = []

    # No lectures on weekends :)
    if DAY[0] == "Saturday" or DAY[0] == "Sunday":
        return []

    # Get all lecture datetimes.
    for (_, date, _) in DAYS:
        for t in LECTURE_TIMES:
            lecture_data.append(date + " " + t)

    return np.array(lecture_data)

def plot(bins):
    # Extract x and y values from bins.
    bin_xs = np.array([datetime.fromtimestamp(bin[0]) for bin in bins])
    bin_ys = np.array([bin[2] for bin in bins])

    # Calculate moving average.
    average_y = np.convolve(bin_ys, np.ones((MOVING_AVERAGE_WINDOW,))/MOVING_AVERAGE_WINDOW, mode='valid')

    # Create plot.
    plt.figure(figsize=(8, 5))
    plt.xticks(rotation=-60, ha="left")
    plt.title(DAY[2])

    # Set plot axis limits.
    plt.ylim([0, bin_ys.max() + 1])
    plt.xlim([bin_xs[0], bin_xs[-1]])

    # Format x-axis labels.
    ax=plt.gca()
    xfmt = md.DateFormatter('%H:%M | %m-%d')
    ax.xaxis.set_major_formatter(xfmt)

    # Plot bus times.
    # TODO
    # plt.axvline(x = datetime.fromisoformat("2023-02-28 06:39:00"), color = 'r', linestyle="--")

    # Plot raw data.
    plt.hist(md.date2num(bin_xs), md.date2num(bin_xs), weights=bin_ys, label="Number of unique MAC addresses", alpha=0.5)

    # Plot moving average.
    plt.plot(md.date2num(bin_xs[MOVING_AVERAGE_WINDOW // 2:-MOVING_AVERAGE_WINDOW // 2 + 1]), average_y, label="Number of unique MAC addresses (moving average)")

    # Plot lecture times.
    lecture_data = get_lecture_data()
    for date in lecture_data:
        try:
            plt.axvline(x = datetime.fromisoformat(date), color='r', linestyle='--')
        except:
            continue

    # Print potentially interesting facts.
    print("Minimum number of unique addresses: " + str(bin_ys.min()) + " at " + str(bin_xs[bin_ys.argmin()]))
    print("Maximum number of unique addresses: " + str(bin_ys.max()) + " at " + str(bin_xs[bin_ys.argmax()]))

    # Process plot and save it.
    plt.plot()
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join("plots", "plot_" + DAY[1] + ".pdf"))
    plt.show()

def main():
    bins = []

    # Read bins from binned data.
    with open(DATA_FILE_NAME, 'r', newline='') as file:
        csvreader = csv.reader(file)

        for i, row in enumerate(csvreader):
            if i > 0:
                bins.append([float(row[0]), float(row[1]), int(row[2])])

    plot(bins)

if __name__ == "__main__":
    main()
