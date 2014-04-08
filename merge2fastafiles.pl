#!/usr/bin/perl -w

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

open FILE, "$ARGV[0]" or die;
chomp(my @file1 = <FILE>);
close FILE or die;

open FILE, "$ARGV[1]" or die;
chomp(my @file2=<FILE>);
close FILE or die;

### Reading the accnos that are already pressent
my $i=0;
my @oldaccnos;
foreach (@file1) { if ($_=~ /^>([A-Za-z0-9]+)/) { $oldaccnos[$i++]=$1; }; print "$_\n"; }

my $j=0;
my $k=0;


for ($i=0; $i<scalar @file2; $i++) { 
   if ($file2[$i] =~ /^>([A-Za-z0-9]+)/) {
      for ($k=0; $k< scalar @oldaccnos; $k++) {
         if ($1 eq $oldaccnos[$k]) {last;} ### If the accno is already present proceed without any output
         elsif ($k == (scalar @oldaccnos -1)) { ### if not even the last accno in the old file was the same as the downloaded it must be a new one
            print "$file2[$i]\n";   ### printing the title of the sequence
            for ($j=$i+1; $j<scalar @file2; $j++) { ### starting from the row below the sequence title print the sequence
               if ($file2[$j]=~ /^>/) { last; }  ### stop printing the sequence if you have got to the next sequence
               else {
                  print "$file2[$j]\n";  ### print the sequence
               }
            }
         }
      }
   }
}


exit;
