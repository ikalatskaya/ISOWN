#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

=head 

wget http://mutationassessor.org/r2/MA.scores.hg19.tar.bz2


tar xvfz MA.scores.hg19.tar.bz2

cat MA.hg19/*.txt | grep -v Mutation | awk -F "\t" '{ print $1"\tRefGenome variant="$2";Gene="$3";Uniprot="$4";Info="$5";Uniprot variant="$6";Func. Impact="$7";FI score="$8 }' | tr ',' '\t' | cut -f 2- | awk '{ print "chr"$0 }' | awk '{ print $1"\t"$2"\t.\t"$3"\t"$4"\t.\t.\t"$0 }' | cut -f 1-7,12- > MA.release2.vcf


=cut 

sub usage {
	print "\nUsage: " . basename($0) . " [ INPUT-DIR ] [ OUTPUT-VCF-FILE ]";
}

if ( @ARGV != 2 ) {
	usage;
	print "\n\n\tPlease ensure to have 2 agruments:\n\tinput dir contained *features* files\n\toutput VCF file name including version number!!!\n\n";
	exit (1);
}


my ($INPUT_DIR, $OUTPUT_FILE) = @ARGV;

opendir(DIR, $INPUT_DIR) or die $!;


while (my $file = readdir(DIR)) {


	next if ($file =~ m/^\./) || ($file =~ m/vcf$/);

	my $f = "${INPUT_DIR}/$file";

	printf "\n\nReformatting $f to VCF format  ...";
	system "cat $f | grep -v Mutation |  awk -F \"\t\" '{ print \$1\"\tRefGenome variant=\"\$2\";Gene=\"\$3\";Uniprot=\"\$4\";Info=\"\$5\";Uniprot variant=\"\$6\";Func. Impact=\"\$7\";FI score=\"\$8 }'  | tr ',' '\t' | cut -f 2- | awk '{ print \"chr\"\$0 }' | awk '{ print \$1\"\t\"\$2\"\t.\t\"\$3\"\t\"\$4\"\t.\t.\t\"\$0 }' | cut -f 1-7,12- > ${f}.vcf "
}

closedir(DIR);

printf "\n\nCreating $OUTPUT_FILE ... ";
system "cat ${INPUT_DIR}/*.vcf | sort -k1,1 -k2,2n > ${OUTPUT_FILE}";

printf "\n\nCompressing $OUTPUT_FILE ... ";
system "bgzip $OUTPUT_FILE  ; tabix -s 1 -b 2 -e 3 ${OUTPUT_FILE}.gz";


printf "\n\nCleaning up ...\n\n";
system "rm ${INPUT_DIR}/*.vcf ";
printf "\n\nDone\n\n";

exit 0;
