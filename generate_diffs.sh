#!/bin/bash

# Get list of folders to generate diffs for
dirs=()
for d in */; do
  [ -d "$d" ] || continue
  dirs+=("${d%/}")
done

# sort directories
IFS=$'\n' sorted_dirs=($(printf '%s\n' "${dirs[@]}" | sort -V))
unset IFS

if (( ${#sorted_dirs[@]} < 2 )); then
  echo "Need at least two directories in the current directory." >&2
  exit 1
fi

total=${#sorted_dirs[@]}

for ((i=0; i<total-1; i++)); do
  old="${sorted_dirs[i]}"
  new="${sorted_dirs[i+1]}"
  out="${old}_${new}.html"
  current=$((i+1))

  #echo "Comparing: '$old' to '$new' -> $out [$current/$total]"
  echo -ne "Comparing... [$current/$total]\r"

  diffoscope --no-default-limits \
    --exclude=UnitySourceGeneratedAssemblyMonoScriptTypes_v1.cs \
    --exclude-directory-metadata yes \
    --max-diff-block-lines 0 \
    --max-page-diff-block-lines 41943040 \
    --html="$out" \
    "./$old" "./$new"
done

echo
echo Done!
