use warnings;
use strict;

my ($input_filename, $output_filename) = @ARGV;
my @output;
open (INPUT, "<", $input_filename) or die "Could not open $input_filename!!";
foreach my $line (<INPUT>){
  if ($line =~m/^[a]/){
    $line =~s/\w+\://;
    $line =~s/\n/\t/;
    push (@output, $line);
    print "$line\n";
  }elsif ($line =~m/^[r]/){
    $line =~s/\w+\://;
    push (@output, $line);
    print "$line\n";
  }else{
    $line =~s/\t\:(\d{1,3})\.\w\@\w\w\s(.*)/$1\t$2/;
    push (@output, $line);
    print "$line\n";
  }
}

open (OUTPUT, ">", $output_filename) or die "Could not open $output_filename!!";
print OUTPUT @output;
