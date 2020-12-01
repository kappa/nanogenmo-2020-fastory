use uni::perl;

package Person {
    use Moose;
    use Moose::Util::TypeConstraints;
    use MooseX::Enumeration;
    use Dynasty::Locale;
    use namespace::autoclean;

    use constant Genders => ['male', 'female'];

    my $DEBUG = 0;

    has 'is_alive', is => 'rw', isa => 'Bool', default => 1;
    has 'gender' => (
        traits      => ["Enumeration"],
        is          => 'ro',
        enum        => Genders,
        required    => 1,
        handles     => 1,
    );
    has 'birthdate', is => 'ro', isa => 'DateTime', required => 1;
    has 'birthplace', is => 'ro', isa => 'Str', required => 1;
    #has 'native_lang', is => 'ro', isa => 'Str', required => 1;
    has 'given_name', is => 'ro', isa => 'Str', required => 1;
    has 'family_name', is => 'ro', isa => 'Str', required => 1;
    #has health
    has 'residence_place', is => 'rw', isa => 'Str', default => sub { $_[0]->birthplace }, lazy => 1;
    has 'children', is => 'rw', isa => 'ArrayRef[Person]', default => sub { [] };
    has 'spouse', is => 'rw', isa => 'Person', predicate => 'is_married', clearer => 'breakup';

    has 'mother', is => 'ro', isa => 'Person';
    has 'father', is => 'ro', isa => 'Person';

    has 'left_parent_family', is => 'rw', isa => 'Bool', default => 0;

    sub name {
        my $self = shift;

        $self->given_name . " " . $self->family_name
    }

    sub be_born_into {
        my ($self, $timeline) = @_;

        my $siblings = 0;

        if ($self->mother) {
            $siblings = scalar @{$self->mother->children} || scalar @{$self->father->children};
        }

        $timeline->add_event(Event::Birth->new(
            main_object    => $self,
            date           => $self->birthdate,
            siblings_count => $siblings,
        ));
    }

    sub plan_life {
        my ($self, $timeline) = @_;

        for my $event ($self->destiny) {
            $timeline->add_event($event);
        }
    }

    sub destiny {
        my $self = shift;

        my @rv;
        say "### destiny for " . $self->name . " born at " . $self->birthdate if $DEBUG;

        my $death = $self->birthdate->clone->add(
            days => Locale->gen_life_expectancy($self)
        );
        push @rv, Event::Death->new(
            main_object => $self,
            date        => $death,
        );
        say "--> death at $death" if $DEBUG;
        my $life_in_days = $death->delta_days($self->birthdate)->in_units('days');

        # probability of a move
        if (rand() < Locale->gen_move_prob($self)) {
            my $move = $self->birthdate->clone->add(days => rand($life_in_days));
            if ($move < $death) {
                my $dst = Locale->gen_random_place($move->year);
                push @rv, Event::Travel->new(
                    main_object => $self,
                    date        => $move,
                    destination => $dst,
                );
                say "--> move to $dst at $move" if $DEBUG;
            }
        }

        # depend on place/epoch/gender/class
        my $puberty = $self->birthdate->clone->add(days => Locale->gen_puberty_age($self));
        if ($puberty > $death) {
            return @rv;
        }
        say "--> puberty at $puberty (also, leave parents)" if $DEBUG;
        push @rv, Event::LeaveParents->new(
            main_object => $self,
            date        => $puberty,
        );

        # marriages
        my $num_of_marriages = Locale->gen_marriages($self);
        say "--> married $num_of_marriages times" if $DEBUG;
        my $current = $puberty->clone;
        for my $i (1 .. $num_of_marriages) {
            $current->add(days => Locale->gen_dating_time($self));
            if ($current > $death) {
                return @rv;
            }

            push @rv, Event::Marriage->new(
                main_object  => $self,
                date         => $current->clone,
                take_surname => !$self->is_male && Locale->gen_husband_surname_prob($self),
            );
            say "--> $i marriage at $current" if $DEBUG;

            # num of children
            # depends on place/epoch/gender/class
            # 3, 2
            my $num_of_children = Locale->gen_fertility($self);
            say "--> $i marriage had $num_of_children children" if $DEBUG;
            my $current_child = $current->clone;
            for my $j (1 .. $num_of_children) {
                # time to next child
                $current_child->add(days => Locale->gen_time_to_child($self));
                if ($current_child > $death) {
                    return @rv;
                }

                my $are_twins = rand() < Locale->gen_twins_prob($self) || 0;
                push @rv, Event::Childbirth->new(
                    main_object => $self,
                    date        => $current_child->clone,
                    twins       => $are_twins,
                );
                say "--> $i marriage $j child born at $current_child, twins($are_twins)" if $DEBUG;
            }

            # length of marriage after last child
            $current = $current_child->clone->add(days => Locale->gen_life_after_children($self));
            if ($current > $death) {
                return @rv;
            }
            say "--> $i marriage ends at $current" if $DEBUG;
            push @rv, Event::Breakup->new(
                main_object => $self,
                date        => $current->clone,
            );
        }

        grep { $_->date <= $death } @rv
    }

    sub gen_random {
        my ($self, $year, $gender, $birthplace) = @_;

        my $birthdate = DateTime->new(year => $year);
        $birthdate->add(days => rand($birthdate->is_leap_year ? 366 : 365));

        $gender ||= $self->Genders->[int(rand(2))];

        $birthplace ||= Locale->gen_random_place($year);

        my $given_name  = Locale->gen_given_name($gender, $birthplace, $year);
        my $family_name = Locale->gen_family_name($gender, $birthplace, $year);

        $self->new(
            gender      => $gender,
            birthdate   => $birthdate,
            birthplace  => $birthplace,
            given_name  => $given_name,
            family_name => $family_name,
        )
    }

    __PACKAGE__->meta->make_immutable;
}

1;
