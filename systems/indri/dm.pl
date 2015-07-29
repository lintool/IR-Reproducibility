#!/usr/bin/perl

#
# Perl subroutine that generates Indri dependence model queries.
#
# Written by: Don Metzler (metzler@cs.umass.edu)
# Last updated: 06/27/2005
#
# Feel free to distribute, edit, modify, or mangle this code as you see fit. If you make any interesting
# changes please email me a copy.
#
# For more technical details, see:
#
#    * Metzler, D. and Croft, W.B., "A Markov Random Field Model for Term Dependencies," ACM SIGIR 2005.
#
#    * Metzler, D., Strohman T., Turtle H., and Croft, W.B., "Indri at TREC 2004: Terabyte Track", TREC 2004.
#
#    * http://ciir.cs.umass.edu/~metzler/
#
# NOTES
#
#    * this script assumes that the query string has already been parsed and that all characters
#      that are not compatible with Indri's query language have been removed.
#
#    * it is not advisable to do a 'full dependence' variant on long strings because of the exponential
#      number of terms that will result. it is suggested that the 'sequential dependence' variant be
#      used for long strings. either that, or split up long strings into smaller cohesive chunks and
#      apply the 'full dependence' variant to each of the chunks.
#
#    * the unordered features use a window size of 4 * number of terms within the phrase. this has been
#      found to work well across a wide range of collections and topics. however, this may need to be
#      modified on an individual basis.
#

# example usage
#print formulate_query( "white house rose garden", "sd", 0.5, 0.25, 0.25 ) . "\n\n";
#print formulate_query( "white house rose garden", "fd", 0.8, 0.1, 0.1 ) . "\n\n";

my $file = $ARGV[0];
open my $info, $file or die "Could not open $file: $!";

while( my $line = <$info>)  {   
    print formulate_query( $line, "sd", 0.7, 0.2, 0.1 ) . "\n";   
    #last if $. == 2;
}

close $info;

#
# formulates a query based on query text and feature weights
#
# arguments:
#    * query - string containing original query terms separated by spaces
#    * type  - string. "sd" for sequential dependence or "fd" for full dependence variant. defaults to "fd".
#    * wt[0] - weight assigned to term features
#    * wt[1] - weight assigned to ordered (#1) features
#    * wt[2] - weight assigned to unordered (#uw) features
#
sub formulate_query {
    my ( $q, $type, @wt ) = @_;

    # trim whitespace from beginning and end of query string
    $q =~ s/^\s+|\s+$//g;
    
    my $queryT = "#combine( ";
    my $queryO = "#combine(";
    my $queryU = "#combine(";
    
    # generate term features (f_T)
    my @terms = split(/\s+/ , $q);
    my $term;
    foreach $term ( @terms ) {
	$queryT .= "$term ";
    }

    my $num_terms = @terms;
    
    # skip the rest of the processing if we're just
    # interested in term features or if we only have 1 term
    if( ( $wt[1] == 0.0 && $wt[2] == 0.0 ) || $num_terms == 1 ) {
	return $queryT . ")";
    }
    
    # generate the rest of the features
    my $start = 1;
    if( $type eq "sd" ) { $start = 3; }
    for( my $i = $start ; $i < 2 ** $num_terms ; $i++ ) {
	my $bin = unpack("B*", pack("N", $i)); # create binary representation of i
	my $num_extracted = 0;
	my $extracted_terms = "";

	# get query terms corresponding to 'on' bits
	for( my $j = 0 ; $j < $num_terms ; $j++ ) {
	    my $bit = substr($bin, $j - $num_terms, 1);
	    if( $bit eq "1" ) {
		$extracted_terms .= "$terms[$j] ";
		$num_extracted++;
	    }
	}
	
	if( $num_extracted == 1 ) { next; } # skip these, since we already took care of the term features...
	if( $bin =~ /^0+11+[^1]*$/ ) { # words in contiguous phrase, ordered features (f_O)
	    $queryO .= " #1( $extracted_terms) ";
	}
	$queryU .= " #uw" . 4*$num_extracted . "( $extracted_terms) "; # every subset of terms, unordered features (f_U)
	if( $type eq "sd" ) { $i *= 2; $i--; }
    }

    my $query = "#weight(";
    if( $wt[0] != 0.0 && $queryT ne "#combine( " ) { $query .= " $wt[0] $queryT)"; }
    if( $wt[1] != 0.0 && $queryO ne "#combine(" ) { $query .= " $wt[1] $queryO)"; }
    if( $wt[2] != 0.0 && $queryU ne "#combine(" ) { $query .= " $wt[2] $queryU)"; }

    if( $query eq "#weight(" ) { return ""; } # return "" if we couldn't formulate anything
    
    return $query . " )";
}
