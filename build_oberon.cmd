@echo off
cls
chcp 866
Compiler.exe .\Source\Compiler\Compiler.ob07 con 4
echo ===================================
chcp 1251
Compiler.exe .\Source\Compiler\Compiler.ob07 con 4
chcp 866