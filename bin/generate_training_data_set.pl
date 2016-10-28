#!/usr/bin/perl

use strict;
use Cwd;

use File::Spec;
use File::Basename;
use Cwd 'abs_path';

=head


=cut 


# directory of where this script is called
my $cwd = dirname($0);

sub usage {
	print "\nUsage: " . basename($0) . " [ INPUT-DIR ] [ OUTPUT-FILE ] ";
}

if ( @ARGV != 2 ) {
	usage;
	print "\n\n\tPlease ensure to have 2 agruments:\n\t\tinput directory of emaf files\n\t\toutput training file name\n\n";
	exit (1);
}

my ($INPUT_DIR) = abs_path($ARGV[0]);
my ($OUTPUT_FILE) = $ARGV[1];

#java -jar /.mounts/labs/hudsonlab/public/qtrinh/svn/isown/bin/REFORMVCF_v1.0.jar   -vcfFolder ./ -output ./Project_final_Sept2016.emaf


#java -jar /.mounts/labs/hudsonlab/public/qtrinh/svn/isown/bin/ARFFgenerator_v1.0.jar -input Project_final_Sept2016.emaf -output ./myarfffile.arff


printf "\nReformat files in '$INPUT_DIR' to emaf ... \n\n";
system "java -jar ${cwd}/../bin/REFORMVCF_v1.0.jar -vcfFolder $INPUT_DIR -output ${OUTPUT_FILE}.emaf";


printf "\nGenerate training data set for '$INPUT_DIR' ... \n\n";
system "java -jar ${cwd}/../bin/ARFFgenerator_v1.0.jar -input ${OUTPUT_FILE}.emaf  -output ${OUTPUT_FILE}";

printf "\n\nDone\n\n";


