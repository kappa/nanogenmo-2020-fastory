use uni::perl;

package Story {
    use Text::Wrap;

    $Text::Wrap::columns = 72;

    sub gen_bio {
        my ($self, $p, $events) = @_;

        my @chunks;

        for my $e (@$events) {
            push @chunks, $e->gen_bio_note();
        }

        my $story = join(" ", @chunks);
        $story =~ s/^\s+//;

        return Text::Wrap::wrap("", "", $story);
    }

    sub gen_short_story {
        my ($self, $p, $events) = @_;

        my @chunks;

        # school, growing
        # Spouse, children
        # worked as
        # move
        # cliffhanger
        # illness
        # hobby
        # cute story from late years
        # artifact
        # death

        my $story = join(" ", @chunks);
        $story =~ s/^\s+//;

        return Text::Wrap::wrap("", "", $story);
    }
}

1;
