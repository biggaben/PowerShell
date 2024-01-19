# BEGIN: Test Cases

# Test Case 1: Test SniffSearch with depth parameter
$expectedDirectories1 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 2 | Where-Object { $_.Name -like "Test*" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories1 = SniffSearch -firstParam 2 -secondParam "Test*"
Assert-Equals $expectedDirectories1 $actualDirectories1

# Test Case 2: Test SniffSearch with search string parameter
$expectedDirectories2 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 0 | Where-Object { $_.Name -like "*Test" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories2 = SniffSearch -firstParam "*Test"
Assert-Equals $expectedDirectories2 $actualDirectories2

# Test Case 3: Test SniffSearch with depth and search string parameters
$expectedDirectories3 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 3 | Where-Object { $_.Name -like "Test*" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories3 = SniffSearch -firstParam 3 -secondParam "Test*"
Assert-Equals $expectedDirectories3 $actualDirectories3

# Test Case 4: Test SniffSearch with noFolders switch
$expectedFiles4 = Get-ChildItem -Path $currentLocation -File -Recurse -Depth 0 | Where-Object { $_.Name -like "*Test" } | Sort-Object -Property Name | Format-Table Name
$actualFiles4 = SniffSearch -noFolders
Assert-Equals $expectedFiles4 $actualFiles4

# Test Case 5: Test SniffSearch with noFiles switch
$expectedDirectories5 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 0 | Where-Object { $_.Name -like "*Test" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories5 = SniffSearch -noFiles
Assert-Equals $expectedDirectories5 $actualDirectories5

# Test Case 6: Test SniffSearch with noFolders and noFiles switches
$expectedOutput6 = "No folders`nNo files"
$actualOutput6 = SniffSearch -noFolders -noFiles
Assert-Equals $expectedOutput6 $actualOutput6

# Test Case 7: Test SniffSearch with optReservedParam switch
$expectedOutput7 = "No folders`nNo files"
$actualOutput7 = SniffSearch -optReservedParam
Assert-Equals $expectedOutput7 $actualOutput7

# Test Case 8: Test SniffSearch with both depth and search string parameters and noFolders switch
$expectedFiles8 = Get-ChildItem -Path $currentLocation -File -Recurse -Depth 2 | Where-Object { $_.Name -like "Test*" } | Sort-Object -Property Name | Format-Table Name
$actualFiles8 = SniffSearch -firstParam 2 -secondParam "Test*" -noFolders
Assert-Equals $expectedFiles8 $actualFiles8

# Test Case 9: Test SniffSearch with both depth and search string parameters and noFiles switch
$expectedDirectories9 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 3 | Where-Object { $_.Name -like "Test*" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories9 = SniffSearch -firstParam 3 -secondParam "Test*" -noFiles
Assert-Equals $expectedDirectories9 $actualDirectories9

# Test Case 10: Test SniffSearch with both depth and search string parameters and noFolders and noFiles switches
$expectedOutput10 = "No folders`nNo files"
$actualOutput10 = SniffSearch -firstParam 3 -secondParam "Test*" -noFolders -noFiles
Assert-Equals $expectedOutput10 $actualOutput10

# END: Test Cases# BEGIN: Test Cases

# Test Case 1: Test SniffSearch with depth parameter
$expectedDirectories1 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 2 | Where-Object { $_.Name -like "Test*" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories1 = SniffSearch -searchString "Test*" -depth 2
Assert-Equals $expectedDirectories1 $actualDirectories1

# Test Case 2: Test SniffSearch with search string parameter
$expectedDirectories2 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 0 | Where-Object { $_.Name -like "*Test" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories2 = SniffSearch -searchString "*Test"
Assert-Equals $expectedDirectories2 $actualDirectories2

# Test Case 3: Test SniffSearch with depth and search string parameters
$expectedDirectories3 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 3 | Where-Object { $_.Name -like "Test*" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories3 = SniffSearch -searchString "Test*" -depth 3
Assert-Equals $expectedDirectories3 $actualDirectories3

# Test Case 4: Test SniffSearch with noFolders switch
$expectedFiles4 = Get-ChildItem -Path $currentLocation -File -Recurse -Depth 0 | Where-Object { $_.Name -like "*Test" } | Sort-Object -Property Name | Format-Table Name
$actualFiles4 = SniffSearch -noFolders
Assert-Equals $expectedFiles4 $actualFiles4

# Test Case 5: Test SniffSearch with noFiles switch
$expectedDirectories5 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 0 | Where-Object { $_.Name -like "*Test" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories5 = SniffSearch -noFiles
Assert-Equals $expectedDirectories5 $actualDirectories5

# Test Case 6: Test SniffSearch with noFolders and noFiles switches
$expectedOutput6 = "No folders`nNo files"
$actualOutput6 = SniffSearch -noFolders -noFiles
Assert-Equals $expectedOutput6 $actualOutput6

# Test Case 7: Test SniffSearch with optReservedParam switch
$expectedOutput7 = "No folders`nNo files"
$actualOutput7 = SniffSearch -optReservedParam
Assert-Equals $expectedOutput7 $actualOutput7

# Test Case 8: Test SniffSearch with both depth and search string parameters and noFolders switch
$expectedFiles8 = Get-ChildItem -Path $currentLocation -File -Recurse -Depth 2 | Where-Object { $_.Name -like "Test*" } | Sort-Object -Property Name | Format-Table Name
$actualFiles8 = SniffSearch -searchString "Test*" -depth 2 -noFolders
Assert-Equals $expectedFiles8 $actualFiles8

# Test Case 9: Test SniffSearch with both depth and search string parameters and noFiles switch
$expectedDirectories9 = Get-ChildItem -Path $currentLocation -Directory -Recurse -Depth 3 | Where-Object { $_.Name -like "Test*" } | Sort-Object -Property Name | Format-Table Name
$actualDirectories9 = SniffSearch -searchString "Test*" -depth 3 -noFiles
Assert-Equals $expectedDirectories9 $actualDirectories9

# Test Case 10: Test SniffSearch with both depth and search string parameters and noFolders and noFiles switches
$expectedOutput10 = "No folders`nNo files"
$actualOutput10 = SniffSearch -searchString "Test*" -depth 3 -noFolders -noFiles
Assert-Equals $expectedOutput10 $actualOutput10

# END: Test Cases