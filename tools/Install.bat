del %AppData%\Rime\*.* /Q
rmdir %AppData%\RIme\opencc /S /Q
xcopy ..\*.yaml /S %AppData%\Rime\
xcopy ..\*.lua  /S %AppData%\Rime\
xcopy ..\opencc /S %AppData%\Rime\
"C:\Program Files (x86)\Rime\weasel-0.13.0\WeaselDeployer.exe" /deploy
