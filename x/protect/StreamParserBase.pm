use v6;

=begin pod
=TITLE StreamParserBase
=para Base class for as SAX-like stream processor

=begin SYNOPSIS
=begin code
class MyClass is StreamParserBase {...}
my StreamBuffer $buffer .= new( :input($input)  ) ;
my Grammar $grammar;
my $actions;

my MyClass $my-parser .=new( :stream-buffer( $buffer ), :stream-parser-grammar( $grammar ), :stream-parser-actions( $actions ) );
$my-parser.parse();
=end code
=end SYNOPSIS

=begin DESCRIPTION
This is the base class for as SAX-like stream processor. It uses a given L<StreamBuffer>
to provide a stream of lines and a I<Grammar> to analyse blocks of text constructed from this input. It needs to
be inherited by a subclass which implements the private method I<process()>.
=end DESCRIPTION

=begin METHOD 
=begin code
StreamParserBase-subclass.=new( :input( StreamBuffer $input ) )
=end code
I<new()> creates an instance of B<StreamParserBase>

B<Arguments:>
=item stream-buffer:	instantation of L<StreamBuffer> or derivative
=item stream-parser-grammar:	a grammar that returns a string key and string hash value
=item stream-parser-actions:	an action class to complement the grammar
=end METHOD

=begin METHOD 
=begin code
StreamParserBase-subclass.parse()
=end code
The method I<parse()> loops through lines provided by the L<stream-buffer> progressively concatenating the recieved
lines with previous lines in to a text "block" until a match is achieved with the "block" against the I<stream-parser-grammar>. 
The "key" returned by I<stream-parser-grammar> is identified as the "event" and together with the value
returned by I<stream-parser-grammar> and passed to I<process()> for processing.
Trailing unmatched text is returned to the L<stream-buffer> to be provided on the next iteration which will
re-start with a empty text "block".
Parsing stops when L<stream-buffer> can't provide any more lines of text and left-over text is returned.
B<Arguments:> None
=end METHOD

=begin METHOD
I<process()> is a private method stub of B<StreamParserBase> and must be implemented by a subclass.

B<Arguments:>
=item event:	name of event string
=item event-hash:	name/value pairs of data provided by the event
=end METHOD

=end pod
=cut


use lib $*PROGRAM.dirname;
use StreamBuffer;

class StreamParserBase {
	
	has StreamBuffer $.stream-buffer is rw;		
	has Grammar $.stream-parser-grammar is rw;
	has $.stream-parser-actions is rw;
		
	method parse() {
		# loop through input lines
		my %began;
		while True {
			
			# reset loop variables:
			my Str ( $block, $event, $line ) = ('', '', '');
			
			# Concat line to existing block of text and try to get a match. Continue until success
			my $match;
			while ( !$match ) {
				# if there is no match but non-white-space is leftover then return the leftover with but false
				$line = $!stream-buffer.get;
				return ($block ~~ /\S/ ?? $block but False !! '' but True) if !$line; 
				# append line to block and try match
				$block ~= $line;
				$match = $.stream-parser-grammar.subparse( $block, :actions( $.stream-parser-actions ) );
			}
			
			# return the trailing part of the match
			$!stream-buffer.unget( $block.substr( $match.to ) );
			# call process method on grammar match data
			self.process( $match.made.key, $match.made.value );
			
		}
	}	

	method process( Str $event, %event-hash ) {...}	
}