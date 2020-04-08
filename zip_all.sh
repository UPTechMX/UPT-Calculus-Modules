#!/bin/bash
directories=()
directories_name=()
for i in `find . -maxdepth 1 -mindepth 1 -type d`
do
    directories+=($(echo ${i//.}))
done

for i in "${directories[@]}"
do
    directories_name+=($(echo ${i///}))
done

for i in "${directories_name[@]}"
do
    if [[ $i != *"__"* && $i != *"git"* ]];
    then 
        cd $i
        rm "$i.zip"
        zip "$i.zip" . -r
        cd ..
    fi    
done