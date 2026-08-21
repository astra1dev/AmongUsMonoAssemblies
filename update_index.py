# This script is used by CI to update index.html before publishing it
# It edits in the actual assembly and diff counts, as well as the +/- line changes for each file

from pathlib import Path
import re

repo = Path('.')
index_path = repo / 'publish' / 'index.html'
text = index_path.read_text()

dll_count = sum(1 for _ in repo.glob('*.dll'))
diffs = dll_count - 1 if dll_count > 0 else 0
# Insert the actual counts and replace the placeholder '0' values
text = re.sub(r'(Current assemblies:\s*)\d+', rf'\g<1>{dll_count}', text)
text = re.sub(r'(Current diffs:\s*)\d+', rf'\g<1>{diffs}', text)

# Count the number of lines starting with '+' and '-'. Not the best approach I think, but works for now
def count_changes(md_path: Path) -> tuple[int, int]:
    plus = 0
    minus = 0
    for line in md_path.read_text().splitlines():
        if line.startswith('+'):
            plus += 1
        elif line.startswith('-'):
            minus += 1
    return plus, minus

output_lines = []
pending_md = None
for line in text.splitlines():
    # Update the table cell after each markdown link with its total line changes
    md_match = re.search(r'href="([^"]+\.md)"', line)
    if md_match:
        # This will be used in the next iteration to update the "Line changes" cell
        pending_md = md_match.group(1)
    elif pending_md and line.lstrip().startswith('<td>'):
        plus, minus = count_changes(repo / pending_md)
        # Insert the actual +/- line changes and replace the placeholder '0' values
        line = re.sub(r'<td>.*</td>', f'<td>+{plus}, -{minus}</td>', line, count=1)
        pending_md = None
    output_lines.append(line)

# Write the updated content back to the index.html file
index_path.write_text('\n'.join(output_lines) + '\n')
