
import glob
import sys
import sysconfig
import os
from distutils.command.build_ext import build_ext
from setuptools import setup, Extension
from datetime import datetime, timezone

class build_ext_subclass(build_ext):
    def build_extensions(self):
        self.compiler.define_macro("PYTHON_MAJOR_VERSION", sys.version_info[0])
        build_ext.build_extensions(self)

# Function to find MySQLStubs.h on the C drive
def find_file_on_c_drive(filename):
    for root, dirs, files in os.walk('C:\\'):
        if filename in files:
            return os.path.join(root, filename)
    return None

# Remove the "-Wstrict-prototypes" compiler option, which isn't valid for C++.
cfg_vars = sysconfig.get_config_vars()
for key, value in cfg_vars.items():
    if isinstance(value, str):
        cfg_vars[key] = value.replace("-Wstrict-prototypes", "")

# Get the current UTC date
utc_now = datetime.now(timezone.utc).strftime('%Y%m%d')

long_description = ''
with open('LICENSE') as file:
    license_ = file.read()

# Find the directory containing MySQLStubs.h
mysql_stubs_path = find_file_on_c_drive('MySQLStubs.h')
if mysql_stubs_path:
    mysql_include_dir = os.path.dirname(mysql_stubs_path)
else:
    raise FileNotFoundError('MySQLStubs.h not found on C drive')

setup(
    name='quickfix-binary',
    version='1.15.1+main',
    py_modules=[
        'quickfix', 'quickfixt11', 'quickfix40', 'quickfix41', 'quickfix42',
        'quickfix43', 'quickfix44', 'quickfix50', 'quickfix50sp1', 'quickfix50sp2'
    ],
    data_files=[('share/quickfix', glob.glob('spec/FIX*.xml'))],
    author='Oren Miller',
    author_email='oren@quickfixengine.org',
    maintainer='wxcuop',
    description="FIX (Financial Information eXchange) protocol implementation",
    url='http://www.quickfixengine.org',
    download_url='http://www.quickfixengine.org',
    include_dirs=[
        'C++', 
        'C:/Program Files/OpenSSL/include',  # OpenSSL include directory
        mysql_include_dir,  # MySQL include directory
        'C:/Program Files/PostgreSQL/16/include'  # PostgreSQL include directory
    ],
    license=license_,
    cmdclass={'build_ext': build_ext_subclass},
    ext_modules=[Extension(
        '_quickfix', glob.glob('C++/*.cpp'),
        include_dirs=[
            'C++', 
            'C:/Program Files/OpenSSL/include',  # OpenSSL include directory
            mysql_include_dir,  # MySQL include directory
            'C:/Program Files/PostgreSQL/16/include'  # PostgreSQL include directory
        ],
        library_dirs=[
            'C:/Program Files/OpenSSL/lib',  # OpenSSL library directory
            'C:/tools/mysql/lib',  # MySQL library directory
            'C:/Program Files/PostgreSQL/16/lib'  # PostgreSQL library directory
        ],
        libraries=['ssl', 'crypto', 'mysqlclient', 'pq'],  # Added 'pq' for PostgreSQL
        extra_link_args=[]
    )]
)
