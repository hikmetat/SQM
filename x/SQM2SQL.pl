use v6;

=head1 SQM TO SQL CONVERTER
=head1 SYNOPSIS
=begin pod
	SQM2SQL.pl [--output-template=<Str>] [--query=<Str>] <input-file> <output-file> 
=end pod
=cut

# TODO: Generalize this
use lib 'D:\Users\Hikmet\workspace\SQM2SQL';		
use output-template;
use sqm-query;

sub MAIN(Str $input-file!, Str $output-file!, Str :$output-template!, Str :$query!) {
	
	# PRELIMINARIES
	# Attempt to open all input files and to create output. Die on failure
	die "Cannot locate or open Input SQM File '$input-file'" unless $input-file.IO ~~ :f;
	die "Cannot locate or open Output Template File '$output-template'" unless $output-template.IO ~~ :f;
	die "Cannot locate or open Query File '$query'" unless $query.IO ~~ :f;
	die "Cannot create Output File 'output-file'" unless my $out-fh = open $output-file, :w;
	
	# GET TEMPLATE
	# get uncommented text lump
	my Str $lines = uncommented-text($output-template);	
	# using the grammar of output-template parse the retrieved $lines string if there is a syntx eror die
	my $match = output-template.parse($lines);
	die "Output template '$output-template' didn't compile" unless ?$match;	
	
	# transfer template data to data-structures
	my %template-params = $match<params-statements><params-list><param>.map( { $_<param-name> => $_<param-value> } );
	my @begin-templates = $match<begin-statements><statement-list><statement>.map: {.Str};
	my @body-templates  = $match<body-statements><statement-list><statement>.map: {.Str};
	my @end-templates   = $match<end-statements><statement-list><statement>.map: {.Str};
		
	# GET QUERY
	# get uncommented text lump
	# using the grammar of output-template parse the retrieved $lines string if there is a syntx eror die
	$lines = uncommented-text($query);
	$match = sqm-query.parse($lines);
	die "Input query file '$query' didn't compile" unless ?$match;
	my %queries;
	for $match<command> -> $stmt {
		%queries{$stmt<query-field-name>.Str} = 
			{ value => $stmt<query-field-value>.Str, extractions => $stmt<extract-field-list><extract-field-name>.map( { $_.Str } ) }
	}

	
	# RUN QUERY
	my $in-fh = open $input-file, :r;
	
	
	# as each bracket opens increment level and as each brace closes decrement level
	# when a new class is found check its level adainst last class
	# if its higher 
	
	
	# close output
	close $out-fh;
}
sub uncommented-text(Str $file-name!) returns Str {
	# select non empty lines from template, then parsimoniously select anything before 
	# the first pound sign thus eliminating comments	
	return $file-name.IO.lines.map( { / \s* ( .*? ) [ \# | $ ] /; ~$0 }).join
}
sub die-tests (Bool %messages) {
	for %messages.kv -> $k, $v {die $k if $v}
}
