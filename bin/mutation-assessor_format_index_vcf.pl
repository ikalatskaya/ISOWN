#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;


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
	# command for release 1
	#system "cat $f | grep -v Mutation |  awk -F \"\t\" '{ print \$1\"\tRefGenome variant=\"\$2\";Gene=\"\$3\";Uniprot=\"\$4\";Info=\"\$5\";Uniprot variant=\"\$6\";Func. Impact=\"\$7\";FI score=\"\$8 }'  | tr ',' '\t' | cut -f 2- | awk '{ print \"chr\"\$0 }' | awk '{ print \$1\"\t\"\$2\"\t.\t\"\$3\"\t\"\$4\"\t.\t.\t\"\$0 }' | cut -f 1-7,12- > ${f}.vcf "

	# command for release 3 report by 
	system "cat $f | grep -v Mutation | sed 's/\"//g' | sed 's/hg19,//' | tr ',' '\t' | awk -F\"\t\" '{ print \"chr\"\$1\"\t\"\$2\"\t.\t\"\$3\"\t\"\$4\"\t.\t.\tRefGenome variant=\"\$5\";Gene=\"\$6\";Uniprot=\"\$7\";Info=\"\$8\";Uniprot variant=\"\$9\";Func. Impact=\"\$10\";FI score=\"\$11 }' > ${f}.vcf" ;

}
closedir(DIR);

printf "\n\nCreating $OUTPUT_FILE ... ";
system "cat ${INPUT_DIR}/*.vcf | sort -k1,1 -k2,2n > ${OUTPUT_FILE}";

printf "\n\nCompressing $OUTPUT_FILE ... ";
system "bgzip $OUTPUT_FILE  ; tabix -p vcf ${OUTPUT_FILE}.gz";


printf "\n\nCleaning up ...\n\n";
system "rm ${INPUT_DIR}/*.vcf ";
printf "\n\nDone\n\n";

exit 0;
