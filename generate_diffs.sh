#!/bin/bash

echo "Note: Please run decompile_all before running this script!"

# Get list of folders to generate diffs for
dirs=()
for d in */; do
  [ -d "$d" ] || continue
  dirs+=("${d%/}")
done

if (( ${#dirs[@]} < 2 )); then
  echo "Need at least two directories in the current directory." >&2
  exit 1
fi

all_dirs=("2020.12.9s" "airship" "2021.5.4m" "2021.6.15i" "2021.6.30e"
          "2021.11.09" "2021.12.15i" "2022.3.29i" "2022.6.21s" "2022.8.23"
          "2022.9.20i" "2022.10.25s" "2022.12.8" "2023.2.28" "2023.3.28"
          "2023.6.13" "2023.7.11" "2023.10.24" "2023.11.28" "2024.3.5"
          "2024.6.4" "2024.6.18" "2024.8.13" "2024.9.4" "2024.10.29"
          "2024.11.26" "2025.3.25" "2025.3.31" "2025.5.20" "2025.6.10"
          "2025.9.9" "2025.10.14" "2025.11.18" "2026.2.17" "2026.2.24"
          "2026-3-17" "2026.3.31" "2026.6.5")

total=${#all_dirs[@]}

for dir in "${all_dirs[@]}"; do
  [ -d "$dir" ] || echo "Missing folder: $dir."
done

for ((i=0; i<total-1; i++)); do
  old="${all_dirs[i]}"
  new="${all_dirs[i+1]}"
  current=$((i+1))

  #echo "Comparing: '$old' to '$new' -> $out [$current/$total]"
  echo -ne "Comparing... [$current/$total]\r"

  diffoscope --no-default-limits \
    --exclude=UnitySourceGeneratedAssemblyMonoScriptTypes_v1.cs \
    --exclude-directory-metadata yes \
    --max-diff-block-lines 0 \
    --max-page-diff-block-lines 41943040 \
    --html="${old}_${new}.html" \
    --markdown="${old}_${new}.md" \
    "./$old" "./$new"
done

echo
echo Done!
