# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..13\n"; }
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
my $toto ;
my $mw = MainWindow-> new ;

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );

my $spe = $mw->Frame -> pack ;
$spe -> Button (text => 'add', 
                command => sub {$toto -> insertText("added\n")} ) 
  -> pack (side => 'left') ;

print "creating manager\n" if $trace;
my $wmgr = $mw -> MultiManager ( 'title' => 'log test' , 'menu' => $w_menu ) 
  -> pack (expand => 1, fill => 'both');

print "ok ",$idx++,"\n";

print "Creating new log\n" if $trace ;
my $log = new Puppet::Log('log test', fullName => 'big test') ;

print "ok ",$idx++,"\n";

print "inserting some text in log\n" if $trace ;
$log -> log("This text was logged but not printed") ;
$log -> log("This text was logged and printed",'whenNoDisplay' => 'print') 
  if $trace ;
$log -> log("This text was also logged and warned" ,
            'whenNoDisplay' => 'print') if $trace ;

print "ok ",$idx++,"\n";

print "requiring display on log\n" if $trace ;
$log ->display($wmgr, 1) ;
$log -> log("This text was also logged after display was created" ,
            'whenNoDisplay' => 'print') ;

print "ok ",$idx++,"\n";

print "Creating new log2\n"  if $trace ;
my $log2 = new Puppet::Log('log2 test','help' => 'log2 dummy help') ;

print "ok ",$idx++,"\n";

print "inserting some text in log2\n" if $trace ;
$log2 -> log("This text was logged but not printed") ;

print "ok ",$idx++,"\n";

print "requiring display on log\n" if $trace ;
$log2 ->display($wmgr,1) ;
$f->command(-label => 'show log2',  -command => sub{$log2->show();} );

print "ok ",$idx++,"\n";

print "Creating sub window toto\n" if $trace ;
$toto = $wmgr -> newSlave('type'=>'MultiText', title => 'toto',
                         'help' => 'dummy help for toto') ;

print "ok ",$idx++,"\n";

print "Creating orphan log window\n" if $trace ;
my $orphan = new Puppet::Log('orphan') ;
$orphan -> log ("poor guy") ;

print "ok ",$idx++,"\n";

my $orphanb = new Puppet::Log('orphan2') ;
$orphanb -> log ("poor brother") ;

print "ok ",$idx++,"\n";

$spe -> Button (text => 'recall orphan log', 
                 command => sub {$orphan -> display($mw) ;} ) 
  -> pack (side => 'left');
$spe -> Button (text => 'recall orphan brother', 
                 command => sub {$orphanb -> display($mw) ;} ) 
  -> pack (side => 'left');

my $bmgr = $orphan -> display($mw) ;
$orphanb -> display($bmgr) ;

print "ok ",$idx++,"\n";

$f->command(-label => 'Quit',  -command => sub{$mw->destroy;} );

MainLoop ; # Tk's

print "ok ",$idx++,"\n";


