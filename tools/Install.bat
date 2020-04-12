del %AppData%\Rime\*.* /Q
rmdir %AppData%\RIme\opencc /S /Q
xcopy ..\src\*.* /S %AppData%\Rime\
rename %AppData%\Rime\default.custom.in %AppData%\Rime\default.custom.yaml
"C:\Program Files (x86)\Rime\weasel-0.13.0\WeaselDeployer.exe" /deploy
