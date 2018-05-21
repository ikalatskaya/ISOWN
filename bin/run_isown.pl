#!/usr/bin/perl

use strict;
use Cwd;

use File::Spec;
use File::Basename;
use Cwd 'abs_path';


# directory of where this script is called
my $cwd = dirname($0);

sub usage {
	print "\nUsage: " . basename($0) . " [ INPUT-DIR ] [ OUTPUT-PREDICTED-FILE ] [ ADDITIONAL_ARG ] ";
}

if ( @ARGV != 3 ) {
	usage;
	print "\n\n\tPlease ensure to have 3 agruments:\n\t\tinput directory of VCF files\n\t\tpredicted output file name\n\t\tadditional agruments (  \" -trainingSet ../bin/data/training/BRCA_50_TrainSet.arff -sanityCheck false \"\n\n";
	exit (1);
}

my ($INPUT_DIR) = abs_path($ARGV[0]);
my ($OUTPUT_FILE) = $ARGV[1];
my ($CMD_ARG) = $ARGV[2];

printf "\nReformat files in '$INPUT_DIR' to emaf ... \n\n";
system "java -jar ${cwd}/../bin/REFORMVCF_v1.0.jar -vcfFolder $INPUT_DIR -output ${OUTPUT_FILE}.emaf";

printf "\nRunning prediction using file '${OUTPUT_FILE}.emaf'  ... \n\n";
system "java -jar ${cwd}/../bin/ISOWN_v1.0.jar -input_file ${OUTPUT_FILE}.emaf -output ${OUTPUT_FILE} $CMD_ARG "; 
#java -jar $ISOWN_DIR/ISOWN_v1.0.jar -input_file $WORKING_DIR/*.emaf -trainingSet $ISOWN_DIR/data/training/BRCA_4_TrainSet.arff -classifier nbc -output FinalFile_SomaticMutations_ISOWN

printf "\n\nDone\n\n";


