import csv
import os

DAY_INDEX = 9
DAYS = [
    ("Monday", "2023-02-27", "01_Maandag"),
    ("Tudesday", "2023-02-28", "02_Dinsdag"),
    ("Wednesday", "2023-03-01", "03_Woensdag"),
    ("Thursday", "2023-03-02", "05_Donderdag"),
    ("Friday", "2023-03-03", "06_Vrijdag"),
    ("Saturday", "2023-03-04", "08_Zaterdag"),
    ("Sunday", "2023-03-05", "09_Zondag"),
    ("Monday", "2023-03-06", "11_Maandag2"),
    ("All", "all", "all"),
    ("All2", "Tue-Thu", "Tue-Thu")
]
DAY = DAYS[DAY_INDEX]
CSV_PROCESSED_DATA = os.path.join("processed_data", "data_" + DAY[2] + ".csv")
CSV_BINNED_DATA = os.path.join("plotting_data", "data_" + DAY[1] + "_binned.csv")
BIN_LENGTH_SECONDS = 180

def main():
    """Entry point of program.
    """
    # Use a set which does not allow duplicates.
    unique_macs = set()
    # Bin format: (begin, end, #unique macs)
    bins = []
    start_time = 0
    end_time = 0

    # Read CSV data.
    with open(CSV_PROCESSED_DATA, 'r', newline='') as file:
        csvreader = csv.reader(file)

        for i, row in enumerate(csvreader):
            # Skip top row.
            if i == 0:
                continue
            # If no start time set, set it now and append to a bin.
            if start_time == 0:
                start_time = float(row[1])
                end_time = start_time + BIN_LENGTH_SECONDS
                bins.append([start_time, end_time, 0])
            # If bin end time is reached, add unique MACs to it and start new bin.
            elif float(row[1]) > end_time:
                bins[-1][2] = len(unique_macs)
                unique_macs.clear()
                start_time = float(row[1])

                # Insert empty bins where necessary.
                while end_time < start_time:
                    new_end_time = min(end_time + BIN_LENGTH_SECONDS, start_time)
                    bins.append([end_time, new_end_time, 0])
                    end_time = new_end_time

                end_time = start_time + BIN_LENGTH_SECONDS
                bins.append([start_time, end_time, 0])
            # Add unique MAC to set.
            unique_macs.add(row[0])

    # Write binned data to CSV to plot later.
    with open(CSV_BINNED_DATA, 'w', newline='') as file:
        csvwriter = csv.writer(file)
        csvwriter.writerow(["Bin start", "Bin end", "Number of unique MAC addresses"])

        for bin in bins:
            csvwriter.writerow([bin[0], bin[1], bin[2]])


if __name__ == "__main__":
    main()