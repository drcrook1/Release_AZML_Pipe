import argparse
import os
import json
import numpy as np
import logging

parser = argparse.ArgumentParser()
parser.add_argument("num_buckets", type=int)
parser.add_argument("input_mount_path", type=str)
parser.add_argument("output_mount_path", type=str)
args = parser.parse_args()

log_vars_str = "num_buckets: {} - input_mount_path: {} - output_mount_path: {}".format(
                args.num_buckets, args.input_mount_path, args.output_mount_path)

logging.info(log_vars_str)

file_name = "test.json"
out_file_name = "processed.npz"
data = None
with open(os.path.join(args.input_mount_path, file_name)) as json_file:
    data = json.load(json_file)

data["data"] = np.array(data["data"] * args.num_buckets).reshape(-1, 3)
np.save(os.path.join(args.output_mount_path, out_file_name), data["data"])
