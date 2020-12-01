package Timeline {
    use uni::perl;
    use Moose;
    use Heap::Simple::Perl;

    use Dynasty::Event;

    use namespace::autoclean;

    has 'starting_date', is => 'ro', isa => 'DateTime', required => 1;
    has 'date', is => 'rw', isa => 'DateTime', lazy => 1, default => sub { $_[0]->starting_date };

    has '_pending_events', is => 'ro',
        default => sub { Heap::Simple::Perl->new(elements => [Method => 'date']) };

    has 'event_observer',
        is => 'ro',
        isa => 'CodeRef';

    # has 'people', traits => ['Array'], is => 'ro', isa => 'ArrayRef[Person]', default => sub { [] };

    sub add_event {
        my ($self, $event) = @_;
        $self->_pending_events->insert($event);
    }

    sub advance {
        my $self = shift;

        my $event = $self->_pending_events->extract_first or return 0;
        $self->date($event->date);

        if ($self->event_observer && $self->event_observer->($event)) {
            $event->process($self);
        }

        return 1;
    }

    __PACKAGE__->meta->make_immutable;
}

1;
