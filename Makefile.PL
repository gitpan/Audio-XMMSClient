use strict;
use warnings;
use ExtUtils::MakeMaker;
use ExtUtils::PkgConfig;

my %pkg_info = ExtUtils::PkgConfig->find('xmms2-client');

WriteMakefile(
		NAME			=> 'Audio::XMMSClient',
		VERSION_FROM	=> 'pm/XMMSClient.pm',
		ABSTRACT_FROM	=> 'pm/XMMSClient.pm',
		XSPROTOARG		=> '-noprototypes',
		MAN3PODS		=> {
			'pm/XMMSClient.pm'	                => '$(INST_MAN3DIR)/Audio::XMMSClient.$(MAN3EXT)',
			'pm/XMMSClient/Glib.pm'	            => '$(INST_MAN3DIR)/Audio::XMMSClient::Glib.$(MAN3EXT)',
		},
		PM				=> {
			'pm/XMMSClient.pm'	                => '$(INST_LIBDIR)/XMMSClient.pm',
			'pm/XMMSClient/Glib.pm'	            => '$(INST_LIBDIR)/XMMSClient/Glib.pm',
		},
		INC				=> '-Wall -Werror -Iperl_glue '.$pkg_info{cflags},
		LIBS			=> $pkg_info{libs},
		do {
			my @clean;
			my @OBJECT;
			my %XS;

			for my $xs (<xs/*.xs>) {
				(my $c = $xs) =~ s/\.xs$/\.c/i;
				(my $o = $xs) =~ s/\.xs$/\$(OBJ_EXT)/i;

				$XS{$xs} = $c;
				push @OBJECT, $o;
				push @clean, $o;
			}

			for my $c (<perl_glue/*.c>) {
				(my $o = $c) =~ s/\.c/\$(OBJ_EXT)/i;

				push @OBJECT, $o;
				push @clean, $o;
			}

			clean   => { FILES => join(' ', @clean) },
			OBJECT  => join(' ', @OBJECT),
			XS      => \%XS

		}
);

package MY;

use strict;
use warnings;
use Config;

sub const_cccmd {
	my $inherited = shift->SUPER::const_cccmd(@_);
	return '' unless $inherited;

	if ($Config{cc} eq 'cl') {
		warn 'you are using MSVC... my condolences.';
		$inherited .= ' /Fo$@';
	} else {
		$inherited .= ' -o $@';
	}

	return $inherited;
}
