del %AppData%\Rime\*.* /Q
rmdir %AppData%\RIme\opencc /S /Q
xcopy ..\*.yaml /S %AppData%\Rime\
xcopy ..\*.lua  /S %AppData%\Rime\
xcopy ..\opencc /S %AppData%\Rime\
xcopy ..\default.custom.in %AppData%\Rime\default.custom.yaml
"C:\Program Files (x86)\Rime\weasel-0.13.0\WeaselDeployer.exe" /deploy
