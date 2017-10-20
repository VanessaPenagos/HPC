#!/bin/bash

#SBATCH --job-name=image
#SBATCH --output=im_image
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --gres=gpu:1

./DisplayImage ../Imagenes/Originales/camaleon.jpg

