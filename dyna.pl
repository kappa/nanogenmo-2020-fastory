#! /usr/bin/perl

use uni::perl;
use DateTime;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/lib";

use Dynasty::Timeline;
use Dynasty::Person;
use Dynasty::Story;

my $STARTING_YEAR = 1340;

my $DEBUG = 0;

exit main(@ARGV);

my %people;

sub observe_event {
    my $event = shift;

    state %seen_name;
    state %seen_period;

    my $person = $event->main_object;
    say STDERR $event->date, ' processing ', ref($event), ' for ', $person->name if $DEBUG;

    if (ref $event eq 'Event::Birth') {
        if ($seen_name{$person->name}) {
            return 0;
        } else {
            $seen_name{$person->name} = 1;
        }

        $people{$person}->{person} = $person;
    }

    push @{$people{$person}->{events}}, $event if $people{$person};

    return 1;
}

sub sim_salabim {
    for my $p (
        sort { $a->{person}->birthdate <=> $b->{person}->birthdate }
        values %people)
    {
        next unless $p->{person}->mother; # skip the progenitors

        say "\n    --- * * * ---    \n";
        say Story->gen_bio($p->{person}, $p->{events});
    }

    say "Found " . keys(%people) . " people";
}

sub main {
    my $timeline = Timeline->new(
        starting_date  => DateTime->new(year => $STARTING_YEAR),
        event_observer => \&observe_event,
    );

    for (0 .. 5) {
        Person->gen_random($STARTING_YEAR)->be_born_into($timeline);
    }

    my $event_counter = 0;
    while ($timeline->date->year <= 2020) {
        $timeline->advance or last;
    }

    sim_salabim;

    return 0;
}
