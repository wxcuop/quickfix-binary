name: Build and Deploy

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        python-version: [ '3.12' ]
        os: [ 'ubuntu-latest' ]
    steps:
      - uses: actions/checkout@v4
      - name: Setup
        run: |
          sudo apt-get update
          sudo apt-get install -y build-essential autoconf automake libtool pkg-config openssl libssl-dev dos2unix libltdl-dev
          sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev
          sudo apt-get install -y postgresql postgresql-contrib libpq-dev
      - name: Setup python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - name: Install dependencies
        run: pip install setuptools wheel auditwheel
      - name: Create C++ directory
        run: mkdir -p C++
      - name: Create dummy MySQLStubs.h
        run: |
          echo '#ifndef MYSQLSTUBS_H' > C++/MySQLStubs.h
          echo '#define MYSQLSTUBS_H' >> C++/MySQLStubs.h
          echo '// Dummy content' >> C++/MySQLStubs.h
          echo '#endif // MYSQLSTUBS_H' >> C++/MySQLStubs.h
      - name: Convert line endings
        run: dos2unix ./build.sh
      - name: Make build.sh executable
        run: chmod +x ./build.sh
      - name: Build
        env:
          CPLUS_INCLUDE_PATH: /usr/include/mysql
        run: ./build.sh
      - name: Fix linux wheel
        run: auditwheel repair $(ls ./dist/*.whl | head -1) --plat manylinux_2_17_x86_64

  deploy:
    needs: build
    permissions:
      pages: write
      id-token: write

    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Copy wheel to dist
        run: |
          mkdir -p dist
          cp $(ls ./dist/*.whl | head -1) dist/
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
        with:
          github_token: ${{ secrets.GH_PAT }}
          publish_dir: ./dist
