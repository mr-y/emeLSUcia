#! /user/bin/perl -w

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

my $querysequence='empty';
my $i=0;
my @accno;
my @species;
my @evalue;
my @score;
my $infile= pop (@ARGV); #treat last argument as file name
my $searchgenus;

for (my $i=0; $i < scalar @ARGV; $i++) {

   if ($ARGV[$i] eq "-g") {$searchgenus=$ARGV[++$i];}

}


open INFILE, "$infile" or die;
while (<INFILE>) {
#   if ($_=~ /^Reference: Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer/) {$querysequence='empty'; $i=0; for (my $j=0; $j< scalar @accno; $j++) {$accno[$j]=""; $species[$j]=""}}
   if ($_=~ /Query= (.+)/) { $querysequence=$1; }
   elsif ($_=~ /^Sequences producing significant alignments/) {$i=1;}
   elsif ($i>0 and $i<6 and $_=~ /^([A-Za-z0-9]+)_(.+)/) {$accno[$i-1]=$1; $species[$i-1]=$2; $i++;}
      
   elsif ($_=~ /^>/ and $species[0] =~ /^$searchgenus/) {
      print "Query= $querysequence\n"; 
      for (my $j=0; $j< scalar @accno; $j++) {print "\t$accno[$j] $species[$j]\n";}
      $querysequence='empty'; $i=0; for (my $j=0; $j< scalar @accno; $j++) {$accno[$j]=""; $species[$j]=""}
   }
   else {next;}
}
close INFILE or die;

