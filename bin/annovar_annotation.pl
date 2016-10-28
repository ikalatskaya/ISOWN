#!/usr/bin/perl

use strict;

use Cwd;

use File::Basename;

sub usage {

	print "\nUsage: $0 [ INPUT_VCF_FILE ] [ OUTPUT_VCF_FILE ] \n";
}

my ($inputVCFFile, $outputVCFFile) = @ARGV;

# dirname of where this script is
my $cwd = dirname($0);

if (not defined $inputVCFFile) {
	  usage;
	  print "\n\tPlease provide input VCF file name\n\n";
	  exit ;
}
if (not defined $outputVCFFile) {
	  usage;
	  print "\n\tPlease provide output VCF file name\n\n";
	  exit ;
}

# use annovar to convert VCF format to annovar format 
system "perl $cwd/../external_tools/annovar_2012-03-08/convert2annovar.pl --format vcf4 --includeinfo $inputVCFFile 1> ${outputVCFFile}.temp.convert2annovar 2> ${outputVCFFile}.temp.stdout ";


# call annovar annotation 
system "perl $cwd/../external_tools/annovar_2012-03-08/annotate_variation.pl -geneanno ${outputVCFFile}.temp.convert2annovar  -buildver hg19 $cwd/../external_tools/annovar_2012-03-08/humandb";

# put togheter what annovar generated with orginal VCF file 
system "cat $inputVCFFile | perl  $cwd/addAnnovarToVCF.pl ${outputVCFFile}.temp.convert2annovar.variant_function ${outputVCFFile}.temp.convert2annovar.exonic_variant_function > $outputVCFFile ";



