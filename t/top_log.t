# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib;
use Tk::Multi::Manager;
use Puppet::Log ;
$loaded = 1;
my $idx = 1;
print "ok ",$idx++,"\n";
my $trace = shift || 0 ;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict ;
my $mw = MainWindow-> new ;
$mw->withdraw ;

print "Creating orphan log window\n" if $trace ;
my $orphan = new Puppet::Log(title => 'orphan') ;

print "ok ",$idx++,"\n";

my $orphanb = new Puppet::Log(title => 'orphan2') ;

print "ok ",$idx++,"\n";

my $bmgr ;

$bmgr = $orphan -> display($mw) ;
$orphan -> log ("This log was not attached to an existing Multi::Manager and so created its own") ;
print "ok ",$idx++,"\n";

$orphanb -> display($bmgr) ;
$orphanb -> log ("This log was attached to the Multi::Manager created by the 'orphan' log") ;

print "ok ",$idx++,"\n";


MainLoop ; # Tk's

print "ok ",$idx++,"\n";


