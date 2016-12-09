#!/usr/bin/perl

use strict;
use Cwd;

use File::Spec;
use File::Basename;


# directory of where this script is called
my $cwd = dirname($0);

# databases to annotate against to 
my $REF="$cwd/../external_databases/hg19_random.fa";
my $dbSNP_142="$cwd/../external_databases/dbSNP142_All_20141124.vcf.gz.modified.vcf.gz";
my $COSMIC_69="$cwd/../external_databases/COSMIC_v69.vcf.gz";
my $ExAC="$cwd/../external_databases/ExAC.r0.3.sites.vep.vcf.20150421.vcf.gz";
my $MA="$cwd/../external_databases/MA.release2.vcf.gz";
my $POLYPHEN="$cwd/../external_databases/WHESS_20150403.txt.gz";

sub usage {
	print "\nUsage: " . basename($0) . " [ INPUT_VCF_FILE ] [ OUTPUT_VCF_FILE ]";
}

if ( @ARGV != 2 ) {
	usage;
	print "\n\n\tPlease enter input and/or output files!\n\n";
	exit (1);
}

# input and output from user
my ($inputFile) = $ARGV[0];
my ($finalOutputFile) = $ARGV[1];
#$finalOutputFile = $inputFile; $finalOutputFile =~ s/.vcf/.final.isown.annotated.vcf/;
my $outputFile; 
if (-e  "$cwd/annovar_annotation.pl") {
	print "\n\nannotating input file with ANNOVAR ...";
	$outputFile = $finalOutputFile . ".temp.annovar.vcf";
	system "perl $cwd/annovar_annotation.pl $inputFile $outputFile";
} else {
	print "\n\nANNOVAR is not found.  Please make sure ANNOVAR is installed in external_tools and try again \n";
	exit 1;
}


if (-e  "$dbSNP_142") {
	print "\n\nannotating input file with dbSNP ...";
	$inputFile = $outputFile;
	my $outputFile = $finalOutputFile . ".temp.dbSNP.vcf";
	system "perl $cwd/annotation.pl $inputFile $dbSNP_142 dbSNP142_All_20141124 $outputFile $REF";
} else {
	print "\n\nThe dbSNP 142 file is not found.  Please correct the path in $0 and try again - see path below:\n";
	print "\n\t$dbSNP_142\n\n"; 
	exit 1;
}


print "\n\nannotating input file with COSMIC ...";
$inputFile = $outputFile;
$outputFile = $finalOutputFile . ".temp.cosmic.vcf";
system "perl $cwd/annotation.pl $inputFile $COSMIC_69  COSMIC_69 $outputFile $REF";


print "\n\nannotating input file with ExAC ...";
$inputFile = $outputFile;
$outputFile = $finalOutputFile . ".temp.exac.vcf";
system "perl $cwd/annotation.pl $inputFile $ExAC ExAC.r0.3_20150421 $outputFile $REF";


print "\n\nannotating input file with MutationAccessor ...";
$inputFile = $outputFile;
$outputFile = $finalOutputFile . ".temp.ma.vcf";
system "perl $cwd/annotation.pl $inputFile $MA 2013_12_11_MA $outputFile $REF";


print "\n\nannotating input file with PolyPhen ...";
$inputFile = $outputFile;
$outputFile = $finalOutputFile . ".temp.polyphen.vcf";
#system "perl $cwd/annotation.pl $inputFile $POLYPHEN polyphenWHESS_20150403 $outputFile $REF";
system "$cwd/qpipeline tabix -m 2200 -i $inputFile -d $POLYPHEN -p polyphenWHESS_20150403 > $outputFile ";


print "\n\nannotating input file with sequence context ...";
$inputFile = $outputFile;
$outputFile = $finalOutputFile . ".temp.sequence.context.vcf";
system "$cwd/qpipeline vcf -m 80 -i $inputFile -f $REF > $outputFile";


print "\n\ncalculating flanking region ...";
$inputFile = $outputFile;
$outputFile = $finalOutputFile . ".temp.flanking.vcf";
system "$cwd/qpipeline_internal tabix -m 9555 -i $inputFile -f $REF > $outputFile";


print "\n\nfinal reformatting ...";
$inputFile = $outputFile;
$outputFile = $inputFile . ".temp.final.vcf";
system "$cwd/qpipeline_internal tabix -m 9503 -i $inputFile > $outputFile";


# work around to remove or exclude entries from NORMAL samples
$inputFile = $outputFile;
$outputFile = $finalOutputFile;
system "perl $cwd/remove_normal_samples.pl $inputFile > $outputFile";


# cleanup 
my $filePatternToRemove = $finalOutputFile . "*.temp.*";
print "\n\ncleanup: deleting temporary files ( $filePatternToRemove ) ...\n\n";
# sleep 10 seconds just in case there are delayed in file system etc.
system "sleep 10";
system "rm $filePatternToRemove ";



