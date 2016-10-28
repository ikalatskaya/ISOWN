#!/usr/bin/perl

use strict;
use Cwd;

use File::Spec;
use File::Basename;

=head

wget ftp://ftp.broadinstitute.org/pub/ExAC_release/current/ExAC.r0.3.1.sites.vep.vcf.gz

zcat ExAC.r0.3.1.sites.vep.vcf.gz  | head -500 | grep ^#  > ExAC.r0.3.1.sites.vep.modified.vcf
zcat ExAC.r0.3.1.sites.vep.vcf.gz  | grep -v ^#  | awk '{ print "chr"$0 }' >> ExAC.r0.3.1.sites.vep.modified.vcf

bgzip ExAC.r0.3.1.sites.vep.modified.vcf

tabix -p vcf ExAC.r0.3.1.sites.vep.modified.vcf.gz

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
system "zcat $INPUT_FILE  | grep -v \"^#\" | awk '{ print \"chr\"\$0 }' >> ${OUTPUT_FILE}";


printf "\nCompressing $OUTPUT_FILE ... ";
system "bgzip ${OUTPUT_FILE}; tabix -p vcf ${OUTPUT_FILE}.gz";

printf "\n\nDone\n\n";



