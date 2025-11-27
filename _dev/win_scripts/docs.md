## separate-4K.bat
organizes folders based on their naming convention.

Target: scans immediate subdirectories for those containing "4K" in their name.

Action: moves these identified folders into a new directory named "4K-downscale".


Safety: explicitly skips the destination folder itself to avoid recursion issues.


## cleanup-files.bat
performs a recursive cleanup of specific file types and names.

Target: searches recursively (/R) for files containing keywords like "NormalDX", "Displacement", "Disp", "Height", "PREVIEW", or files with .usda/.usdc extensions.

Action: deletes these files and logs the path of every deleted file to deleted_files_log.txt.

Logging: captures the start time in the log file.


## down-scaling.bat
uses ImageMagick to resize textures and renames them to reflect the change.

Requirement: relies on the magick command (ImageMagick).

Renaming Logic: replaces "4K" with "4d1K" and "2K" with "2d1K" in both folder names and filenames.

Action: resizes supported image formats (jpg, png, tif, exr, etc.) to 25% of their original size.

Output: The processed files are saved into a "DOWNSCALED" directory, preserving the folder structure with the new names.

Logging: Extensive debug information and success/failure states are written to downscale_log.txt.


## flatten.bat
simplifies directory structures by removing unnecessary nesting.

Logic: identifies directories that contain exactly zero files and exactly one subfolder.

Action: If a directory meets these criteria, the script moves the contents of the subfolder up one level and deletes the empty subfolder.

Constraints: skips directories that do not meet the strict "0 files, 1 subfolder" rule.