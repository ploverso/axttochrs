#!/usr/bin/perl

# Usage: axtToChrs.pl $inFile $outDir
# inFile: The input .axt file
# $outDir: The directory into which to write the chromosome axt file.

# Example usage:
# perl axtToChrs.pl myAxtFile.axt ./

use warnings;
use strict;

my ($inFile, $outDir) = @ARGV;
