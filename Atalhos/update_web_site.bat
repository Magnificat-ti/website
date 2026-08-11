@echo off
title Atualizar imagens - GitHub

:: Prompt for Git personal‑access token
:ask_token
set /p GIT_TOKEN="Enter your Git personal access token (or press ENTER to cancel): "
if "%GIT_TOKEN%"=="" (
    echo Token not provided – operation cancelled.
    pause
    exit /b 1
)

cd /d "%~dp0.."

call :update_banner

git add images/ index.html >nul 2>&1
if %errorlevel% neq 0 (
    echo Erro no git add.
    pause
    exit /b 1
)

git commit -m "Atualizar imagens" >nul 2>&1
if %errorlevel% neq 0 (
    echo Nao ha alteracoes para commitar ou ocorreu um erro.
    pause
    exit /b 1
)

git push 

echo.
echo Operacao concluida.
pause
exit /b 0

:: ============================================================================
:: update_banner
:: Escaneia images/banner_images/ e insere no index.html os slides de imagens
:: que ainda nao estao listadas no banner.
:: ============================================================================
:update_banner
setlocal enabledelayedexpansion
set "BANNER_DIR=%~dp0..\images\banner_images"
set "INDEX_FILE=%~dp0..\index.html"

set "NEW_IMAGES="
for %%E in (png jpg jpeg gif webp) do (
    for %%F in ("%BANNER_DIR%\*.%%E") do (
        findstr /i /c:"%%~nxF" "%INDEX_FILE%" >nul 2>&1
        if errorlevel 1 (
            if defined NEW_IMAGES (
                set "NEW_IMAGES=!NEW_IMAGES!,%%~nxF"
            ) else (
                set "NEW_IMAGES=%%~nxF"
            )
        )
    )
)

if not defined NEW_IMAGES (
    echo Nenhuma nova imagem para o banner.
    endlocal
    goto :eof
)

set "PS_SCRIPT=%TEMP%\update_banner.ps1"
del "%PS_SCRIPT%" 2>nul
>> "%PS_SCRIPT%" echo $images = '%NEW_IMAGES%'.Split(',')
>> "%PS_SCRIPT%" echo $sb = New-Object System.Text.StringBuilder
>> "%PS_SCRIPT%" echo foreach ^($img in $images^) {
>> "%PS_SCRIPT%" echo     [void]$sb.AppendLine^('                ^<div class="swiper-slide"^>^<img class="carousel_img" src="./images/banner_images/' + $img + '" alt="' + $img + '"^>^</div^>'^)
>> "%PS_SCRIPT%" echo }
>> "%PS_SCRIPT%" echo $content = [System.IO.File]::ReadAllText^('%INDEX_FILE%'^)
>> "%PS_SCRIPT%" echo $marker = '^<div class="swiper-pagination"^>'
>> "%PS_SCRIPT%" echo $content = $content.Replace^($marker, $sb.ToString^(^) + '             ' + $marker^)
>> "%PS_SCRIPT%" echo [System.IO.File]::WriteAllText^('%INDEX_FILE%', $content^)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
del "%PS_SCRIPT%" 2>nul

endlocal
goto :eof
