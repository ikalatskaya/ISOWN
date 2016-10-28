#!/usr/bin/perl

use strict;
use Cwd;

use File::Spec;
use File::Basename;

=head

# need to add 'chr' in front of chromosome column
# change chrMT to chrM
zcat 00-All.vcf.gz | head -500 | grep ^# > 00-All.modified.vcf
zcat 00-All.vcf.gz | grep -v ^# | awk '{ print "chr"$0 }' | sed 's/chrMT/chrM/' >> 00-All.modified.vcf

# zip using bgzip
bgzip 00-All.modified.vcf

# index using tabix
tabix -p vcf 00-All.modified.vcf.gz


=cut 


# directory of where this script is called
my $cwd = dirname($0);

sub usage {
	print "\nUsage: " . basename($0) . " [ INPUT-VCF-GZ-FILE ] [ OUTPUT-VCF-FILE ]";
}

if ( @ARGV != 2 ) {
	usage;
	print "\n\n\tPlease ensure to have 2 agruments:\n\tinput VCF .gz file\n\toutput VCF file name including version number!!!\n\n";
	exit (1);
}

my ($INPUT_FILE) = $ARGV[0];
my ($OUTPUT_FILE) = $ARGV[1];

printf "\nReformat $INPUT_FILE ... ";
system "zcat $INPUT_FILE  | head -500  | grep \"^#\" > ${OUTPUT_FILE}";
system "zcat $INPUT_FILE  | grep -v \"^#\" | awk '{ print \"chr\"\$0 }' | sed 's/chrMT/chrM/' >> ${OUTPUT_FILE}";


printf "\n\nCompressing $OUTPUT_FILE ... ";
system "bgzip ${OUTPUT_FILE}; tabix -p vcf ${OUTPUT_FILE}.gz";

printf "\n\nDone\n\n";



