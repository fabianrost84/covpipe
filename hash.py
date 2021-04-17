#!/usr/bin/python

# hoelzerm@rki.de

# snakemake creates a conda environment using a hash combined from the 
#
# 1) absolute output path where the environment is generated 
# 2) the content of the env.yaml file

# to pre-build all environments with the correct hash, this script is used 

import hashlib
import os

yaml_file = os.environ["YAML"]

md5hash = hashlib.md5()
md5hash.update("/.snakemake/conda".encode())

f = open(yaml_file, 'rb')
md5hash.update(f.read())
f.close()

h = md5hash.hexdigest()
print(h)
