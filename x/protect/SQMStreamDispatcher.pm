use v6;

use lib $*PROGRAM.dirname;
use StreamDispatcher;
use SQMReaderActions;
use SQMReaderGrammar;

=begin pod
=TITLE SQMStreamDispatcher
=para Base class for as SAX-like event dispatcher for SQM input

=begin SYNOPSIS
=begin code
class MyClass is StreamDispatcher {...}
my StreamBuffer $buffer .= new( :input($input)  ) ;
my Grammar $grammar;
my $actions;

my MyClass $my-parser .=new( :stream-buffer( $buffer ), :stream-parser-grammar( $grammar ), :stream-parser-actions( $actions ) );
$my-parser.parse();
=end code
=end SYNOPSIS

=begin DESCRIPTION
This is the base class for as SAX-like event dispatcher. It extends L<StreamParserBase>
by providing a I<process()> method which dispatches calls to methods with names derived from I<event>
by a prefix. It doesn't provide these methods which must be provided by a derived class.
It also provides an empty FALLBACK method for unimplemented event calls which may be extended
by descendant classes
=end DESCRIPTION

=end pod
=cut

class SQMStreamDispatcher is StreamDispatcher {
	
	has Grammar $.stream-parser-grammar is rw = SQMReaderGrammar;
	has $.stream-parser-actions is rw = SQMReaderActions;	
	
	has Str $!begin-name;
	has Str $!begin-type;
	has Hash @!openStack;
	has %!popped;

	
	method evp_attrib(%event-hash) {
		say sprintf("%-20s%-35s%-1000s", 'Attribute', 'Name=' ~ %event-hash<name>, 'Value=' ~ %event-hash<value>);
	}
	method evp_class-begin(%event-hash) {
		say sprintf("%-20s%-35s%-1000s", 'Class Begin', 'Name=' ~ %event-hash<name>, '');
		my $h = {name => ~%event-hash<name>, type => 'class'};	
		@!openStack.push($h);		
	}
	method evp_array-begin(%event-hash) {
		say sprintf("%-20s%-35s%-1000s", 'Array Begin', 'Name=' ~ %event-hash<name>, '');
		my $h = {name => ~%event-hash<name>, type => 'array'};			
		@!openStack.push($h);		
	}
	method evp_array-elem(%event-hash) {
		say sprintf("%-20s%-35s%-1000s", 'Array Elem', '', 'Value=' ~ %event-hash<value>);
	}
	method evp_closer(%event-hash) {
		%!popped = @!openStack.pop;			
		self."evp_{%!popped<type>}-end"(%event-hash);
	}
	method evp_class-end(%event-hash) {
		say sprintf("%-20s%-35s%-1000s", 'Class End', 'Name=' ~ %!popped<name>, '');
	}	
	method evp_array-end(%event-hash) {	
		say sprintf("%-20s%-35s%-1000s", 'Array End', 'Name=' ~ %!popped<name>, '');
	}	
}