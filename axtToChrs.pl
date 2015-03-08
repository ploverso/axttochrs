#!/usr/bin/perl

# Usage: axtToChrs.pl $inFile $outDir
# inFile: The input .axt file
# $outDir: The directory into which to write the chromosome axt file.

# Example usage:
# perl axtToChrs.pl myAxtFile.axt ./

use warnings;
use strict;

#Takes an input file and a output directory
#Returns nothing- output is written to file
sub processAxt{
	
	my $inFile = shift;
	my $outDir = shift;
	open my $axtData, "<", $inFile or die "could not open $inFile";
	my $currentChr = "";
	
	my $lineNum = 0;
	while(<$axtData>){
		$lineNum++;
		my $line = $_;
		
		# Skip comments
		next if ($line =~ m/^#/);
		
		my @line;
		# Update chromosome number if new alignment
		if($line =~ m/^\d/){
			@line = split(/\s/, $line);
			$currentChr = $line[1];
		}
		#Removed unmapped regions
		#next if(length($currentChr) > 6);
		my $outfile = $outDir . "/" . $currentChr . ".axt";
		open my $fh, '>>', $outfile or die "could not open $outfile";
		print $fh $line;
		close $fh;
		
		# Print line number every 100,000 to give an idea of progress
		if($lineNum % 100000 == 0){
			print "$lineNum\n";
		}
	}
	close $axtData;
}


my ($inFile, $outDir) = @ARGV;
processAxt($inFile, $outDir);
