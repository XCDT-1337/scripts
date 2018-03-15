#!/bin/bash

pandoc -s linux-hardening.md windows-hardening.md firewall.md windows-notes.md --listings --template=template.tex --latex-engine=xelatex -o CompetitionGuide.pdf