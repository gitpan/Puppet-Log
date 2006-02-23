use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	   => 'Puppet::Log',
   'VERSION_FROM' => 'Log.pm', # finds $VERSION
   'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
   ($] >= 5.005 ?
    (ABSTRACT   => 'Log facility based on Tk',
     AUTHOR     => 'Dominique Dumont (domi@komarr.grenoble.hp.com)') : ()),
   'PREREQ_PM' =>
   {
    'Tk' => 0,
    'Puppet::LogBody' => 0,
    'Tk::Multi::Manager' => '2.001',
    'Tk::Multi::Toplevel' => '0',
    'Tk::Multi::Text' => '2.001'
   }
  );
