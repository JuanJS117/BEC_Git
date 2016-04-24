use warnings;
use strict;

unless ($ARGV[0] and $ARGV[1] and $ARGV[2]){
  &usage();
  exit;
}

my $PDBfile; my $RTFfile; my $PQRfile;
# First of all, we store every file (given as an argument in any order) into corresponding variable.
foreach my $file (@ARGV){
  if ($file =~m/.*\.pdb/){
    $PDBfile = $file;
    #print "$PDBfile\n";
  }elsif ($file =~m/.*\.rtf/){
    $RTFfile = $file;
    #print "$RTFfile\n";
  }elsif ($file =~m/.*\.pqr/){
    $PQRfile = $file;
    #print "$PQRfile\n";
  }else{
    print "\nYou have submitted some file/s with an incorrect extension.\n";
    print "Please try again.\n\n";
    exit;
  }
}

&test_files($PDBfile, $RTFfile, $PQRfile);

my @PDBlines; my @RTFlines; my @ATOM_rtflines;

foreach my $file (($PDBfile,$RTFfile)){
  if ($file =~m/.*\.pdb/){
    @PDBlines = &open_file($file);
  }elsif ($file =~m/.*\.rtf/){
    @RTFlines = &open_file($file);
    foreach my $line (@RTFlines){
      if ($line =~m/^ATOM/){
        push (@ATOM_rtflines, $line);
        #print "$line\n\n";
      }
    }
  }
}

my $counter = 0;
my $second_counter = -1;
for (my $i = 0; $i < scalar(@PDBlines); $i++){
  if ($PDBlines[$i] =~m/^(ATOM)|(HETATM)/){
    $second_counter = $second_counter + 1;
    my $charge = &get_charges($ATOM_rtflines[$i-$counter+$second_counter]);
    #print "$charge\n";
    my $VdWradius = &get_VdWradius($ATOM_rtflines[$i-$counter+$second_counter]);
    #print "$VdWradius\n";
    $PDBlines[$i] =~s/([ATOM|HETATM]+\s+\d+\s+\w*\d*\s+\w{1,3}\s+\w+\s+\d+\s+)(\-?\d+\.\d+\s+\-?\d+\.\d+\s+\-?\d+\.\d+\s+)(\d+\.\d+\s+)(\d+\.\d+\s+)(\w{1,3})/$1$2$charge  $VdWradius\t\t$5/;
    #print "$PDBlines[$i]\n";
  }
  $counter = $counter + 1;
}

open (my $OUTPUT, '>', $PQRfile) or die "Could not open $PQRfile to write on it!!\n";
my $date = `date`;
print $OUTPUT "REMARK\tPQR FILE CREATED BY JuanJS - $date";
foreach my $line (@PDBlines){
  print $OUTPUT $line;
  #print "$line\n";
}
close $OUTPUT;



sub usage {
  print "\n\nYou need to supply 3 file names in order to run this program:\n";
  print "\t1- A PDB file, containing the molecule coordinates.\n";
  print "\t2- A RTF file, containing the charges of the molecule.\n";
  print "\t3- A PQR file, in which charges and coordinates will be stored.\n\n";
  print "To call the program from the terminal, type:\n";
  print "\t\"perl FFC-PDBtoPQR.pl file.pdb file.rtf output.pqr\"\n";
  print "You may submit the files in any order.\n\n";
}

sub test_files {
  my ($PDBfile, $RTFfile, $PQRfile) = @_;
  unless ($PDBfile and $RTFfile and $PQRfile){
    print "\n\nYou may have forgotten to submit any file, and submitted another twice.\n";
    print "Please try again.\n";
    exit;
  }
}

sub open_file {
  my ($file) = @_;
  open (LINES, $file) or die "Could not open $file!!\n";
  my @lines = <LINES>;
  close LINES;

  return @lines;
}

sub get_charges {
  my ($line) = @_;
  my $charge;
  if ($line =~m/ATOM\s\w+\s+\w+\=?\w+\s+(\-?\d+\.\d+)/){
    $charge = $1;
  }

  if ($charge !~m/^\-/){
    $charge = " ".$charge;
  }

  return $charge;
}

sub get_VdWradius {
  my ($line) = @_;
  my $VdW_radius; my $atom_type;
  if ($line =~m/ATOM\s\w+\s+(\w+\=?\w+)\s+(\-?\d+\.\d+)/){
    $atom_type = $1;
    #print "$atom_type\n";
  }


  my @SP3_Carbons = ("CIM+", "CR", "CR3R");

  my @SP2_HCarbons = ("C5", "CNN+", "C=C","CSP2","C5A", "C5B", "C=O", "C=N",							"CGD", "C=OR",							"C=ON", "COO",							"COON", "C=OS",							"C=S", "C=SN",							"CSO2", "CS=O",							"CSS", "C=P",							"CB"			   );

  my @SP2_Carbons = ("CONN", "CGD+", "COOO", "CSP", "=C=", "C%", "CO2M");

  my @Nitrogens = (
          "N5", "N5M",							"NR+", "=N=",			  "NRP", "NPD+",							"N5A", "N5B",							"N2OX", "N3OX",							"NPOX", "NIM+",							"N5A+", "N5B+",							"N5+", "N5AX",							"N5BX", "N5OX",							"NR", "N=C",							"N=N", "NC=O",							"NC=S", "NN=C",							"NN=N", "NPYD",		          "NPYL", "NC=C",		          "NC=N", "NC=P",		          'NC%C',		          "NSP", "NSO2",		          "NSO3", "NPO2",		          "NPO3",		          'NC%N',		          "NO2", "NO3",		          "N=O", "NAZT",		          "NSO", "N+=C",		          "N+=N", "NCN+",		          "NGD+", "NPD+",		          "NR%", "NM"		   );

  my @SP2_Oxigens = (
					"O=+", "OC=O",							"OC=C", "OC=N",							"OC=S", "ONO2",							"ON=O", "OSO",							"OPO", "O=C",							"O=CN", "O=CR",							"O=CO", "O=N",							"O=S", "O=S="	  );

  my @SP3_Oxigens = (
  				"O+", "OR",	"OMMM",		 					"OSO3", "OSO2",							"OS=O", "-OS",		          "OPO3", "OPO2",		          "-OP", "-O-",							"OFUR", "OH2",							"O2CM", "OXN",							"O2N", "O2NO",							"O3N", "O-S",							"O2S", "O3S",							"O4S", "OSMS",							"OP", "O2P",							"O3P", "O4P",							"O4CL", "OM",			 					"OM2"       );

  my @SP3_Sulfurs = (
  	  "STHI", "=S=O",		          "S-P", "S2CM",			  "SM", "SSMO",			  "SO2M", "SSOM",     		          "S", "S=C",		          "S=O", "SO2",		          "SO2N", "SO3",		          "SO4", "=SO2",		          "SNO", "SI"			    );

  my @C_Hydrogens = (
      "HC","HCMM"
  );

  my @Hydrogens = (
          "HO+", "HO=+",			  "HS", "HS=N",			  "HP", "HOS",		           "HSI",		          "HOR", "HO",			            "HOM", "HNR",		          "H3N", "HPYL",		          "HNOX", "HNM",		          "HN", "HOCO",		          "HOP", "HN=N",		          "HN=C", "HNCO",		          "HNCS", "HNCC",		          "HNCN", "HNNC",		          "HNNN", "HNSO",		          "HNPO", "HNC%",		          "HSP2", "HOCC",		          "HOCN", "HOH",		          "HNR+", "HIM+",		          "HPD+", "HNN+",		          "HNC+", "HGD+",		          "HN5+", "HO+",		          "HO=+", "HS",			            "HS=N", "HP",
  );

  my @Phosphorus = (
	  "PO4", "P"
  );

  foreach my $type (@SP3_Carbons){
    if ($type eq $atom_type){
      $VdW_radius = 2.175;
      #print "$VdW_radius\n";
      last;
    }
  }

  foreach my $type (@SP2_HCarbons){
    if ($type eq $atom_type){
      $VdW_radius = 2.00;
      $VdW_radius = $VdW_radius."\t\t";
      #print "$VdW_radius\n";
      last;
    }
  }

  foreach my $type (@SP2_Carbons){
    if ($type eq $atom_type){
      $VdW_radius = 1.9924;
      #print "$VdW_radius\n";
      last;
    }
  }

  foreach my $type (@SP3_Sulfurs){
    if ($type eq $atom_type){
      $VdW_radius = 2.00;
      $VdW_radius = $VdW_radius."\t";
      #print "$VdW_radius\n";
      last;
    }
  }

  foreach my $type (@SP3_Oxigens){
    if ($type eq $atom_type){
      $VdW_radius = 1.77;
      $VdW_radius = $VdW_radius."\t";
      #print "$VdW_radius\n";
      last;
    }
  }

  foreach my $type (@SP2_Oxigens){
    if ($type eq $atom_type){
      $VdW_radius = 1.7;
      $VdW_radius = $VdW_radius."\t";
      #print "$VdW_radius\n";
      last;
    }
  }

  foreach my $type (@Nitrogens){
    if ($type eq $atom_type){
      $VdW_radius = 1.85;
      $VdW_radius = $VdW_radius."\t";
      #print "$VdW_radius\n";
      last;
    }
  }

  foreach my $type (@Phosphorus){
    if ($type eq $atom_type){
      $VdW_radius = 2.15;
      $VdW_radius = $VdW_radius."\t";
      #print "$VdW_radius\n";
      last;
    }
  }

  foreach my $type (@Hydrogens){
    if ($type eq $atom_type){
      $VdW_radius = 0.2245;
      #print "$VdW_radius\n";
      last;
    }
  }

  foreach my $type (@C_Hydrogens){
    if ($type eq $atom_type){
      $VdW_radius = 1.35;
      $VdW_radius = $VdW_radius."\t";
      #print "$VdW_radius\n";
      last;
    }
  }


  return $VdW_radius;
}
