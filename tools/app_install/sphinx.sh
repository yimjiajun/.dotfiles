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
# 4. sphinxcontrib-mermaid: A Sphinx extension to include Mermaid diagrams in documentation.
# 5. mermaid-cli: A command-line interface for generating diagrams and flowcharts from Mermaid syntax.
# 6. myst-parse: A Sphinx extension that allows parsing of Markdown files using the MyST syntax.
# 7. latexpdf: Command to build PDF documents from Sphinx documentation using LaTe (make latexpdf)
# 8. latexmk: A Perl script that automates the process of generating LaTeX documents. (make latexpdf)
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
# 3. sphinxcontrib-mermaid allows inclusion of Mermaid diagrams in Sphinx documentation.
#
#    sphinxcontrib-mermaid usage example: add the following lines to your Sphinx conf.py
#
#    # conf.py
#    extensions = [ 'sphinxcontrib.mermaid', ]
#
# 4. mermaid-cli is a command-line interface for generating diagrams from Mermaid syntax.
#
#    mermaid-cli usage example: generate a PNG diagram from a Mermaid file
#
#    $ mmdc -i input.mmd -o output.png
#
#    # On Ubuntu 23.04 or later, you may need to add '--no-sandbox' flag due to Chromium sandboxing issues
#    $ mmdc -i input.mmdc -o output.png -p /dev/stdin <<< '{"args":["--no-sandbox"]}
#
#    - latexpdf is a Sphinx build command to generate PDF documents using LaTeX.
#
#      latexpdf usage example: run the following command in your Sphinx documentation directory
#
#      # conf.py
#      mermaid_output_format = "png"
#      mermaind_params = { '--theme', 'default',
#                          '--width', '2000',
#                          '--backgroundColor', 'transparent' }
#
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
  pip_install_package 'sphinxcontrib-mermaid' || exit 1
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

check_install_is_required "mmdc" "${@}" && {
  npm install -g @mermaid-js/mermaid-cli || exit 1
}

mmdc --version
