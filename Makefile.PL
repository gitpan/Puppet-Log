use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              'NAME'	   => 'Puppet::Log',
              'VERSION_FROM' => 'Log.pm', # finds $VERSION
              'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
              'PREREQ_PM' =>
              {
               'Tk' => 0,
               'Tk::Multi::Manager' => 0,
               'Tk::Multi::Text' => 0
              }
);
