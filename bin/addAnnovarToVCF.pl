#!/usr/bin/perl

### usage cat vcf | addAnnvarToVcf.pl varFuncFile exonicVarFuncFile > annovar.vcf

use strict;
use warnings;

my $varFuncFile = $ARGV[0];
my $exonicVarFuncFile = $ARGV[1];

my %varFunc;
my %exonicVarFunc;

my $l;
my @f;

# pull variant function file into hash
open (FILE, "<$varFuncFile") or die "Couldn't open $varFuncFile/\n";
while ($l = <FILE>)
{
	chomp $l;
	@f = split(/\t/, $l);

	unless ($l =~ /^#/)
	{
		$f[0] =~ s/;/:/g;
		$f[1] =~ s/;/:/g;
		$varFunc{"$f[7]\t$f[8]\t$f[10]\t$f[11]"} = ";ANNOVAR=$f[0],$f[1]";
		$varFunc{"$f[7]\t$f[8]\t$f[10]\t$f[11]"} =~ s/ /-/g;
	}
}
close FILE;



# pull exonic variant function file into hash

open (FILE, "<$exonicVarFuncFile") or die "Couldn't open $exonicVarFuncFile/\n";
while ($l = <FILE>)
{
	chomp $l;
	@f = split(/\t/, $l);

	unless ($l =~ /^#/)
	{
		$f[0] =~ s/;/:/g;
		$f[1] =~ s/;/:/g;
		$exonicVarFunc{"$f[8]\t$f[9]\t$f[11]\t$f[12]"} = ";ANNOVAR_EXONIC=$f[1],$f[2]";
		#$exonicVarFunc{"$f[8]\t$f[9]\t$f[11]\t$f[12]"} =~ s/ /-/g;  ### not sure why i thought to replace spaces in these values, removed for now
	}
}
close FILE;



# iterate over vcf to check for annotation and add to info column
# add note to header?

while ($l = <STDIN>)
{
	chomp $l;
	@f = split(/\t/, $l);

	if ($l =~ /^#/)
	{
		print $l . "\n";
	}
	else
	{
		if (exists $varFunc{"$f[0]\t$f[1]\t$f[3]\t$f[4]"})
		{
			$f[7] .= $varFunc{"$f[0]\t$f[1]\t$f[3]\t$f[4]"};
		}

		if (exists $exonicVarFunc{"$f[0]\t$f[1]\t$f[3]\t$f[4]"})
		{
			$f[7] .= $exonicVarFunc{"$f[0]\t$f[1]\t$f[3]\t$f[4]"};
		}

		print $f[0];
		for (my $i = 1; $i < scalar(@f); $i++)
		{
			print "\t$f[$i]";
		}
		print "\n";
	}


}





