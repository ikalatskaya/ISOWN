#!/usr/bin/perl

use strict;

use Cwd;

use File::Basename;

sub usage {

	print "\nUsage: $0 [ INPUT_VCF_FILE ] [ INPUT_VCF_DATABASE_FILE ] [ INPUT_VCF_DATABASE_FILE_PREFIX ] [ OUTPUT_VCF_FILE ] [ FASTA_REFERENCE_FILE ]\n";
}

my ($inputVCFFile, $vcfDatabase, $vcfDatabasePrefix, $outputVCFFile, $referenceFile) = @ARGV;

# dirname of where this script is
my $cwd = dirname($0);

if (not defined $inputVCFFile) {
	  usage;
	  print "\n\tPlease provide input VCF file name\n\n";
	  exit ;
}
if (not defined $vcfDatabase) {
	  usage;
	  print "\n\tPlease provide input VCF database file\n\n";
	  exit ;
}
 
if (not defined $vcfDatabasePrefix) {
	  usage;
	  print "\n\tPlease provide input VCF database file prefix\n\n";
	  exit ;
}
if (not defined $outputVCFFile) {
	  usage;
	  print "\n\tPlease provide output VCF file name\n\n";
	  exit ;
}
if (not defined $outputVCFFile) {
	  usage;
	  print "\n\tPlease provide output VCF file name\n\n";
	  exit ;
}

system "$cwd/qpipeline tabix -m 2020 -d $vcfDatabase -A -E -p $vcfDatabasePrefix -i $inputVCFFile  -f $referenceFile > $outputVCFFile"

