############################################################
#
# $Header: /mnt/barrayar/d06/home/domi/Tools/perlDev/Puppet_Log/RCS/Log.pm,v 1.4 1998/06/22 11:38:35 domi Exp $
#
# $Source: /mnt/barrayar/d06/home/domi/Tools/perlDev/Puppet_Log/RCS/Log.pm,v $
# $Revision: 1.4 $
# $Locker:  $
# 
############################################################

# Copyright (c) 1998 Dominique Dumont. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Puppet::Log ;

use Carp ;

use strict ;
use vars qw($VERSION) ;

$VERSION = '0.2' ;

# see loadspecs for other names
sub new 
  {
    my $type = shift ;
    my $self = {} ;
    $self->{name} = shift || 'unknown' ;
    my %args = @_ ;

    $self->{printOut} = $args{'whenNoDisplay'};

    $self->{'data'}= [] ;

    bless $self,$type ;
  }

sub log
  {
    my $self = shift ;
    my $text = shift ;
    my %args = @_ ;

    my $printOut = $args{'whenNoDisplay'} || $self->{printOut};

    chomp ($text) ;
    $text .= "\n";

    push @{$self->{'data'}}, $text ; # always keep text in local array

    if (defined $self->{'textObj'})
      {
        $self->{'textObj'}->insertText($text) ;
      }
    elsif (defined $printOut)
      {
        if ($printOut eq 'print')
          {
            print ref($self),"::",$self->{name},": \n\t",$text ;
          }
        else
          {
            warn ref($self),"::",$self->{name},": \n\t",$text ;
          }
      }
  }

sub clear
  {
    my $self = shift ;

    if (defined $self->{'textObj'}) {$self->{'textObj'}->clear ;}
    $self->{'data'} =[];
  }

sub display
  {
    my $self =shift ;
    # ref is either a toplevel or a multi manager, optionnal if display was
    # already called once.
    my $ref = shift ; 
    my $hidden = shift || 0 ; #optionnal

    # load only when display is called
    require Tk::Multi::Manager ;
    require Tk::Multi::Text ;

    # don't create 2 displays
    if (defined $self->{textObj})
      {
        my $mytop = $self->{textObj}->toplevel ;
        $mytop->deiconify() if ($mytop->state() eq 'iconic');
        $mytop->raise();
        return $self->{manager};
      }

    croak( "No ref (should be either a Toplevel or a MultiManager) ",
    "given for Puppet::Log\n" )
      unless defined $ref ;

    if (ref($ref) eq 'Tk::Toplevel' or ref($ref) eq 'MainWindow')
      {
        # create Top Level window with menu if no manager is given
        
        my $window = $ref->Toplevel() ;
        $window -> title('log '.$self->{name});

        my $w_menu = $window->Frame(-relief => 'raised', -borderwidth => 2);
        $w_menu->pack(-fill => 'x');
        my $f = $w_menu->Menubutton(-text => 'File') -> pack(side => 'left' );
        $f->command(-label => 'close log',  
                    -command => sub{$window->destroy(); } );

        $self->{manager} = $window -> MultiManager 
          (
           'title' => 'log '.$self->{name}, 'menu' => $w_menu
          ) -> pack ();
      }
    elsif (ref($ref) eq 'Tk::Multi::Manager')
      {
        $self->{manager} = $ref ;
      }
    else
      {
        croak("Unexpected tk object ( ",ref($ref)," ) given to Puppet::Log\n");
      }

    $self->{'textObj'} = $self->{manager} -> newSlave
      (
       'type' => 'MultiText',
       'title' => $self->{name},
       'hidden' => $hidden 
      ) ;

    $self->{textObj} -> OnDestroy(sub{$self->close;}) ;

    map ($self->{'textObj'} -> insertText($_),@{$self->{'data'}}) ;
    #$self->{'data'} = [] ; #reset

    return $self->{manager} ;
  }

sub show
  {
    my $self = shift ;

    if (defined $self->{manager})
      {
        $self->{'manager'}->show($self->{name});      
      }
  }

sub close
  {
    my $self = shift ;

    delete $self->{textObj} ; # delete the reference in the hash
    delete $self->{manager} ;
  }



1;

__END__

=head1 NAME

Puppet::Log - Log window used by any puppet class

=head1 SYNOPSIS

use Puppet::Any ;
use Data::Dumper ;

package myClass ;

@myClass::ISA=('Puppet::Any') ;

=head1 DESCRIPTION

This class defined a log facility usable by any class.

This log class will store all text passed to it. When no its display is not
opened, the log text will be written on stdout. If a display is opened,
the text display will be updated with the log text.

When the display is created it will feature all logs written since the creation
of this object or since the clear method was called.

=cut

=head1 Methods

=head2 new(name,['whenNoDisplay' => 'print' | 'warn' ])

Creates the log object. 'name' is the log name.

The whenNoDisplay parameter specifies what to do when a log is sent to the
object and the display is not opened (either print on STDOUT, warn on 
STDERR)

=head2 log(text,['whenNoDisplay' => 'print' | 'warn' ])

Will log the passed text

The whenNoDisplay parameter will supersede the parameter passed to the 
constructor.

=head2 clear()

Clear the logs

=head2 display(toplevel_ref | multi_manager_reference, [hidden] )

Will create the log display. The log display is in fact a Tk::Multi::Text
window which can managed by a Tk::Multi::Manager object.

 - toplevel_ref is the parent window object.
 - multi_manager_reference is the Tk::Multi::Manager reference
 - hidden : when hidden is 1, the log will not displayed on start-up. (default
   is to show the log window)

If you don't provide a multi_manager reference, Puppet::Log will consider that 
you want the Log to appear in its own TopLevel window. So Log will create
a new Toplevel window and create a menu manager in it.
In this case, the menu will feature also a File->close button which will
destroy the window. The display method can then be called later to recall the
log window.

In any case Log returns the manager reference. You may reuse this reference
to add another Log display in the Toplevel window that Log just created.
(See the test.pl file if this not clear enough. Curiously enough I have some
doubts regarding my explanations)

=head2 show()

Will raise the log window. Note that this function is ignored if its called
before display().

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi::Text(3), Tk::Multi::Manager(3)

=cut
