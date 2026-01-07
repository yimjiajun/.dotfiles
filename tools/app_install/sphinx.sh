#!/bin/bash
# Install 'sphinx' and related packages
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./sphinx.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./sphinx.sh --force
#
# Sphinx is a documentation generator for Python projects.
# It converts reStructuredText files into various output formats, such as HTML and PDF.
#
# Tools:
#
# 1. sphinx-quickstart: Command-line tool to create a new Sphinx documentation project.
# 2. sphinx_rtd_theme: A Sphinx theme designed for Read the Docs.
# 3. sphinx-design: A Sphinx extension that provides design components for better documentation.
# 4. myst-parse: A Sphinx extension that allows parsing of Markdown files using the MyST syntax.
# 5. latexpdf: Command to build PDF documents from Sphinx documentation using LaTe (make latexpdf)
# 6. latexmk: A Perl script that automates the process of generating LaTeX documents. (make latexpdf)
#
# Guide:
#
# 1. Add 'sphinx_rtd_theme' to use the Read the Docs theme for Sphinx documentation.
#
#   sphinx_rtd_theme usage example: add the following lines to your Sphinx conf.py
#
#   # conf.py
#   html_theme = 'sphinx_rtd_theme'
#
# 2. sphinx-design provides design components for Sphinx documentation.
#
#    sphinx-design usage example: add the following lines to your Sphinx conf.py
#
#    # conf.py
#    extensions = [ 'sphinx_design', ]
#
# 3. myst-parser is a markdown compatible parser for Sphinx.
#
#   myst-parser usage example: add the following lines to your Sphinx conf.py
#
#   # conf.py
#   extensions = [ 'myst_parser', ]

tool='sphinx'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required 'sphinx-quickstart' "${@}" && {
    pip_install_package "$tool" || exit 1
    pip_install_package 'sphinx_rtd_theme' || exit 1
    pip_install_package 'sphinx-design' || exit 1
}

sphinx-quickstart --version

check_install_is_required "myst-docutils-demo" "${@}" && {
    pip_install_package 'myst-parser' || exit 1
}

myst-docutils-demo --version

check_install_is_required "pdflatex" "${@}" && {
    install_package 'texlive-latex-extra' || exit 1
}

pdflatex --version

check_install_is_required "latexmk" "${@}" && {
    install_package 'latexmk' || exit 1
}

latexmk --version
