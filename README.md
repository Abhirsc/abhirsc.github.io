# Abhimanyu Raj Singh

## Update Timeline Quickly
Timeline entries are now generated from `/Users/abhirsc/Documents/resumetimeline/abhirsc.github.io/data/timeline.csv`.

1. Edit `data/timeline.csv`.
2. Update the row you want or add a new row.
3. Run `quarto render` from repo root.
4. The page rebuilds `_generated/timeline.html` automatically and the site updates from that CSV.

Use these columns in `data/timeline.csv`:
`sort_order, year, period, title, preview, detail, image, alt`

Notes:
Keep image files in `images/` and use the exact same filename case.
Higher `sort_order` values appear first in the timeline.

Idea-Blogs are easier to manage as plain text files:
Add `idea-pages/page3.txt`, `idea-pages/page4.txt`, and render.
Each new file is picked up automatically in the `Idea-Blogs` tab.

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Row 1 A  | Row 1 B  | Row 1 C  |
| Row 2 A  | Row 2 B  | Row 2 C  |
