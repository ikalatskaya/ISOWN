#!/usr/bin/perl

use strict;

my @tools = ("java", "tabix");
my $tool_path = '';
my $foundTool;

print "\n\nChecking dependencies for ISOWN ... \n\n";
	
foreach my $t (0 .. $#tools) {
	$foundTool = 0;
		
	my $tool_name = $tools[$t];
	for my $path ( split /:/, $ENV{PATH} ) {
		if ( -f "$path/$tool_name" && -x _ ) {
			$foundTool = 1;
			print "$tool_name found in $path\n\n";
			#$tool_path = "$path/$tool_name";
			last ;
		}
	}
	if ($foundTool == 0) {
		print "$tool_name does not exist or not in the path!  Please install $tool_name or make sure it is in the path!\n\n";
	}
}
print "\n\n";
