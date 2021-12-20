#!/usr/bin/perl
use strict;
use warnings;

######## PROGRAMA QUE GENERA LAS ESTADISTICAS BASICAS DE RENDIMIENTO Y CALIDAD DE SECUENCIACION #######
######## Alejanda Escobar Zepeda, USMB, IBt, UNAM
######## 5/Julio/2016

scalar @ARGV == 1 || die "usage: $0 <files_list.txt>
        
        Programa que genera las estadisticas basicas de rendimiento y calidad de secuenciacion 
        para una serie de archivos en formato fastq
		  
        files_list.txt <file>           Lista de archivos de entrada, si son pareados deben estar 
                                        en la misma linea separados por tabulador. Los archivos se
                                        esperan en formato fastq, pueden estar comprimidos como fastq.gz

";

open OUT, ">basic_stats_out.txt" || "No puedo crear el archivo basic_stats_out.txt\n";
print OUT "Sample\tTotal_reads\tTotal_bases\tLong_promedio\tGC(%)\tCalidad_promedio\tLecturas_Ns(%)\tQ20(%)\tQ30(%)\n";

my $files = $ARGV[0];
open (VALUES, $files) or die ("No puedo abrir el archivo $files\n") ;
while (<VALUES>) {
	chomp;
	my $name = $_;
	STATS($name);
}
close(VALUES);
close(OUT);
system("rm concat*");

### Subrutina que genera estadisticas para cada archivo de entrada
sub STATS {
	my $arch_list=shift;
	my($reads_total, $suma_bases, $acumula_qual, $suma_qual_prom, $gc, $flag_n, $n, $q20, $q30)=(0,0,0,0,0,0,0,0,0);
	my $file;
	my @archivos_dscmp;

	my (@archivos)=split(/\t/, $arch_list);
	if (scalar@archivos > 1) {
		foreach my $arch_cmp (@archivos){
			if ($arch_cmp =~ /fastq.gz/){
				system("gzip -df $arch_cmp");
				$arch_cmp =~ s/\.gz//;
				push(@archivos_dscmp, $arch_cmp);
			}else{
				push(@archivos_dscmp, $arch_cmp);
			}
		}
		my$junto=join(' ', @archivos_dscmp);
		my$name=$archivos[0];
		system("cat $junto > concat_$name");
		$file="concat_$name";
		system("rm $junto");
	} else {
		$file=$arch_list;
	}

	open (IN, $file) or die ("No puedo abrir el archivo $file\n") ;
	my$name;
	while (defined($name=<IN>)) {
		my($read, $plus, $qual);
		$read = <IN>;
		$plus = <IN>;
	   	$qual = <IN>;

		chomp $read;
		chomp $qual;

		my$longitud=length($read);
		$suma_bases+=$longitud;	
	   	$reads_total++;

		my @read=split(//, $read);
		foreach my $nuc (@read) {
			if ($nuc =~ 'G' || $nuc =~ 'g' || $nuc =~ 'C' || $nuc =~ 'c' ){
				$gc++;
			}		
			if ($nuc =~ 'N' || $nuc =~ 'n'){
				$flag_n=1;
			}
		}

		if($flag_n==1){
			$n++;
			$flag_n=0;
		}
		
		my $size=length($qual);
		my @ql=split (//, $qual);
		foreach my $qual_num (@ql) {
			my$num=ord($qual_num)-33;
			$acumula_qual+=$num ;
		}
		my $prom_q_read=$acumula_qual/$size;
		$acumula_qual=0;
		$suma_qual_prom+=$prom_q_read;
		
		if ($prom_q_read >= 20){
			$q20++;				
		}
		if ($prom_q_read >= 30){
			$q30++;				
		}

	}
	close(IN);

	my $long_reads_prom=sprintf "%.2f", $suma_bases/$reads_total;
	my $gc_percent=sprintf "%.2f", ($gc/$suma_bases)*100;
	my $n_percent=sprintf "%.2f", ($n/$reads_total)*100;
	my $qual_prom_run=sprintf "%.2f", $suma_qual_prom/$reads_total;
	my $q20_percent=sprintf "%.2f", ($q20/$reads_total)*100;
	my $q30_percent=sprintf "%.2f", ($q30/$reads_total)*100;
	$file=~s/concat_//;
	$file=~s/_R1.fastq//;	

	print OUT "$file\t$reads_total\t$suma_bases\t$long_reads_prom\t$gc_percent\t$qual_prom_run\t$n_percent\t$q20_percent\t$q30_percent\n";
#	system("rm $file");

}

