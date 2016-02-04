#!/usr/bin/perl

# Example usage:
# perl axtLift.pl myGtfFile.gtf myAxtFile.axt /path/to/output/directory/

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

sub axtLift{
	
	my $gffFile = shift;
	my $axtFile = shift;
	my $outDir = shift;
	open my $gffData, "<", $gffFile or die "could not open $gffFile";
	open my $axtData, "<", $axtFile or die "could not open $axtFile";
	
	my @lastAxt = nextAxt($axtData);
	my ($fromStart, $fromEnd, $toChr, $toStart, $toEnd, $toStrand) = axtLocs($lastAxt[0]);
	#~ print "$lastAxt[1]\n";
	
	my $lineNum = 0;
	GTFLINE:while(my $line = <$gffData>){
		$lineNum ++;
		print "$lineNum\n";
		my @line = split(/\t/, $line);
		my $mmstart = $line[3];
		my $mmend = $line[4];
		my $mmstrand = $line[6];
		while($mmstart > $fromEnd){
			@lastAxt = nextAxt($axtData);
			if($lastAxt[0] == ""){
				my $outFile = $outDir . "/" . $line[0] . "_unmapped.gff";
				open my $outData, '>>', $outFile or die "could not open $outFile";
				print $outData join("\t", @line);
				close $outData;
				next GTFLINE;
			}
			($fromStart, $fromEnd, $toChr, $toStart, $toEnd, $toStrand) = axtLocs($lastAxt[0]);
		}
		if($fromStart > $mmstart || $fromEnd < $mmend){
			my $outFile = $outDir . "/" . $line[0] . "_unmapped.gff";
			open my $outData, '>>', $outFile or die "could not open $outFile";
			print $outData join("\t", @line);
			close $outData;
			next;
		}
		
		#Complete match for this exon. Determine new coordinates.
		my $newStartOff = 0;
		my $oldStartOff = $mmstart - $fromStart;
		my @inSeq = split(//, $lastAxt[1]);
		my @outSeq = split(//, $lastAxt[2]);
		while($oldStartOff > 0){
			$newStartOff ++;
			my $mmNuc = shift @inSeq;
			my $newNuc = shift @outSeq;
			if ($newNuc eq "-"){
				$newStartOff --;
			}
			next if ($mmNuc eq "-");
			$oldStartOff --;
		}
		my $newEndOff = $newStartOff;
		my $oldEndOff = $mmend - $mmstart;
		while($oldEndOff > 0){
			$newEndOff ++;
			my $mmNuc = shift @inSeq;
			my $newNuc = shift @outSeq;
			if ($newNuc eq "-"){
				$newEndOff --;
			}
			next if ($mmNuc eq "-");
			$oldEndOff --;
		}
		$line[0] = $toChr;
		$line[3] = $toStart + $newStartOff;
		$line[4] = $toEnd + $newEndOff;
		if($mmstrand eq "+"){
			$line[6] = $toStrand;
		}else{
			if($toStrand eq "+"){
				$line[6] = "-";
			}else{
				$line[6] = "+";
			}
		}
		my $outFile = $outDir . "/" . $line[0] . "_new.gff";
		open my $outData, '>>', $outFile or die "could not open $outFile";
		print $outData join("\t", @line);
		close $outData;
		
	}
	
	close $gffData;
	close $axtData;
}


my ($gffFile, $axtFile, $outDir) = @ARGV;
axtLift($gffFile, $axtFile, $outDir);
