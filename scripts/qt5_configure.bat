ECHO "Configuring QT5..."

:: TODO add usage doc

cd %1
IF NOT EXIST configure.bat (
  ECHO This doesn't look like the QT5.15 source folder.
  EXIT /B 1
)

configure -static -opensource -debug-and-release -no-dbus -no-feature-qdbus -confirm-license -strip -silent -no-compile-examples -nomake tests -make libs -no-sql-psql -no-sql-sqlite -skip qt3d -skip webengine -skip qtmultimedia -skip qtserialport -skip qtsensors -skip qtgamepad -skip qtwebchannel -skip qtandroidextras -feature-imageformat_png -qt-libpng -qt-zlib -recheck-all -openssl-linked -I c:\MozillaVPNBuild\include -L c:\MozillaVPNBuild\lib -prefix c:\MozillaVPNBuild

IF %ERRORLEVEL% NEQ 0 (
  ECHO Failed to configure QT5.
  EXIT /B 1
)
