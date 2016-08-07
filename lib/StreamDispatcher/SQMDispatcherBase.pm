use v6;

use StreamDispatcher::StreamDispatcherBase;
use SQM::Reader::SQMFragmentActions;
use SQM::Reader::SQMFragmentGrammar;

=begin pod
=TITLE StreamDispatcher::SQMDispatcherBase
=para Base class for as SAX-like event dispatcher for SQM input

=begin SYNOPSIS
=begin code
class MyClass is StreamDispatcher::SQMDispatcherBase {...}
my StreamBuffer $buffer .= new( :input($input)  ) ;

my MyClass $my-parser .=new( :stream-buffer( $buffer ) );
$my-parser.parse();
=end code
=end SYNOPSIS

=begin DESCRIPTION
This is the base class for as SAX-like event dispatcher for SQM handling. It extends 
L<StreamDispatcher::StreamDispatcherBase> by providing a methods for the following events:
=item class-begin
=item attrib
=item class-end
=item array-begin
=item array-elem
=item array-end
For each event a method of the form I<evp_the-event(%event-hash)> exists which transform
the hash input into 'name' and/or 'value' arguments and then call the event methods to be
overridden by descendant classes of the form I<event-name(...)>.
The method evp_closer yields to I<evp_class-end> and I<evp_array-end> according to the
stack  maintained by I<evp_class-begin> and I<evp_class-end>.
Normally I<evp_*> methods should not be overridden by descendant classes. All processing
should be done under the I<event-name> methods. 
=end DESCRIPTION

=end pod
=cut

class StreamDispatcher::SQMDispatcherBase is StreamDispatcher::StreamDispatcherBase {
	
	has Grammar $.stream-parser-grammar is rw = SQM::Reader::SQMFragmentGrammar;
	has $.stream-parser-actions is rw = SQM::Reader::SQMFragmentActions;	
	
	has Str $!begin-name;
	has Str $!begin-type;
	has Hash @!openStack;
	has %!popped;

	#inherited dispatch methods	
	method evp_attrib(%event-hash) { self.attrib( :name( %event-hash<name> ), :value( %event-hash<value> ) ) }
	
	method evp_class-begin(%event-hash) {
		my $h = {name => ~%event-hash<name>, type => 'class'};	
		@!openStack.push($h);	
		self.class-begin( :name( %event-hash<name> ) )	
	}
	
	method evp_array-begin(%event-hash) {
		my $h = {name => ~%event-hash<name>, type => 'array'};			
		@!openStack.push($h);	
		self.array-begin( :name( %event-hash<name> ) )	
	}
	
	method evp_array-elem(%event-hash) { self.array-elem( :value( %event-hash<value> ) ) }
	
	method evp_closer(%event-hash) {
		%!popped = @!openStack.pop;			
		self."evp_{%!popped<type>}-end"(%!popped);
	}
	
	method evp_class-end(%event-hash) { self.class-end( :name( %event-hash<name> ) ) }	
	
	method evp_array-end(%event-hash) {	self.array-end( :name( %event-hash<name> ) ) }	

	# empty methods for use by descendant classes
	method attrib(Str :$name, Str :$value) { }
	method class-begin(Str :$name) { }
	method array-begin(Str :$name) { }
	method array-elem(Str :$value) { }
	method class-end(Str :$name) { }	
	method array-end(Str :$name) { }
		
}