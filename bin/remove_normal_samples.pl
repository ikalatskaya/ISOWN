#!/usr/bin/perl 
use strict;
use warnings;
use File::Basename;

#
#
#
#
#

if ( @ARGV != 1 ) {
   print "\n";
   print "\nremove entries from NORMAL samples";
   print "\n\nusage: perl " . basename($0) . " [ INPUT_FILE ] ";
   print "\n\n";
   exit (0);
}

my $INPUT_FILE =  $ARGV[0];

my $line;

open (FHI, "<" , $INPUT_FILE) || die ;
while ($line = <FHI>) {
	if ($line =~ /^#/) {
		print $line;
		next;
	}

   chomp $line;
   my @fields=split /\t/, $line;
	if (($fields[0] =~ /_R_/) || ($fields[0] =~ /NORMAL/)) {
	} else {
		print $line . "\n";
	}
}
close FHI;

