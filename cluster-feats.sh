#!/bin/bash

# 1.) this obtains the MFCC features and prepares a random subsample for clustering. Comment this out for all clustering runs but the first one!

clustering/prepare-feats.sh

# 2.) perform clustering with k clusters

python clustering/do_k_means.py clustering/feats/king_1mil_shuffled_feats.txt $1

# 3.) prepare the cluster centroids by removing random newlines and parentheses and inserting commas

paste -d, -s clustering/centroids/$1_cluster_centroids.txt | sed "s/\[/\n/g" | sed "s/\]\][0-9].*//g" | sed "s/\]//g" | sed "/^$/d" | sed "s/,//g" | sed "s/  */ /g" | sed "s/ $//g" | sed "s/^ //g" | sed "s/ /,/g" > clustering/centroids/$1_cluster_centroids_clean.txt

mv clustering/centroids/$1_cluster_centroids_clean.txt clustering/centroids/$1_cluster_centroids.txt

# 4.) do vector quantization to obtain the sequence of cluster IDs for a sequence of observations

python clustering/get_vq_index.py $1 $2 clustering/centroids/$1_cluster_centroids.txt words/$3

# 5.) obtain the lexicon

cat clustering/words/$3_$1_cluster_ids.txt | sed "s/\[//g" | sed "s/\]//g" | sed "s/  */\n/g" | sed "/^$/d" | uniq | paste -d, -s | sed "s/,/ /g" | sed "s/^/$3\t/g" >> clustering/lexica/lexicon_$1.txt

