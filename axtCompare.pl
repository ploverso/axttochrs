#!/usr/bin/perl

# Example usage:
# perl axtCompare.pl myGtfFile.gtf myAxtFile.axt myOutFile.gtf

use warnings 'FATAL';
use strict;

sub nextAxt{
	
	my $fh = shift;
	my @lastAxt;
	while(scalar @lastAxt < 4){
		my $line = <$fh>;
		# Skip comments
		next if ($line =~ m/^#/);
		chomp($line);
		push @lastAxt, $line;
	}
	return @lastAxt;
}

sub axtLocs{
	my $axtLine = shift;
	my @line = split(/\s/, $axtLine);
	my @axtImportant = ($line[2], $line[3], $line[4], $line[5], $line[6], $line[7]);
	return @axtImportant;
}

sub axtCompare{
	
	my $gffFile = shift;
	my $axtFile = shift;
	my $outFile = shift;
	open my $gffData, "<", $gffFile or die "could not open $gffFile";
	open my $axtData, "<", $axtFile or die "could not open $axtFile";
	
	my @lastAxt = nextAxt($axtData);
	my ($fromStart, $fromEnd, $toChr, $toStart, $toEnd, $toStrand) = axtLocs($lastAxt[0]);
	#~ print "$lastAxt[1]\n";
	
	my $lineNum = 0;
	while(my $line = <$gffData>){
		#~ $lineNum ++;
		#~ print "$lineNum\n";
		my @line = split(/\t/, $line);
		my $mmstart = $line[3];
		my $mmend = $line[4];
		my $mmstrand = $line[6];
		while($mmstart > $fromEnd){
			@lastAxt = nextAxt($axtData);
			($fromStart, $fromEnd, $toChr, $toStart, $toEnd, $toStrand) = axtLocs($lastAxt[0]);
		}
		if($fromStart > $mmstart || $fromEnd < $mmend){
			next;
		}
		
		open my $outData, '>>', $outFile or die "could not open $outFile";
		print $outData join("\t", @line);
		close $outData;
		
	}
	
	close $gffData;
	close $axtData;
}


my ($gffFile, $axtFile, $outFile) = @ARGV;
axtCompare($gffFile, $axtFile, $outFile);
