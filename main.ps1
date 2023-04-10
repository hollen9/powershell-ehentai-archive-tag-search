Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = 'EroHon Gallery Search'
$mainForm.Size = New-Object System.Drawing.Size(800,600)

$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(10,10)
$searchBox.Size = New-Object System.Drawing.Size(200,20)
$mainForm.Controls.Add($searchBox)

$searchButton = New-Object System.Windows.Forms.Button
$searchButton.Location = New-Object System.Drawing.Point(220,10)
$searchButton.Size = New-Object System.Drawing.Size(75,20)
$searchButton.Text = 'Search'
$mainForm.Controls.Add($searchButton)

$resultListView = New-Object System.Windows.Forms.ListView
$resultListView.Location = New-Object System.Drawing.Point(10, 40)
$resultListView.Size = New-Object System.Drawing.Size(760, 500)
# $resultListView.View = [System.Windows.Forms.View]::Details
$resultListView.View = [System.Windows.Forms.View]::LargeIcon

$resultListView.Columns.Add('Gallery Name', 400) | Out-Null
$resultListView.Columns.Add('Cover Image', 350) | Out-Null


$resultListView.FullRowSelect = $true
$resultListView.MultiSelect = $false
$mainForm.Controls.Add($resultListView)

$imageList = New-Object System.Windows.Forms.ImageList
$imageList.ImageSize = New-Object System.Drawing.Size(200, 200)
$resultListView.LargeImageList = $imageList

$searchBox.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
        $searchButton.PerformClick()
    }
})

$searchButton.Add_Click({
    $resultListView.Items.Clear()
    $imageList.Images.Clear()

    $searchTag = $searchBox.Text
    $directories = Get-ChildItem 'X:\EroHon' -Directory

    $searchTags = $searchTag -split '(?<=\x22)\s+(?=\S)|\s+(?<=\S)\s+(?=\x22)|\s+(?<=\S)\s+(?=\S)'

    $searchTagRegexes = @()
    foreach ($tag in $searchTags) {
        $trimmedTag = $tag.Trim('"')
        $modifiedTag = ($trimmedTag -replace '^male', 'm') -replace '^female', 'f'
        if ($modifiedTag -notmatch "^[mf]:") {
            $searchTagRegexes += "(?:male|female):$modifiedTag"
        } else {
            $modifiedTag = $modifiedTag.Replace('m:', 'male:').Replace('f:', 'female:')
            $searchTagRegexes += "(^|,)($modifiedTag)(:|$)"
        }
    }


    $resultListView.BeginUpdate()
    foreach ($directory in $directories) {
        $galleryInfoPath = Join-Path $directory.FullName 'galleryinfo.txt'
    
        if (Test-Path -LiteralPath $galleryInfoPath) {
            $galleryInfo = Get-Content -LiteralPath $galleryInfoPath
    
            $tagMatch = $galleryInfo | Select-String -Pattern "Tags:\s*(.*)"
            if ($tagMatch) {
                $tagsString = $tagMatch.Matches[0].Groups[1].Value
    
                if ($tagsString) {
                    $tags = $tagsString -split ',' | ForEach-Object { $_.Trim() }
                        
                    #$matched = $false #OR
                    $matched = $true #AND
                    foreach ($tagRegex in $searchTagRegexes) {
                        # # OR Search
                        # if ($tags -match $tagRegex) {
                        #     $matched = $true
                        #     break
                        # }

                        # AND Search
                        if ($tagRegex.StartsWith('(?:male|female):')) {
                            $tempRegex = $tagRegex -replace '^\(\?\:male\|female\):', ''
                            if (-not ($tags -match "male:$tempRegex" -or $tags -match "female:$tempRegex")) {
                                $matched = $false
                                break
                            }
                        } else {
                            if (-not ($tags -match $tagRegex)) {
                                $matched = $false
                                break
                            }
                        }
                    }
                    if ($matched) {

                        $directoryInfo = New-Object System.IO.DirectoryInfo($directory.FullName)
                        
                        $coverImageFiles = $directoryInfo.GetFiles() | Where-Object { $_.Extension -in @('.jpg', '.jpeg', '.png', '.bmp') } | Sort-Object -Property Name | Select-Object -First 1

                        if ($coverImageFiles.Count -gt 0) {
                            $coverImagePath = $coverImageFiles[0].FullName
                        } else {
                            $coverImagePath = $null
                        }                        

                        if ($coverImagePath -ne $null) {
                            $imageList.Images.Add([System.Drawing.Image]::FromFile($coverImagePath), [System.Drawing.Color]::Transparent)
                            Write-Host "Added image: $coverImagePath"
                        }
                        $item = New-Object System.Windows.Forms.ListViewItem($directory.Name)
                        $item.ImageIndex = $imageList.Images.Count - 1
                        $resultListView.Items.Insert(0, $item)

                    }
                }
            }
        }
    }
    $resultListView.EndUpdate()
    Write-Host "Total images: $($imageList.Images.Count)"
})

$resultListView.Add_MouseDoubleClick({
    if ($resultListView.SelectedItems.Count -gt 0) {
        $selectedItem = $resultListView.SelectedItems[0]
        $selectedFolder = Join-Path 'X:\EroHon' $selectedItem.Text
        Start-Process 'explorer.exe' -ArgumentList $selectedFolder
    }
})


[void]$mainForm.ShowDialog()