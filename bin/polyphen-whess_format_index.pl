#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

=head 

for i in `ls *features.tab`; do j=`echo $i | sed 's/features/scores/'`; paste  $i $j ; done  | cut -d$'\t' -f1-10,16-20,56- > WHESS

F="WHESS.txt"
head -1 WHESS | cut -f 2- | awk '{ print "#chr\tstart\tend\t"$0 }' > $F

cat WHESS | grep -v transcript | sed 's/:/\t/' | awk '{ print $1"\t"$2"\t"$2"\t"$0 }' | cut -f 1-3,6- | sort -k1,1 -k2,2n -k3,3n >> $F

bgzip $F ; tabix -s 1 -b 2 -e 3 ${F}.gz


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

printf "\n\nConcat PolyPhen feature and score files together ...";
my $firstTime = 1;
my $fileScore;
while (my $file = readdir(DIR)) {

	# Use a regular expression to ignore files beginning with a period
	next if ($file =~ m/^\./) || ($file !~ m/features.tab/);
	$fileScore = $file;
	$fileScore =~ s/features/scores/;
	
 	print "\nprocessing $file\t$fileScore ... ";
	if ($firstTime == 1) {
		system "paste ${INPUT_DIR}/$file ${INPUT_DIR}/$fileScore > _tmp";
		$firstTime = 0;
	} else {
		system "paste ${INPUT_DIR}/$file ${INPUT_DIR}/$fileScore | grep -v chr_pos >> _tmp";
	}
}
closedir(DIR);

system "cat _tmp | cut -d '\t' -f1-10,16-20,56- > _tmp.txt ";


printf "\n\nCreating $OUTPUT_FILE ...";
system "head -1 _tmp.txt | cut -f 2- | awk '{ print \"#chr\tstart\tend\t\"\$0 }' > $OUTPUT_FILE ";
system "cat _tmp.txt | grep -v transcript | sed 's/:/\t/' | awk '{ print \$1\"\t\"\$2\"\t\"\$2\"\t\"\$0 }' | cut -f 1-3,6- | sort -k1,1 -k2,2n -k3,3n >> $OUTPUT_FILE ";

printf "\n\nCompressing $OUTPUT_FILE ...";
system "bgzip $OUTPUT_FILE  ; tabix -s 1 -b 2 -e 3 ${OUTPUT_FILE}.gz";


printf "\n\nCleaning up ...\n\n";
system "rm _tmp _tmp.txt ";
printf "\n\nDone\n\n";

exit 0;
