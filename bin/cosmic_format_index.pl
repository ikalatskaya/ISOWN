#!/usr/bin/perl

use strict;
use Cwd;

use File::Spec;
use File::Basename;

=head
Download both COSMIC CosmicCodingMuts.vcf.gz and CosmicNonCodingVariants.vcf.gz files from http://cancer.sanger.ac.uk/cosmic/download.
An account is needed to download COSMIC VCF files - see https://cancer.sanger.ac.uk/cosmic/register

sftp "your_email_address"@sftp-cancer.sanger.ac.uk

cd /cosmic/grch37/cosmic/v78/VCF
mget *.gz
quit

=cut 


# directory of where this script is called
my $cwd = dirname($0);

sub usage {
	print "\nUsage: " . basename($0) . " [ CODING-VCF-GZ-FILE ] [ NON-CODING-VCF-GZ-FILE ] [ OUTPUT-VCF-FILE ]";
}

if ( @ARGV != 3 ) {
	usage;
	print "\n\n\tPlease ensure to have 3 agruments:\n\tCOSMIC coding VCF .gz file\n\tCOSMIC non-coding VCF .gz file\n\toutput VCF file name including version number!!!\n\n";
	exit (1);
}

my ($CODING_FILE) = $ARGV[0];
my ($NON_CODING_FILE) = $ARGV[1];
my ($OUTPUT_FILE) = $ARGV[2];

# combine coding and non-coding VCF headers
printf "\nExtract headers from ${CODING_FILE} and ${NON_CODING_FILE}  ...";
system "zcat $CODING_FILE  | head -500  | grep \"^#\" | grep -v CHROM > _coding.header";
system "zcat $NON_CODING_FILE  | head -500  | grep \"^#\" > _non.coding.header";


# get the headers
printf "\n\nCombine headers ...";
system "echo \"#################################\" >_header ";
system "echo \"##header for $CODING_FILE \" >> _header";
system "cat _coding.header >>_header";
system "echo \"#################################\" >> _header";
system "echo \"##header for $NON_CODING_FILE \" >> _header ";
system "cat _non.coding.header >> _header ";



# added chr, CODING=1, and non-coding
printf "\n\nAdding CODING=1 and non-coding=1 ... ";
system "zcat $CODING_FILE  | awk '{ if (\$1 ~ /^#/) { print \$0 } else { print \"chr\"\$0\";CODING=1\" }}' | grep -v \"^#\" > _coding.modified ";

# added chr and NONCODING=1
system "zcat $NON_CODING_FILE  | awk '{ if (\$1 ~ /^#/) { print \$0 } else { print \"chr\"\$0\";non-coding=1\" }}' | grep -v \"^#\" > _non.coding.modified";

system "cat _coding.modified _non.coding.modified | sort -k1,1 -k2,2n > _data ";

# check the header of hte VCF file to set the version
system "cat _header _data | sed 's/^chrMT/chrM/' > ${OUTPUT_FILE}";
system "bgzip ${OUTPUT_FILE}; tabix -p vcf ${OUTPUT_FILE}.gz";

# clean up
printf "\n\nCleaning up ....";
system "rm _coding.header _non.coding.header _coding.modified _non.coding.modified _header _data";

printf "\n\nDone\n\n";



