#!/bin/bash

num_assemblies=0
i=1

# Get list of files to decompile
assemblies="$(ls | grep "Assembly-CSharp-")"

for a in $assemblies; do ((num_assemblies++)) done

echo "Found ${num_assemblies} files to decompile."

# Go through all files
for assembly in $assemblies; do
    folder_name="${assembly%.dll}"
    folder_name="${folder_name#Assembly-CSharp-}"

    echo -ne "Decompiling... [${i}/${num_assemblies}]\r"

    ilspycmd --decompiler-setting SortCustomAttributes=true --nested-directories -p -o $folder_name $assembly

    ((i++))
done

echo
echo "Done!"
