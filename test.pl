# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib;
use Tk::Multi::Manager;
use Puppet::Log ;
$loaded = 1;
print "ok 1\n";

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
$f->command(-label => 'Quit',  -command => sub{exit;} );

my $spe = $mw->Frame -> pack ;
$spe -> Button (text => 'add', 
                command => sub {$toto -> insertText("added\n")} ) 
  -> pack (side => 'left') ;

print "creating manager\n";
my $wmgr = $mw -> MultiManager ( 'title' => 'log test' ,
                             'menu' => $w_menu ) -> pack ();

print "Creating new log\n" ;
my $log = new Puppet::Log('log test') ;

print "inserting some text in log\n";
$log -> log("This text was logged but not printed") ;
$log -> log("This text was logged and printed",'whenNoDisplay' => 'print') ;
$log -> log("This text was also logged and warned" ,
            'whenNoDisplay' => 'print') ;

print "requiring display on log\n";
$log ->display($wmgr, 1) ;
$log -> log("This text was also logged after display was created" ,
            'whenNoDisplay' => 'print') ;

print "Creating sub window toto\n";
$toto = $wmgr -> newSlave('type'=>'MultiText', title => 'toto') ;

print "Creating orphan log window\n";
my $orphan = new Puppet::Log('orphan') ;
$orphan -> log ("poor guy") ;
my $orphanb = new Puppet::Log('orphan2') ;
$orphanb -> log ("poor brother") ;

$spe -> Button (text => 'recall orphan log', 
                 command => sub {$orphan -> display($mw) ;} ) 
  -> pack (side => 'left');
$spe -> Button (text => 'recall orphan brother', 
                 command => sub {$orphanb -> display($mw) ;} ) 
  -> pack (side => 'left');

my $bmgr = $orphan -> display($mw) ;
$orphanb -> display($bmgr) ;

MainLoop ; # Tk's

