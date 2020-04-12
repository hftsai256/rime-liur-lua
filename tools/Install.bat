del %AppData%\Rime\*.* /Q
rmdir %AppData%\RIme\opencc /S /Q
xcopy ..\src\*.yaml /S %AppData%\Rime\
xcopy ..\src\*.lua  /S %AppData%\Rime\
xcopy ..\src\opencc /S %AppData%\Rime\
xcopy ..\src\default.custom.in %AppData%\Rime\default.custom.yaml
"C:\Program Files (x86)\Rime\weasel-0.13.0\WeaselDeployer.exe" /deploy
