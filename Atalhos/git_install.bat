@echo off
title Verificar / Instalar Git

where git >nul 2>nul
if %errorlevel% equ 0 (
    echo Git ja esta instalado.
    git --version
    goto :fim
)

echo Git nao encontrado. A descarregar instalador...
set URL=https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe
set INSTALADOR=%TEMP%\Git-2.45.2-64-bit.exe

curl -L -o "%INSTALADOR%" "%URL%"
if %errorlevel% neq 0 (
    echo Erro ao descarregar o Git.
    pause
    exit /b 1
)

echo A instalar Git silenciosamente...
"%INSTALADOR%" /SILENT

echo Instalacao concluida. A verificar...
where git >nul 2>nul
if %errorlevel% equ 0 (
    git --version
) else (
    echo Erro: Git nao foi encontrado apos instalacao.
    echo Pode ser necessario reiniciar o terminal.
)

:fim
pause
