#! /local/bin/perl -w

#########################################################################
# Copyright (C) 2011 Martin Ryberg                                      #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#                                                                       #
# contact: kryberg@utk.edu                                              #
#########################################################################

use strict;

my $locus;
my $definition;
my $accession;
my $version;
my $keywords;
my $source;
my $organism;
my @reference;
my @authors;
my @title;
my @journal;

### FEATURES ###
my @source;
my %source;
my @gene;
my %gene;
my @rRNA;
my %rRNA;
my @mRNA;
my %mRNA;
my $origin;
my @cds;
my %cds;

my $sequence;

my $searchstring;
my $searchfield;
my $outfile= "outfile";
my $separateIISandFIS="no";
my @infile;
my $IDstatus;

### If several arguments are given each have to be specified ###
if (scalar @ARGV>1) {

   for (my $i=0; $i<scalar @ARGV; $i++) {

### if searching for specific organism ###
      if ($ARGV[$i] eq "-o") {$searchfield="organism"; $searchstring="$ARGV[++$i]";}

### read base name for output
      if ($ARGV[$i] eq "-n") {$outfile=$ARGV[++$i];}

### If separating IIS and FIS give -separate
      if ($ARGV[$i] eq "-s") {$separateIISandFIS="yes";}

### infile(s) should be preseded by -f ###   
      elsif ($ARGV[$i] eq "-f") {
         if (@infile) { ### if already read one infile just catenate the next to it
               open INFILE, $ARGV[++$i] or die;
               chomp(@infile = (@infile,<INFILE>));
               close INFILE or die;
         }
         else {
            open INFILE, $ARGV[++$i] or die;
            chomp(@infile=<INFILE>);
            close INFILE or die;

        }
      }
   }
}

### if only one argument is given it is treted as an infile ###
else {
   open INFILE, $ARGV[-1] or die;
   chomp(@infile=<INFILE>);
   close INFILE or die;
}

### begin parsing infile(s) ###
for (my $i=0; $i<scalar @infile; $i++) {
#   print "parsing line $i...  ";
   if ($infile[$i]=~ /^LOCUS\s+(.+)/) {$locus=$1;}
   elsif ($infile[$i]=~ /^DEFINITION\s+(.+)/) {
      $definition=$1;
      while (!($infile[$i+1]=~ /^[A-Z]/)) {  ### Could be several rows
         $i++;
         $infile[$i]=~ s/^\s*//;
         $definition.= "\n$infile[$i]";
         }
      }
   elsif ($infile[$i]=~ /^ACCESSION\s+(.+)/) {$accession=$1;}
   elsif ($infile[$i]=~ /^VERSION\s+(.+)/) {$version=$1;}
   elsif ($infile[$i]=~ /^KEYWORDS\s+(.+)/) {$keywords=$1;}
   elsif ($infile[$i]=~ /^SOURCE\s+(.+)/) {$source=$1;}
   elsif ($infile[$i]=~ /^\s.ORGANISM\s+(.+)/) {
      $organism="$1\n";
      while (!($infile[$i+1]=~ /^[A-Z]/)) { ### Could be several rows
         $i++;
         $infile[$i]=~ s/^\s*//;
         $organism.= "$infile[$i] ";
         }
      }
### should pars references here ###

   elsif ($infile[$i]=~ /^FEATURES/) { ### trying to separate the different features
      @source="";
      %source=("","");
      my $source=0;
      @gene="";
      %gene=("","");
      my $gene=0;
      @rRNA="";
      %rRNA=("","");
      my $rRNA=0;
      @mRNA="";
      %mRNA=("","");
      my $mRNA=0;
      @cds="";
      %cds=("","");
      my $cds=0;

      while (!($infile[$i+1]=~ /^[A-Z]/)) { ### Capital character at beginning of row means the ORIGIN field starts and the FEATURES must have ended
         $i++;
         if ($infile[$i]=~ /^\s+source\s+(.+)/) {
            $source[$source]=$1;
            while ($infile[$i+1]=~ m{^\s+/(\w+)=(.+)}) {
               $i++;
               $source{$1}= $2;

            }
            $source++; 
         }
      }
   }

   elsif ($infile[$i]=~ /^ORIGIN/) { ### get the sequence
      $sequence='';
      while ($infile[++$i]=~ /[A-Za-z]/) {

         $sequence.= $infile[$i];

      }
      $sequence=~ s/[^A-Za-z]//g;
      $i--;
   }

   elsif ($infile[$i]=~ m|^//|) { ### end of sequence entery, time to wrap things up
      $organism=~ /^(.+)\n/;
      my $species=$1; ### getting just species from the organism field
      $IDstatus= idstatus($species, $definition); ### is it a IIS or FIS according to the emerencia criterias

      if (defined($searchfield)) { ### if searching for a particular organism os given by -o
         if ($searchfield eq "organism") {
            if ($organism=~ /$searchstring/) { ### not tested but this should mean that one can search for eg cortinariaceae, sensitive for capital letters
               print "$locus\n$definition\n"; ### should probably put in a function for what format one want. Here key information are given.
               foreach (keys %source) {
                  if (defined($_) and $_=~ /(strain|specimen_voucher)/) {
                     print "$1 = $source{$_}\n";
                  }
               }
            print "---------\n"; ### Part the different enteries
            }
         }
      }
      else { ### if not looking for particular organism, giving fasta format
         if ($separateIISandFIS eq "yes") {
            if ($IDstatus eq "I") {
              open OUTFILE, ">>$outfile\_FIS.fst" or die;
              &printfasta("$accession\_$species", $sequence);
              close OUTFILE or die;
            }
            if ($IDstatus eq "U") {    
              open OUTFILE, ">>$outfile\_IIS.fst" or die;
              &printfasta("$accession\_$species", $sequence);
              close OUTFILE or die;
            }
         }
         else {
            open OUTFILE, ">>$outfile.fst" or die;
            &printfasta("$accession\_$species", $sequence);
            close OUTFILE or die;
            }
      }
   }

}

if ($searchfield) {print "Search made in the \"$searchfield\" field looking for \"$searchstring\"";}
print "\n";

sub printfasta {
   my $title=$_[0];
   my $sequence=$_[1];
   $title=~ s/\s/_/g;
   print OUTFILE ">$title\n$sequence\n\n";
}

### Sub to determin if the sequence is ID or UID, much of the code is from the emerencia script ###

sub idstatus {

    my $species=$_[0];
    my $annotation=$_[1];
    my $IDstatus;

    if (($species =~ / f\. sp\./) or ($species =~ / f\.sp\./)) { $IDstatus='I'; } # formae specialis = ID
   
    elsif (($species =~ /sp\. nov\./) or ($species =~ /sp\.nov\./)) { $IDstatus='I'; } # new species = ID

    elsif (($species =~ /basidiomycete/i) or ($species =~ /ascomycete/i) or ($species=~/zygomycete/i)) { $IDstatus='U'; }  # UID

    elsif (($species =~ / sp\./) or ($species=~/ cf\./) or ($species =~ / spp\./) or ($species =~ / aff\./)) { $IDstatus='U'; } # UID

    elsif (($annotation =~ /unidentified/i) or ($species =~ /unidentified/i)) {  $IDstatus='U'; }  # UID

    elsif (($annotation =~ /uncultured/i) or ($species =~ /uncultured/i)) { $IDstatus='U'; } # UID

    elsif (($species=~/antarctic yeast/i) or ($species=~/^cf\. /i)) { $IDstatus='U'; } # UID

    elsif (($species=~/mycorrhizal/i) or ($annotation =~ /mycorrhizal/i)) { $IDstatus='U'; } # UID

    elsif (($species=~/mycorrhizae/i) or ($species=~/vouchered/)) { $IDstatus='U'; } # UID

    elsif (($species=~/ complex /) or ($species=~/ group /) or ($species=~/s\.l\./)) { $IDstatus='U'; } # UID

    elsif (($species=~/Ascomycota/) or ($species =~ /Basidiomycota/)) { $IDstatus='U'; } # UID

    elsif (($species=~/symbiont/i) or ($species =~/ genogroup /) or ($species=~/epistomatal fungus/i)) { $IDstatus='U'; } # UID

    elsif (($species=~/endophyte /i) or ($species=~/ endophyte\./i)) { $IDstatus='U'; } # UID

    elsif (($species=~/coelomycete /i) or ($species=~/coelomycete\./i)) { $IDstatus='U'; } # UID

    elsif (($species =~ /fungal/i) or ($annotation=~/fungal/i)) { $IDstatus='U'; } # UID

    elsif (($species =~ /axenic/i) and ($species=~ /isolate/i)) { $IDstatus='U'; } # UID

    elsif (($species =~ /vouchered/i)) { $IDstatus='U'; } # UID

    elsif (($species =~ /^aff./)) { $IDstatus='U'; } # UID NEW November 2007

    elsif (($species =~ /beech leaf/)) { $IDstatus='U'; } # UID NEW November 2007

    elsif (($species =~ /sensu lato/)) { $IDstatus='U'; } # UID NEW November 2007

    elsif (($species =~ /Termitomyces DKA/)) { $IDstatus='U'; } # UID NEW November 2007

    elsif (($species =~ / root /i) or ($species=~/XK\-2005/) or ($species=~ / isolate /)) { $IDstatus='U'; } # UID

    elsif (($species =~ /yeast isolate/i) or ($species=~/ericoid/i)) { $IDstatus='U'; } # UID

    elsif (($species =~ /mycorrhiza of/i) or ($species=~/myrocchiza on/i)) { $IDstatus='U'; } # UID

    elsif (($species =~ /thelephoralean/i) or ($species=~/thelephoraceous/i)) { $IDstatus='U'; } # UID

    elsif (($species =~ /aphyllophoralean/i) or ($species=~/cortinariaceous/i)) { $IDstatus='U'; } # UID

    elsif (($species =~ /sebacinaceous/i) or ($species=~/cantharelloid/i)) { $IDstatus='U'; } # UID

    else { $IDstatus='I'; }   # passed all tests, therefore assumed to be fully identified ID

    return $IDstatus;


}
