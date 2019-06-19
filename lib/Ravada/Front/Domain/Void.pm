package Ravada::Front::Domain::Void;

use Moose;
use YAML qw(LoadFile);

extends 'Ravada::Front::Domain';

no warnings "experimental::signatures";
use feature qw(signatures);

my $DIR_TMP = "/var/tmp/rvd_void/".getpwuid($>);

our %GET_CONTROLLER_SUB = (
    'mock' => \&_get_controller_mock
    ,'disk' => \&_get_controller_disk
    ,screen => \&_get_controller_screen

);

sub get_driver {
    my $self = shift;
    my $name = shift;

    my $drivers = $self->_value('drivers');
    return $drivers->{$name} if exists $drivers->{$name};

    my $hardware = $self->_value('hardware');

    $name = 'device' if $name eq 'disk';
    return $hardware->{$name}->[0]->{driver}
        if $hardware->{$name} && $hardware->{$name}->[0];
}

sub _value{
    my $self = shift;

    my ($var) = @_;

    my ($disk) = $self->_config_file();

    my $data = {} ;
    $data = LoadFile($disk) if -e $disk;

    return $data->{$var};

}

sub _config_file {
    my $self = shift;
    return "$DIR_TMP/".$self->name.".yml";
}

sub _config_dir {
    return $DIR_TMP;
}

sub list_controllers {
    return %GET_CONTROLLER_SUB;
}

sub get_controller_by_name {
    my ($self, $name) = @_;
    return $GET_CONTROLLER_SUB{$name};
}

sub _get_controller_mock($self, $name='mock') {
    my $hardware = $self->_value('hardware');
    return if !exists $hardware->{$name};
    return @{$hardware->{$name}};
}

sub _get_controller_screen($self) {
    return $self->_get_controller_mock('screen');
}

sub _get_controller_disk {
    my $self = shift;
    return $self->list_volumes_info;
}

sub _default_screen_type { 'void' }
1;
