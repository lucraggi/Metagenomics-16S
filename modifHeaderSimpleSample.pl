#!/usr/bin/perl
use strict;
use warnings;

### Este programa modifica los headers de cualquier archivo en formato fasta
### Alejandra Escobar, USMB, IBt, UNAM

die "Usage: $0 file.fasta\n" unless @ARGV;
my $file = shift;
#my$file_inside=$file;
#$file_inside=~s/-/_/g;
#my@array_file_inside=split(/_/, $file);
#my$file_inside=join("_", $array_file_inside[0], $array_file_inside[1]);
my $cont=0;
open OUT, ">mod_$file" || die ("No puedo crear mod_$file, revisar permisos de escritura en directorio actual\n");
open CHANGE, ">change_record_$file.list" || die ("No puedo crear change_record_$file.list, revisar permisos de escritura en directorio actual\n");
open (ARCH, $file) or die ("No puedo abrir el archivo $file") ;
while (<ARCH>) {
	chomp ;
	if ($_ =~ /^>/) {
		$cont++;
                print CHANGE "$_\t>$file|seq_$cont\n";
		print OUT ">$file|seq_$cont\n" ;
	}else {
		print OUT "$_\n" ;
	}
}
close(ARCH);
close(OUT);
close(CHANGE);
exit;
