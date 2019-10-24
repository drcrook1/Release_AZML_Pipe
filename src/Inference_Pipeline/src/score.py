import argparse
import os
import json
import numpy as np
import logging

parser = argparse.ArgumentParser()

parser.add_argument("--input_mount_path", type=str)
parser.add_argument("--output_mount_path", type=str)
args = parser.parse_args()

THRESHOLD = 10

data = np.load(os.path.join(args.input_mount_path, "processed.npy"))

def classify(x : int):
    if x > 10:
        return True
    return False

predictions = {}
predictions["predictions"] = [classify(x) for x in data.reshape(-1)]

os.makedirs(args.output_mount_path) #need to create output path first
with open(os.path.join(args.output_mount_path, "predictions.json"), "w") as outfile:
    json.dump(predictions, outfile)

logging.info("completed predictions.")