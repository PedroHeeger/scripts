$version = "117.0.5938.92"
$file = "chromedriver-win64"
# $chromeDriverUrl = "https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_win32.zip"
$chromeDriverUrl = "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$version/win64/$file.zip"

$downloadPath = "C:\Users\pedro\Downloads\$file"
Invoke-WebRequest -Uri $chromeDriverUrl -OutFile $downloadPath
Expand-Archive -Path $downloadPath -DestinationPath "C:\Users\pedro\Downloads\chromedriver\$file"
Move-Item -Path "C:\Users\pedro\Downloads\chromedriver\$file\*" -Destination "C:\zProgramsTI\chromedriver\$file"
Remove-Item -Path "C:\Users\pedro\Downloads\$file.zip" -Recurse
Remove-Item -Path "C:\Users\pedro\Downloads\chromedriver\$file.zip" -Recurse