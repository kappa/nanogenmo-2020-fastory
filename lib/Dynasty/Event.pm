package Event {
    use Moose::Role;
    #use Moose::Util::TypeConstraints;
    use namespace::autoclean;

    has 'date', is => 'ro', isa => 'DateTime', required => 1;
    has 'main_object', is => 'ro', isa => 'Person', required => 1;

    requires 'process';

    sub gen_bio_note {
        my $self = shift;

        return ref($self) . " for " . $self->main_object->name . ".";
    }
}

package Event::Birth {
    use Moose;
    use namespace::autoclean;

    with 'Event';

    has 'siblings_count', is => 'ro', isa => 'Num', required => 1;

    sub process {
        my ($self, $timeline) = @_;
        $self->main_object->plan_life($timeline);
    }

    sub gen_bio_note {
        my $self = shift;

        my $person     = $self->main_object;
        my $name       = $person->name;
        my $b_date_str = $person->birthdate->strftime('%d/%m/%Y');
        my $country    = $person->birthplace;
        my $Pronoun    = $person->is_male ? 'He' : 'She';
        my $c_num      = $self->siblings_count;
        my $father     = $person->father;
        my $mother     = $person->mother;

        my $parents;

        if ($c_num > 1) {
            if ($father->family_name eq $mother->family_name) {
                $parents = $father->given_name . " and " . $mother->name;
            } else {
                $parents = $father->name . ", " . $mother->name;
            }
            return "$name was born on $b_date_str in $country into the family of $parents and their $c_num other children.";
        } elsif ($c_num == 1) {
            if ($father->family_name eq $mother->family_name) {
                $parents = $father->given_name . " and " . $mother->name;
            } else {
                $parents = $father->name . ", " . $mother->name;
            }
            return "$name was born on $b_date_str in $country into the family of $parents and their other child.";
        } else {
            if ($father->family_name eq $mother->family_name) {
                $parents = $father->given_name . " and " . $mother->name;
            } else {
                $parents = $father->name . " and " . $mother->name;
            }
            return "$name was born in $b_date_str in $country into the family of $parents. $Pronoun was their first child.";
        }
    }

    __PACKAGE__->meta->make_immutable;
}

package Event::Childbirth {
    use Moose;
    use Moose::Util::TypeConstraints;
    use Dynasty::Person;
    use namespace::autoclean;

    with 'Event';

    has 'twins', is => 'ro', 'isa' => 'Bool', default => 0;

    has 'children', is => 'rw', 'isa' => 'ArrayRef[Person]', default => sub { [] };

    sub process {
        my ($self, $timeline) = @_;

        my $am_father = $self->main_object->is_male;
        my $family_name = $am_father ? $self->main_object->family_name : $self->main_object->spouse->family_name;

        for (0 .. ($self->twins ? 1 : 0)) {
            my $gender = Person->Genders->[int(rand(2))];
            my $given_name = Locale->gen_given_name($gender, $self->main_object->residence_place, $self->date->year);

            my $new_born = Person->new(
                gender      => $gender,
                birthdate   => $self->date,
                birthplace  => $self->main_object->residence_place,
                given_name  => $given_name,
                family_name => $family_name,
                father      => $am_father ? $self->main_object : $self->main_object->spouse,
                mother      => $am_father ? $self->main_object->spouse : $self->main_object,
            );

            push @{$self->main_object->children}, $new_born;
            push @{$self->children}, $new_born;

            $new_born->be_born_into($timeline);
        }
    }

    sub gen_bio_note {
        my $self = shift;

        my $person = $self->main_object;

        my $year  = $self->date->year;
        my $mon   = $self->date->month_name;

        if ($self->twins) {
            my $names = $self->children->[0]->given_name . " and " . $self->children->[1]->given_name;

            my $babies;
            if ($self->children->[0]->is_male) {
                if ($self->children->[1]->is_male) {
                    $babies = 'two boys';
                } else {
                    $babies = 'a boy and a girl';
                }
            } else {
                if ($self->children->[1]->is_male) {
                    $babies = 'a girl and a boy';
                } else {
                    $babies = 'two girls';
                }
            }

            return "In $mon of $year the family was blessed with twins, $babies, who they named $names."
        } else {
            my $name = $self->children->[0]->given_name;
            my $baby = $self->children->[0]->is_male ? 'baby-boy' : 'baby-girl';

            return "In $mon of $year the family had a $baby who they named $name."
        }
    }

    __PACKAGE__->meta->make_immutable;
}

package Event::Death {
    use Moose;
    use namespace::autoclean;

    with 'Event';

    sub process {
        my ($self, $timeline) = @_;
        $self->main_object->is_alive(0);
    }

    sub gen_bio_note {
        my $self = shift;

        my $person = $self->main_object;
        my $name   = $person->name;

        if ((my $d = $self->date->delta_days($person->birthdate)->in_units('days')) < 20) {
            my $first_name = $person->given_name;
            return "Unfortunately, baby $first_name died in several days."
        } else {
            my $date_str = $self->date->strftime('%d/%m/%Y');
            my $dow      = $self->date->day_name;

            return "On $date_str, $dow, $name died."
        }
    }

    __PACKAGE__->meta->make_immutable;
}

package Event::LeaveParents {
    use Moose;
    use namespace::autoclean;

    with 'Event';

    sub process {
        my ($self, $timeline) = @_;
        $self->main_object->left_parent_family(1);
    }

    sub gen_bio_note {
        my $self = shift;

        my $person = $self->main_object;
        my $name   = $person->given_name;

        my $year = $self->date->year;
        my $mon  = $self->date->month_name;

        return "In $mon of $year $name left the family to live separately."
    }

    __PACKAGE__->meta->make_immutable;
}

package Event::Travel {
    use Moose;
    use namespace::autoclean;

    with 'Event';

    has 'destination', is => 'ro', isa => 'Str', 'required' => 1;
    has 'source', is => 'rw', isa => 'Str';

    sub process {
        my ($self, $timeline) = @_;
        $self->source($self->main_object->residence_place);
        $self->main_object->residence_place($self->destination);

        for my $child (@{$self->main_object->children}) {
            $child->residence_place($self->destination) unless $child->left_parent_family;
        }
    }

    sub gen_bio_note {
        my $self = shift;

        return "" if $self->source eq $self->destination;

        my $person = $self->main_object;
        my $name   = $person->given_name;

        my $year = $self->date->year;
        my $mon  = $self->date->month_name;

        my $source = $self->source;
        my $dst    = $self->destination;

        return "An big move for the family of $name happened in $mon of $year. After a long travel from their home in $source they settled down in a small town in $dst."
    }

    __PACKAGE__->meta->make_immutable;
}

package Event::Marriage {
    use Moose;
    use namespace::autoclean;

    with 'Event';

    has 'spouse', is => 'rw', isa => 'Person';

    sub process {
        my ($self, $timeline) = @_;

        my $spouse = Person->gen_random($self->main_object->birthdate->year,
                                        $self->main_object->is_male ? 'female' : 'male',
                                        $self->main_object->residence_place);

        $self->spouse($spouse);

        $self->main_object->spouse($spouse);
    }

    sub gen_bio_note {
        my $self = shift;

        my $person = $self->main_object;
        my $name   = $person->given_name;

        my $date_str = $self->date->strftime('%d/%m/%Y');

        my $spouse = $self->spouse->name;

        return "On the day of $date_str, $name married $spouse."
    }

    __PACKAGE__->meta->make_immutable;
}

package Event::Breakup {
    use Moose;
    use namespace::autoclean;

    with 'Event';

    has 'spouse', is => 'rw', isa => 'Person';

    sub process {
        my ($self, $timeline) = @_;

        $self->spouse($self->main_object->spouse);

        $self->main_object->breakup;
    }

    sub gen_bio_note {
        my $self = shift;

        my $person = $self->main_object;
        my $name   = $person->given_name;

        my $year = $self->date->year;
        my $mon  = $self->date->month_name;
        my $day  = $self->date->day;

        my $spouse = $person->is_male ? "his wife " . $self->spouse->name : "her husband " . $self->spouse->name;

        return "In $mon of $year, $name broke up with $spouse."
    }

    __PACKAGE__->meta->make_immutable;
}

1;
