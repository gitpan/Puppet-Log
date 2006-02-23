############################################################
#
# $Header: /home/domi/perlDev/old/Puppet_Log/RCS/Log.pm,v 1.12 2006/02/23 08:25:56 domi Exp $
#
# $Source: /home/domi/perlDev/old/Puppet_Log/RCS/Log.pm,v $
# $Revision: 1.12 $
# $Locker:  $
# 
############################################################

# Copyright (c) 1998,1999,2006 Dominique Dumont. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Puppet::Log ;
use Puppet::LogBody ;

use Carp ;

use strict ;
use vars qw(@ISA $VERSION) ;

@ISA=qw/Puppet::LogBody/ ;

$VERSION = sprintf "%d.%03d", q$Revision: 1.12 $ =~ /(\d+)\.(\d+)/;

# see loadspecs for other names

sub new 
  {
    my $type = shift ;

    my $title ;
    if (scalar @_ % 2)
      {
        carp "Unnamed 'title' parameter is deprecated with Puppet::Log\n";
        $title = shift ;
      }

    my %args = @_ ;
    $title = delete $args{title} unless defined $title;

    if (defined $args{whenNoDisplay})
      {
        carp "whenNoDisplay parameter is deprecated with Puppet::Log->new\n";
        $args{how}=delete $args{whenNoDisplay};
      }


    my $help = delete $args{'help'} || '';
    # parameter 'title' is a short name for the Tk window
    # parameter 'name' is a long name for the casual print

    my $self = new Puppet::LogBody(%args);
    $self->{help} = $help ;
    $self->{title} = $title ;

    bless $self,$type;
  }

sub log
  {
    my $self = shift ;
    my $text = shift ;
    my %args = @_;

    if (defined $args{whenNoDisplay})
      {
        carp "whenNoDisplay parameter is deprecated with Puppet::Log->log\n";
        $args{how}=delete $args{whenNoDisplay};
      }

    $text = $self->SUPER::log($text,%args);

    if (defined $self->{'textObj'})
      {
        $self->{'textObj'}->insertText($text) ;
      }
  }

sub clear
  {
    my $self = shift ;
    $self->SUPER::clear();
    if (defined $self->{'textObj'}) {$self->{'textObj'}->clear ;}
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
    require Tk::Multi::Toplevel ;

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
        $self->{manager} = $ref -> MultiTop 
          (
           'title' => 'log '.$self->{title}, 
          ) ;
        $self->{manager}->OnDestroy(sub{$ref->destroy;});
      }
    elsif (ref($ref) eq 'Tk::Multi::Manager' 
           or ref($ref) eq 'Tk::Multi::Toplevel')
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
       'title' => $self->{title},
       'hidden' => $hidden ,
       'help' => $self->{help}
      ) ;

    $self->{textObj} -> OnDestroy(sub{$self->close;}) ;

    map ($self->{'textObj'} -> insertText($_),$self->getAll()) ;

    return $self->{manager} ;
  }

sub show
  {
    my $self = shift ;

    if (defined $self->{manager})
      {
        $self->{'manager'}->show($self->{title});      
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

Puppet::Log - Log facility with an optional Tk display

=head1 SYNOPSIS

 use Puppet::Log ;

 my $log = new Puppet::Log('title' =>'log test') ;
 $log -> log("Some text") ;

 # $wmgr can be a toplevel Tk main window or a Tk::Multi::Manager
 $log ->display($wmgr, 1) ; 

=head1 DESCRIPTION

This class implements a log facility with an optional Tk display. 

I.e once the class is created, you can log messages in it, but the Tk
display does no need to be created at the same time. You may invoke
later only when you need it.

When the Tk display is not invoked, the log can be either printed on
STDOUT or warned on STDERR (or stay hidden). But in any case, the log
message will be stored in the class so that all log messages can be
retrieved later by the user or by the Tk display when invoked.

Once the Tk display is invoked, it will be updated by new logs.

=head1 Constructor

=head2 new([title => 'name'], ['how' => 'print' | 'warn' ])

Creates the log object.

The constructor parameters are :

=over 4

=item *

title: Title of the Tk log display (optional)

=item *

name: Name of the log used when printing on STDOUT or STDERR (optional)

=item *

how: Specifies what to do when a log is sent to the object (either
print on STDOUT, warn on STDERR). By default the logs will not be
printed or warned. (optional)

=item *

help The argument may be a string or a sub reference.  When the help
menu is invoked, either the help string will be displayed in a
Tk::Dialog box or the sub will be run. In this case it is the user's
responsability to provide a readable help from the sub.  (See
L<Tk::Multi::Manager/"help"> for further details)

=back

=head1 Methods

=head2 log(text,...)

Will log the passed text

Optional parameters are:

=over 4

=item *

how: will supersede the 'how' parameter passed to the constructor. If
'how' is set to undef, the log will not be printed or warned.

=back

=head2 clear()

Clear all stored logs.

=head2 getAll()

Return an array made of all stored logs.

=head2 display(toplevel_ref | multi_manager_reference, [hidden] )

Will create the log display. The log display is in fact a Tk::Multi::Text
window which can managed by a Tk::Multi::Manager object.

=over 4

=item toplevel_ref

The parent window object.

=item multi_manager_reference

The Tk::Multi::Manager reference

=item  hidden

When hidden is 1, the log will not displayed on start-up. (default is
to show the log window)

=back

If you don't provide a multi_manager reference, Puppet::Log will
consider that you want the Log to appear in its own TopLevel window.

In this case Puppet::Log will create a new Toplevel window and create
a Tk::Multi::Manager in it. In this case, it will feature a
File->close menu entry to destroy the Log window.

Once the Log window is destroyed, the display method can then be
called later to recreate it.

In any case display() returns the manager reference. You may reuse this
reference to add another Log display in the Toplevel window that Log
just created. So that both log windows are displayed in the same Tk
window.  (See the F<t/top_log.t> example to see what I mean)

=head2 show()

Will raise the log window. Note that this function is ignored if its called
before display().

=head1 About Puppet::* classes

Puppet classes are a set of utility classes which can be used by any object.
If you use directly the Puppet::*Body class, you get the plain functionnality.
And if you use the Puppet::* class, you can get the same functionnality and
a Tk Gui to manage it. 

The basic idea is when you construct a Puppet::* object, you have all
the functionnality of the object without the GUI. Then, when the need
arises, you may (or the class may decide to) open the GUI of the
object.  On the other hand, if the need does not arise, you may create
a lot of objects without cluttering your display.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998-1999,2006 Dominique Dumont. All rights reserved.  This
program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Puppet::LogBody(3), Tk(3), Tk::Multi::Text(3), Tk::Multi::Manager(3)

=cut
