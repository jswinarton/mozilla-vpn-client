:: Borrowed and modified from https://doc.qt.io/qt-5/windows-building.html
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64

SET _QT_SOURCE_ROOT=C:\mvpnbuilddep\qt5
SET _MVPN_BUILD_ROOT=C:\MozillaVPNBuild
SET PATH=%_MVPN_BUILD_ROOT%\bin;%_QT_SOURCE_ROOT%\qtbase\bin;%_QT_SOURCE_ROOT%\gnuwin32\bin;%PATH%

ECHO %VCToolsRedistDir%
