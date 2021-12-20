#!/usr/bin/perl
use strict;
use warnings;

######## PROGRAMA QUE ELIMINA LOS OTUS DE BAJA FRECUENCIA UNICOS EN LAS MUESTRAS #######
######## Alejandra Escobar Zepeda, USMB, IBt, UNAM
######## 27/Noviembre/2016

scalar@ARGV == 1 || die "usage: $0 <OTU_matrix.txt>
";

my $file=$ARGV[0];

## Recorriendo la matriz
my $suma=0;
open (FILE, $file) or die ("No puedo abrir el archivo $file\n");
open OUT, ">filtered_$file" || die ("No puedo crear el archivo filtered_$file, revisar permisos de escritura en directorio actual\n");
open SINGLE, ">singletones_$file" || die ("No puedo crear el archivo singletones_$file, revisar permisos de escritura en directorio actual\n");
my $header=<FILE>;
print OUT "$header";
while (<FILE>) {
	chomp;
	my@line=split('\t', $_);
	my$OTU=shift@line;
	foreach my $var (@line){
		if ($var >= 1) {
			$suma=$suma+$var;
		}
	}
	if ($suma>1){
		my$print=join("\t", $OTU, @line);
		print OUT "$print\n";
		$suma=0;
	}else{
		my$print=join("\t", $OTU, @line);
		print SINGLE "$print\n";	
		$suma=0;
	}
}
close(FILE);
close(OUT);
close(SINGLE);
