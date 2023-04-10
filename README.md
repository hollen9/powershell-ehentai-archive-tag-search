# EroHon Gallery Search
This is a PowerShell script for searching and browsing a collection of hentai manga (aka EroHon) in a given directory. The script searches for galleries based on user-defined tags in a galleryinfo.txt file and displays the gallery names and cover images in a GUI ListView control.

## Requirements
* PowerShell v5.0 or higher
* .NET Framework 4.7 or higher
## Usage
1. Clone or download this repository.
2. Open a PowerShell terminal and navigate to the directory containing the script.
3. Run the script using the following command: .\SearchEroHon.ps1
4. Enter a tag or keyword in the search box and press Enter or click the Search button.
5. The script will search for galleries containing the entered tag/keyword and display the gallery names and cover images in the results ListView.
6. Double-click a gallery in the results ListView to open its folder in Windows Explorer.
## Notes
* This script is designed to search for galleries that follow a specific format, including a galleryinfo.txt file and a cover image named "cover.jpg" or "cover.png". If your collection does not follow this format, the script may not work properly.
* The script assumes that all image files in a gallery directory are part of the gallery and will use the first image file found as the cover image. If your collection has other types of image files in the gallery directories, you may need to modify the script to exclude them.
* The script uses a ListView control to display the search results. You can change the view mode by modifying the $resultListView.View property (e.g. $resultListView.View = [System.Windows.Forms.View]::Details for a details view).
* This script is intended for mature audiences only and should not be used or distributed for illegal purposes.
