@SetLocal EnableExtensions EnableDelayedExpansion

@echo off

if "%~1"=="" (
	echo Use %0 ^<address^>
	echo Address must be without http://, https:// or www
	echo e.g. riseup.net
	pause
	exit /B
)

set PROV=%1
set ADDR=https://%1
set WORKDIR=data\%PROV%

echo Get keys from %PROV% (%ADDR%)
echo Making work directories...
mkdir %WORKDIR%
echo.

echo Get provider.json...
bin\wget -O %WORKDIR%/provider.json --no-check-certificate %ADDR%/provider.json

if not exist %WORKDIR%\provider.json (
	echo ERROR: File %WORKDIR%\provider.json not downloaded.
	pause
	exit /B
) else (
	echo.
	echo OK. %WORKDIR%\provider.json downloaded.
)
echo.

echo Get provider main data...
for /f %%i in ('bin\jq .api_uri %WORKDIR%/provider.json') do set "API_URI=%%i"& goto f1
:f1
for /f %%i in ('bin\jq .api_version %WORKDIR%/provider.json') do set "API_VER=%%i"& goto f2
:f2
for /f %%i in ('bin\jq .ca_cert_uri %WORKDIR%/provider.json') do set "CACERT_URI=%%i"& goto f3
:f3

set API_URI=%API_URI:"=%
set API_VER=%API_VER:"=%
set CACERT_URI=%CACERT_URI:"=%

set API_BASE=%API_URI%/%API_VER%

echo ===============
echo API URI: %API_URI%
echo API Version: %API_VER%
echo API Base: %API_BASE%
echo Certificate URI: %CACERT_URI%
echo ===============
echo.

echo Get provider certificate...
bin\wget -O %WORKDIR%/cacert.pem --no-check-certificate %CACERT_URI%
echo.

echo Get user certificate...
bin\wget -O %WORKDIR%/openvpn.pem --no-check-certificate %API_BASE%/cert

pause