unzip quickfix-1.15.1.zip
mv quickfix-1.15.1 quickfix
cd quickfix

autoconf

chmod +x ./bootstrap

./bootstrap

./configure --with-python3 --with-openssl --with-mysql --with-postgresql && make && make check

cd ../

mkdir ./C++
mkdir ./spec

cp quickfix/src/python3/*.py ./
cp quickfix/src/C++/*.h ./C++
cp quickfix/src/C++/*.hpp ./C++
cp quickfix/src/C++/*.cpp ./C++
cp -R quickfix/src/C++/double-conversion ./C++
cp quickfix/src/python3/QuickfixPython.cpp ./C++
cp quickfix/src/python3/QuickfixPython.h ./C++

cp quickfix/LICENSE ./

cp quickfix/spec/FIX*.xml ./spec

touch config.h
touch config_windows.h

touch ./C++/config.h
touch ./C++/config_windows.h

python setup.py bdist_wheel
