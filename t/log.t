# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..10\n"; }
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

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );

$f->command(-label => 'Quit',  -command => sub{$mw->destroy;} );

print "creating manager\n" if $trace;
my $wmgr = $mw -> MultiManager ( 'title' => 'log test' , 'menu' => $w_menu ) 
  -> pack (expand => 1, fill => 'both');

print "ok ",$idx++,"\n";

print "Creating new log\n" if $trace ;
my $log = new Puppet::Log('title' =>'log test', fullName => 'big test') ;

print "ok ",$idx++,"\n";

print "inserting some text in log\n" if $trace ;
$log -> log("This text was logged but not printed") ;
$log -> log("This text was logged and printed",'how' => 'print') 
  if $trace ;
$log -> log("This text was also logged and warned" ,
            'how' => 'warn') ;

print "ok ",$idx++,"\n";

print "requiring display on log\n" if $trace ;
$log ->display($wmgr, 1) ;
$log -> log("\nYou may display the 2nd log with menu: 'log test'->'log2 test'->show");

print "ok ",$idx++,"\n";

print "calling show on log\n" if $trace ;
$log ->show();
print "ok ",$idx++,"\n";

print "Creating new log2\n"  if $trace ;
my $log2 = new Puppet::Log('title' =>'log2 test','help' => 'log2 dummy help') ;

print "ok ",$idx++,"\n";

print "inserting some text in log2\n" if $trace ;
$log2 -> log("This text was also logged but not printed") ;

print "ok ",$idx++,"\n";

print "requiring display on log\n" if $trace ;
$log2 ->display($wmgr,1) ;

print "ok ",$idx++,"\n";


MainLoop ; # Tk's

print "ok ",$idx++,"\n";


