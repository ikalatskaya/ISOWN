#!/usr/bin/perl

use Cwd;

use File::Spec;
use File::Basename;

use strict;

my @tools = ("git", "wget", "bzip2", "java", "tabix", "weka.jar");
my $tool_path = '';
my $foundTool;
my $printHeader = 1;

print "\n\nChecking dependencies for ISOWN ... \n\n";

my $cwd = dirname($0);
	
foreach my $t (0 .. $#tools) {
	$foundTool = 0;
		
	my $tool_name = $tools[$t];
	for my $path ( split /:/, $ENV{PATH} ) {
		if (( -f "$path/$tool_name" && -x _ ) || ( -f "$cwd/$tool_name")) {
			$foundTool = 1;
			#print "$tool_name found in $path\n\n";
			#$tool_path = "$path/$tool_name";
			last ;
		}
	}
	if ($foundTool == 0) {
		if ($printHeader == 1) {
			$printHeader = 0;
			print "\nPlease make sure the following tools are installed and included in the path ( see ISOWN manual for instructions ):";
		}
		if ($tool_name =~ /weka/) {
			print "\n\n$tool_name ( download and place $tool_name in $cwd directory )";
		} else {		
			print "\n\n$tool_name";
		}
	}
}
if ($printHeader == 1) {
	print "All dependencies for ISOWN are installed!\n";
}
print "\n\n";
