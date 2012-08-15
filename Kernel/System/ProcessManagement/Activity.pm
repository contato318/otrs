# --
# Kernel/System/ProcessManagement/Activity.pm - all Activity functions
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: Activity.pm,v 1.3 2012-08-15 16:38:16 cr Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ProcessManagement::Activity;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

use vars qw($VERSION);
$VERSION = qw($Revision: 1.3 $) [1];

=head1 NAME

Kernel::System::ProcessManagement::Activity - Activities lib

=head1 SYNOPSIS

All Process Management Activity functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::Config;
    use Kernel::System::Encode;
    use Kernel::System::Log;
    use Kernel::System::ProcessManagement::Activity;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $ActivityObject = Kernel::System::ProcessManagement::Activity->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Needed (qw(ConfigObject LogObject)) {
        die "Got no $Needed!" if !$Param{$Needed};

        $Self->{$Needed} = $Param{$Needed};
    }

    return $Self;
}

=item ActivityGet()

    Get Activity info

    my $Activity = $ActivityObject->ActivityGet(
        ActivityEntityID => 'A1',
    );

    Returns:

    $Activity = {
          'Name'           => 'Activity 3'
          'CreateTime'     => '08-02-2012 13:37:00',
          'ChangeBy'       => '2',
          'ChangeTime'     => '09-02-2012 13:37:00',
          'CreateBy'       => '3',
          'ActivityDialog' => {
              '1' => 'AD5',
              '3' => 'AD7',
              '2' => 'AD6',
            },
        };

=cut

sub ActivityGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(ActivityEntityID)) {
        if ( !defined $Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $Activity = $Self->{ConfigObject}->Get('Process::Activity');

    if ( !IsHashRefWithData($Activity) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need Activity config!'
        );
        return;
    }

    if ( !IsHashRefWithData( $Activity->{ $Param{ActivityEntityID} } ) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "No data for Activity '$Param{ActivityEntityID}' found!"
        );
        return;
    }
    return $Activity->{ $Param{ActivityEntityID} };
}

=item ActivityList()

    Get a list of all Activities

    my $Activities = $ActivityObject->ActivityList();

    Returns:

    $ActivityList = {
        'A1' => 'Activity 1',
        'A2' => 'Activity 2',
        'A3' => '',
    };

=cut

sub ActivityList {
    my ( $Self, %Param ) = @_;

    my $Activities = $Self->{ConfigObject}->Get('Process::Activity');

    if ( !IsHashRefWithData($Activities) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need Activity config!'
        );
        return;
    }

    my %ActivityList = map { $_ => $Activities->{$_}{Name} || '' } keys %{$Activities};
    return \%ActivityList;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut

=head1 VERSION

$Revision: 1.3 $ $Date: 2012-08-15 16:38:16 $

=cut
