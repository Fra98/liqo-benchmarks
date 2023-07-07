import argparse
import os

import numpy as np
import pandas as pd

TYPE="liqo"
RUNS = 20
NUM_PODS = [1, 5, 10, 100]

def read_time(path, file):
    with open(os.path.join(path, file), 'r') as input:
        # Loop through the lines to extract the information of interest.
        for line in input:
            if line.startswith("Start: "):
                # start = int(line.removeprefix("Start: ").split(' ')[0]) # Python >= 3.9
                start = int(line[len("Start: "):].split(' ')[0]) # Python < 3.9
            if line.startswith("End  : "):
                # end = int(line.removeprefix("End  : ").split(' ')[0]) # Python >= 3.9
                end = int(line[len("End  : "):].split(' ')[0]) # Python < 3.9
        # Return the total time
        return (end - start) / 1e9


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("input_path", help="Input folder")
    parser.add_argument("output_file", help="Output file")
    args = parser.parse_args()

    data = np.zeros((len(NUM_PODS), RUNS))
    for idx, pods in enumerate(NUM_PODS):
        for run in range(RUNS):
            file = f"offloading-{TYPE}-1-{pods}-{run+1}.txt"
            time = read_time(args.input_path, file)
            data[idx][run] = time

    # convert array into dataframe
    DF = pd.DataFrame(data)
    
    # save the dataframe as a csv file
    DF.to_csv(args.output_file, float_format="%.3f", index=False, header=False)

