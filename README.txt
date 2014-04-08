emeLSUcia is a software pipeline to perform the same
service as www.emerencia.org (Nilsson et al. 2005) as
implemented in Ryberg et al. (2009). The pipeline was
first used and published in Ryberg and Matheny (in press).

It works on any gene region but was designed for nucLSU
in fungi. It is a series of perl scripts and also need
BLAST (separate installation). First you need to download
the sequence region you are interested in from GenBank
in full GenBank format. For nucLSU this can be done by
the search string:

"fungi" [Organism] AND 500:3500 [SLEN] ("25S"[titl] OR 
"28S"[titl] OR "26S"[titl] OR "large subunit ribosomal
 RNA"[titl] OR "large-subunit ribosomal RNA"[titl] OR 
"lsu ribosomal RNA"[titl] OR "LSU ribosomal RNA"[titl]
 OR "ribosomal RNA large subunit"[titl]) NOT 
("intergenic spacer"[titl] OR "internal transcribed
 spacer"[titl] OR "internal transcribed spacers"[titl]
 OR "ITS"[titl] OR "ITS1"[titl] or "ITS2"[titl] OR 
"mitochondrial")

in combination with:

"fungi" [Organism] AND 1000:3500 [SLEN] ("25S"[titl] OR 
"28S"[titl] OR "26S"[titl] OR "large subunit ribosomal RNA"
[titl] OR "large-subunit ribosomal RNA"[titl] OR 
"lsu ribosomal RNA"[titl] OR "LSU ribosomal RNA"[titl] OR 
"ribosomal RNA large subunit"[titl]) NOT 
("intergenic spacer"[titl] OR "mitochondrial")

Then you can parse the downloaded files using:

---------------------------------------------------------------
perl gbparser.pl -s -n name_of_outfile -f your_sequence_file.gb
---------------------------------------------------------------

This will give you two files: 
name_of_outfile_FIS.fst
name_of_outfile_IIS.fst

The file ending with FIS.fst contain the fully identified
sequences (FIS) while the IIS.fst file contain the 
insufficiently identified sequences (IIS). gbparser.pl does
not overwrite old files with the same output name but only 
add new sequences to those files without warning. So make sure
each run has a separate name. If you started with more than one
GenBank file you can combine the separate fasta files for
each category using:

--------------------------------------------------------------
perl merge2fastafiles.pl file1.fst file2.fst > merged_file.fst
--------------------------------------------------------------

This will only add the sequences in file2.fst that are not
present in file1.fst (based on first word in sequence name,
which preferably should be the accession number).

Then you need to BLAST your IIS sequences against your FIS
sequences. BLAST and BLAST instructions can be downloaded from
http://www.ncbi.nlm.nih.gov/. If you are in the same folder as
formatdb (using BLAST 2.2.25) the database can be formated by:

------------------------------------------
./formatdb -i name_of_outfile_FIS.fst -p F
------------------------------------------

If you are in the same folder as blastall the BLAST search
can be performed using:

------------------------------------------------------
./blastall -p blastn -F F -d name_of_outfile_FIS.fst \
-i name_of_outfile_IIS.fst > nucLSU_BLAST.out
------------------------------------------------------

(the \ return is only for layout purposes and not needed). 
If you have merged files you should use them and not the 
files from gbparser.pl.

The BLAST results can then be queried using:

-------------------------------------------------------
perl BLASTparser.pl -g genus_name BLAST_output_file.txt
-------------------------------------------------------

This will give you the IIS (marked with Query=) with the query
genus as one of the five best BLAST matches, and the five best
matches.

***************************************************************
Nilsson RH, Kristiansson E, Ryberg M, Larsson KH. 2005. Approaching
    the taxonomic affiliation of unidentified sequences in public
    databases - an example from the mycorrhizal fungi. BMC
    Bioinformatics 6 (88).
Ryberg M, Matheny PB. in press. Asynchronous origins of ectomycorrhizal
    clades of Agaricales. Proceedings of the Royal Society B.
Ryberg M, Kristiansson E, Sjökvist E, Nilsson RH. 2009. An outlook
    on the fungal internal transcribed spacer sequences in GenBank
    and the introduction of a web-based tool for the exploration of
    fungal diversity. New Phytologist 181: 471-477

***************************************************************
Copyright (C) 2011 Martin Ryberg
