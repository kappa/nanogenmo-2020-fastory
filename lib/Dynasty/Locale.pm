use uni::perl;

package Locale {
    use Math::Random::NormalDistribution;
    use List::Util qw/max/;

    # taken from https://en.wikipedia.org/wiki/List_of_countries_by_population_in_1600 and similar
    my @places = (
        [1000 => ['Song Empire', 'Byzantine Empire', 'Holy Roman Empire', 'Fatimid Caliphate', 'Kievan Rus', 'France']],
        [1500 => ['Ming Empire', 'Delhi Sultanate', 'France', 'Holy Roman Empire', 'Ottoman Empire', 'Spain', 'Republic of Venice']],
        [1600 => ['Ming Empire', 'Mughal Empire', 'Ottoman Empire', 'Russia', 'France', 'Iberian Union', 'Holy Roman Empire', 'Tokugawa Shogunat']],
        [1800 => ['Qing Empire', 'Maratha Empire', 'British Empire', 'France', 'Russia', 'Holy Roman Empire', 'Ottoman Empire', 'Spain', 'Prussia', 'Persia', 'United States of America']],
        [1900 => ['Qing China', 'British Empire', 'Russia', 'France', 'United States of America', 'Germany', 'Austria-Hungary', 'Italy', 'Mexico', 'Persia']],
        [1939 => ['China', 'Japan', 'Soviet Union', 'United States', 'British Empire', 'France', 'Germany', 'Poland', 'Romania', 'Iran']],
        [1989 => ['China', 'India', 'Soviet Union', 'United States', 'Indonesia', 'Japan', 'Nigeria', 'Pakistan', 'West Germany', 'East Germany', 'Yugoslavia', 'Zaire']],
        [2000 => ['Germany', 'China', 'India', 'United States', 'Russian Federation', 'Vietnam', 'Ukraine', 'Germany', 'Bangladesh', 'Pakistan', 'Philippines', 'Serbia']],
    );

    my %given_names = (
        'China'  => {
            'male' => [
                [1000 => ['Li', 'Wei', 'Fang', 'Jing', 'Na', 'Min', 'Qiang', 'Lei', 'Jun', 'Yang']],
                [1966 => ['Li', 'Wei', 'Fang', 'Jing', 'Na', 'Min', 'Qiang', 'Lei', 'Jun', 'Yang', 'Qiangguo', 'Dongfeng', 'Jianguo', 'Tungfung']],
            ],
            'female' => [
                [1000 => ['Li', 'Li-Li', 'Fang', 'Fang-Fang', 'Jing', 'Xiuying', 'Yan', 'Yan-Yan', 'Juan', 'Ming', 'Xia', 'Mei']],
            ],
        },
        'Byzantine Empire' => {
            'male' => [
                [1000 => ['Constantine', 'Alexander', 'Alexey', 'Theodore', 'Nicholas', 'Michael', 'Leo', 'Basil']],
            ],
            'female' => [
                [1000 => ['Anastasia', 'Anna', 'Maria', 'Eugenia', 'Antonina', 'Sophia']],
            ],
        },
        'Holy Roman Empire' => {
            'male' => [
                [1000 => ['Frederick', 'Maximilian', 'Rudolph', 'Leopold', 'Joseph' ]],
            ],
            'female' => [
                [1000 => ['Anna', 'Elizabeth', 'Barbara', 'Maria', 'Isabella', 'Eleonora', 'Claudia', 'Margarite']],
            ],
        },
        'Fatimid Caliphate' => {
            'male' => [
                [1000 => ['Ali', 'Abdullah', 'Ahmed', 'Farooq', 'Haamid', 'Habib', 'Hussain', 'Ibrahim', 'Yousef', 'Usman']],
            ],
            'female' => [
                [1000 => ['Aisha', 'Jamila', 'Layla', 'Malika', 'Zeinab', 'Qadira', 'Nura']],
            ],
        },
        'Kievan Rus' => {
            'male' => [
                [1000 => ['Andrey', 'Ivan', 'Yaroslav', 'Pyotr', 'Bazhen', 'Bulgak', 'Zhdan', 'Nekras', 'Nechay', 'Yaropolk', 'Izyaslav', 'Ostromir']],
                [1500 => ['Boris', 'Andrey', 'Ivan', 'Yaroslav', 'Pyotr', 'Oleg', 'Victor', 'Roman', 'Maxim', 'Pavel', 'Sergey', 'Vyacheslav', 'Vsevolod', 'Gleb', 'Igor']],
                [1900 => ['Boris', 'Andrey', 'Ivan', 'Yaroslav', 'Pyotr', 'Oleg', 'Victor', 'Roman', 'Maxim', 'Pavel', 'Sergey', 'Vyacheslav', 'Vsevolod', 'Gleb', 'Igor', 'Timur', 'Artur']]
            ],
            'female' => [
                [1000 => ['Vasilisa', 'Ivana', 'Katerina', 'Tatiana', 'Lubov', 'Vera', 'Zabava', 'Smeyana', 'Istoma', 'Goluba', 'Nelyuba']],
                [1500 => ['Olga', 'Ekaterina', 'Tatiana', 'Lubov', 'Vera', 'Ulyana', 'Irina']],
                [1810 => ['Olga', 'Ekaterina', 'Tatiana', 'Lubov', 'Vera', 'Irina', 'Tamara', 'Roza', 'Svetlana', 'Margarita', 'Ella', 'Lilia']],
            ],
        },
        'France' => {
            'male' => [
                [1000 => ['Louis', 'Henry', 'Charles', 'Albert', 'Claude', 'Jean', 'Jacques', 'Raphael', 'Simon', 'Yves']],
            ],
            'female' => [
                [1000 => ['Claire', 'Charlotte', 'Caroline', 'Sophie', 'Madelyn', 'Josephine', 'Elise', 'Nicole', 'Camille', 'Michelle']],
            ],
        },
        'Delhi Sultanate' => {
            'male' => [
                [1000 => ['Andhaka', 'Mahendra', 'Krishna', 'Agastya', 'Sagara', 'Aditya', 'Dhruv', 'Gautam', 'Parth', 'Salman', 'Rohan']],
            ],
            'female' => [
                [1000 => ['Anusuya', 'Satyavati', 'Lakshmi', 'Maya', 'Narmada', 'Amena', 'Aparna', 'Deepika', 'Gayatri', 'Leela', 'Nargis', 'Noor', 'Pooja', 'Tara', 'Shivani']],
            ],
        },
        'Ottoman Empire' => {
            'male' => [
                [1000 => ['Sinan', 'Yakub', 'Timurhan', 'Murad', 'Mustafa', 'Mehmed', 'Suleiman', 'Kismet', 'Kemal', 'Iskender', 'Hamza', 'Hasan', 'Emre', 'Berke']],
            ],
            'female' => [
                [1000 => ['Tohin', 'Zohal', 'Sila', 'Selime', 'Elif', 'Rabiye', 'Nefise', 'Kadem', 'Gulbahar', 'Fatima', 'Emine', 'Behiye']],
            ],
        },
        'Spain' => {
            'male' => [
                [1000 => ['Alonso', 'Alvaro', 'Baltasar', 'Bautista', 'Carlos', 'Diego', 'Pedro', 'Sebastian', 'Santiago', 'Rodrigo', 'Miguel', 'Marcos']],
            ],
            'female' => [
                [1000 => ['Isabel', 'Carmela', 'Maria', 'Catalina', 'Ana', 'Juana', 'Francisca', 'Beatriz', 'Ines', 'Lucia']],
            ],
        },
        'Republic of Venice' => {
            'male' => [
                [1000 => ['Ambroso', 'Aurelio', 'Bastiano', 'Bortolo', 'Claudio', 'Dionisio', 'Filippo', 'Giambattista', 'Giulio', 'Vittorio', 'Tommaso', 'Paolo']],
            ],
            'female' => [
                [1000 => ['Angela', 'Agnese', 'Violante', 'Vincenza', 'Susanna', 'Rosa', 'Regina', 'Paola', 'Maria', 'Marcella', 'Lugrezia']],
            ],
        },
        'Tokugawa Shogunat' => {
            'male' => [
                [1000 => ['Yoshi', 'Yamato', 'Takeshi', 'Shiro', 'Shinobu', 'Nori', 'Ryoichi', 'Makoto', 'Kenta', 'Kazuo', 'Katsuro', 'Hiroshi', 'Hideyoshi']],
            ],
            'female' => [
                [1000 => ['Aiko', 'Etsuko', 'Haruka', 'Hoshi', 'Izumi', 'Satomi', 'Shinju', 'Yasu', 'Yoshiko', 'Yuri', 'Yuki', 'Noriko', 'Ren']],
            ],
        },
        'British Empire' => {
            'male' => [
                [1000 => [qw/John Oliver George Jack Thomas William Harry James Samuel Jacob Benjamin Oscar Edward Ethan Daniel Adam Dylan Toby/]],
            ],
            'female' => [
                [1000 => [qw/Olivia Charlotte Emily Grace Florence Mia Ella Lily Alice Jessica Chloe Matilda Ruby Willow Ivy Evelyn Harriet/]],
            ],
        },
        'Prussia' => {
            'male' => [
                [1000 => [qw/Ensel Gils Kristups Lenert Pinkus Tanius Timas Valtin Willus Jowalis Cilas/]],
            ],
            'female' => [
                [1000 => [qw/Agnet Albe Edwikke Elze Maryke Scharlotte Tille Zofija Magryta Lida Lenorte Heinriette Katryne/]],
            ],
        },
        'Persia' => {
            'male' => [
                [1000 => [qw/Ahura Arman Ahmed Arash Bahram Darius Farhad Ramin Piruz Vahid Sassan Shahryar Marduk Javad/]],
            ],
            'female' => [
                [1000 => [qw/Amaya Anousheh Armita Yasamin Taraneh Zenwer Safie Reyhan Roxana Niloufar Laleh Golnar Maryam/]],
            ],
        },
        'Poland' => {
            'male' => [
                [1000 => [qw/Lech Krzysztof Andrzej Piotr Tomasz Paweł Stanisław Marcin Jakub Antoni Filip Jan Szymon Franciszek Michał Wojciech Aleksander/]],
            ],
            'female' => [
                [1000 => [qw/Lena Zuzanna Julia Julia Zofia Hanna Aleksandra Amelia Natalia Wiktoria Katarzyna Maria Agnieszka Krystyna Barbara Ewa Karolina Magdalena/]],
            ],
        },
        'Romania' => {
            'male' => [
                [1000 => [qw/Alexandru Adrian Andrei Mihai Ionuţ Florin Daniel Marian Marius Cristian Mihai Razvan Ştefan/]]
            ],
            'female' => [
                [1000 => [qw/Ana-Maria Mihaela Andreea Elena Alexandra Cristina Daniela Alina Maria Ioana Maria Ioana Gabriela/]]
            ],
        },
    );

    $given_names{"Song Empire"} = $given_names{China};
    $given_names{"Ming Empire"} = $given_names{China};
    $given_names{"Qing Empire"} = $given_names{China};
    $given_names{"Qing China"} = $given_names{China};
    $given_names{"India"} = $given_names{"Delhi Sultanate"};
    $given_names{"Mughal Empire"} = $given_names{"Delhi Sultanate"};
    $given_names{"Maratha Empire"} = $given_names{"Delhi Sultanate"};

    $given_names{"United States of America"} = $given_names{"British Empire"};
    $given_names{"United States"} = $given_names{"British Empire"};
    $given_names{"Germany"} = $given_names{"Prussia"};
    $given_names{"West Germany"} = $given_names{"Germany"};
    $given_names{"East Germany"} = $given_names{"Germany"};
    $given_names{"Italy"} = $given_names{"Republic of Venice"};
    $given_names{"Mexico"} = $given_names{"Spain"};
    $given_names{"Austria-Hungary"} = $given_names{"Holy Roman Empire"};

    push @{$given_names{"Holy Roman Empire"}->{"male"}->[0]->[1]},
        @{$given_names{"France"}->{"male"}->[0]->[1]};
    push @{$given_names{"Holy Roman Empire"}->{"female"}->[0]->[1]},
        @{$given_names{"France"}->{"female"}->[0]->[1]};

    $given_names{"Russia"} = $given_names{"Kievan Rus"};
    $given_names{"Soviet Union"} = $given_names{"Russia"};

    $given_names{"Iberian Union"} = $given_names{"Spain"};
    $given_names{"Japan"} = $given_names{"Tokugawa Shogunat"};

    $given_names{"Iran"} = $given_names{"Persia"};

    my %family_names = (
        'China'  => [
            [1000 => [qw/Wang Li Zhang Liu Chen Yang Huang Zhao Wu Zhou Xu Sun Ma Zhu Hu Guo He Lin Gao Luo/]],
        ],
        'Byzantine Empire' => [
            [1000 => [qw/Angelos Hidromenos Basilikos Digenes Masgidas Makrenos Laskaris Melachrinos Amarantos Hyaleas Stavrakios/]],
        ],
        'Holy Roman Empire' => [
            [1000 => [qw/Muller Schmidt Schneider Fischer Weber Meyer Bauer Koch Klein Braun Erbach Conradiner Mansfeld Leiningen Oettingen Neuwied Sponheim/]],
        ],
        'Fatimid Caliphate' => [
            [1000 => [qw/Abbas Abdallah Badawi Baghdadi Bashar Dawoud Fadel Fasil Ghazali Ghulam Hashim Irfan Issawi Jawahir Kassab Maalouf Mugrabi Nader Nasser Qasim Rahim Rashid Saqqaf Zeyad Tawfiq/]],
        ],
        'Kievan Rus' => [
            [1000 => [qw/Lebed Byk Sokol Moroz Volk Semak Chernysh Malyuta Golovach Loban Zima Kot Tatarin Tugarin Zhuk/]],
            [1600 => [qw/Lebedev Ivanov Smirnov Kuznetsov Goncharov Petrov Popov Sokolov Morozov Volkov Novikov Pavlov Kozlov Kozhemyakin Bezborodov Nikanorov Yamschikov Belykh Chernykh Krasnykh/]],
            [1600 => [qw/Lebedev Ivanov Smirnov Kuznetsov Goncharov Petrov Popov Sokolov Morozov Volkov Novikov Pavlov Kozlov Ostrovsky Belozersky Zhukovsky Vyazemsky Voznesensky Troitsky/]],
        ],
        'France' => [
            [1000 => [qw/Lavigne Garnier Blanchet Moulin Laurent Dupont Martin Boucher Allard Corbin Dubois Cartier Fournier Beaufort Bonnet Fontaine Dufort Vernier Renaud/]],
            [1600 => [qw/Martin Bernard Dubois Thomas Robert Richard Petit Durand Moreau Lambert Laurent Renard Leclerq/]],
        ],
        'Delhi Sultanate' => [
            [1000 => [qw/Agarwal Anand Ahuja Patel Reddy Bakshi Bhatt Varma Chowdhury Chakrabarti Amin Malhotra Jain Ghosh Gupta Das Chopra Kapoor Goswami Kumar Biswas/]],
        ],
        'Ottoman Empire' => [
            [1000 => [qw/Asker Kaplan Aslan Onder Osman Yilmaz Younan Aydin Ozturk Aksoy Erdogan Yavuz Bulut Cetin Dogan Kaya/]],
        ],
        'Spain' => [
            [1000 => [qw/Torrero Vera Vida Valdes Toxenes Serrano Santos Salazar Rosa Romero Romano Quexada Quadrado Pinedo Palomino Marques Hurtado Herrero Garrido Galiano Flores/]],
        ],
        'Republic of Venice' => [
            [1000 => [qw/Verona Vicenza Treviso Belluno Padova Barozzi Visconti Tomado Sartore Rizo Natale Menegi Molin Marano Gritti Girardo Gandolfo Dente Damiani Contarini/]],
        ],
        'Tokugawa Shogunat' => [
            [1000 => [qw/Nishimoto Fujimura Uchida Yamaguchi Minamoto Tanaka Nishida Abo Ichimura Yamamoto Nishiyama Hangai Sato Suzuki Takahashi Tanaka Watanabe Ito Nakamura Kobayashi Kato Yoshida Yamamoto/]],
        ],
        'British Empire' => [
            [1000 => [qw/Smith Jones Williams Taylor Davies Evans Thomas Johnson Roberts Walker Wright Robinson Thompson White Hughes Edwards Green Lewis Wood Harris Martin Jackson Clarke/]],
        ],
        'Persia' => [
            [1000 => [qw/Abed Avesta Esfahani Farrokhzad Hashemi Jahangir Jamshidi Kabiri Khorasani Madani Mokri Pahlavi Parsi Rahbar Rostami Sasani Turani Heydari Ahmadi Karimi Hosseini/]],
        ],
        'Poland' => [
            [1000 => [qw/Abramczyk Andrzejewski Babinski Nowak Kowalski Wiśniewski Dabrowski Kaminski Kowalcyzk Zielinski/]],
        ],
        'Romania' => [
            [1000 => [qw/Albescu Aldea Baciu Barbaneagra Botezatu Ciobanu Creţu Dascălu Dragavei Fieraru Florescu Iordanescu Ioveanu Lupu Mitrea Popa Popescu/]],
        ],
    );

    $family_names{"Song Empire"} = $family_names{China};
    $family_names{"Ming Empire"} = $family_names{China};
    $family_names{"Qing Empire"} = $family_names{China};
    $family_names{"Qing China"} = $family_names{China};
    $family_names{"India"} = $family_names{"Delhi Sultanate"};
    $family_names{"Mughal Empire"} = $family_names{"Delhi Sultanate"};
    $family_names{"Maratha Empire"} = $family_names{"Delhi Sultanate"};

    $family_names{"United States of America"} = $family_names{"British Empire"};
    $family_names{"United States"} = $family_names{"British Empire"};
    $family_names{"Italy"} = $family_names{"Republic of Venice"};
    $family_names{"Mexico"} = $family_names{"Spain"};
    $family_names{"Austria-Hungary"} = $family_names{"Holy Roman Empire"};

    push @{$family_names{"Holy Roman Empire"}->[0]->[1]},
        @{$family_names{"France"}->[0]->[1]};

    $family_names{"Russia"} = $family_names{"Kievan Rus"};
    $family_names{"Soviet Union"} = $family_names{"Russia"};

    $family_names{"Germany"} = $family_names{"Holy Roman Empire"};
    $family_names{"Prussia"} = $family_names{"Germany"};

    $family_names{"Iberian Union"} = $family_names{"Spain"};
    $family_names{"Japan"} = $family_names{"Tokugawa Shogunat"};

    sub normal_rand {
        my ($self, $mean, $stddev) = @_;
        my $gen = rand_nd_generator($mean, $stddev);

        $gen->()
    }

    sub pick_option_by_year {
        my ($self, $table, $year) = @_;

        die "Empty options table for $year" unless $table;

        my $i = 0;
        until (!$table->[$i] || $table->[$i]->[0] > $year) {
            ++$i;
        }

        $table->[$i - 1]->[1]->[rand @{$table->[$i - 1]->[1]}]
    }

    sub gen_given_name {
        my ($self, $gender, $place, $year) = @_;

        $self->pick_option_by_year($given_names{$place}->{$gender}, $year)
    }

    sub gen_family_name {
        my ($self, $gender, $place, $year) = @_;

        $self->pick_option_by_year($family_names{$place}, $year)
    }

    sub gen_random_place {
        my ($self, $year) = @_;
        $self->pick_option_by_year(\@places, $year)
    }

    sub gen_life_expectancy {
        my ($self, $person) = @_;

        my ($year, $gender) = ($person->birthdate->year, $person->gender);
        my ($mean, $sd);

        my $child_death;

        if ($year < 1500) {
            $child_death = rand() > 0.6;
        }
        elsif ($year < 1700) {
            $child_death = rand() > 0.7;
        }
        elsif ($year < 1800) {
            $child_death = rand() > 0.8;
        }
        elsif ($year < 1950) {
            $child_death = rand() > 0.9;
        }
        else {
            $child_death = rand() > 0.99;
        }

        if ($child_death) {
            return int(rand(14));
        }

        if ($year < 1700) {
            ($mean, $sd) = (40, 9);
        }
        elsif ($year < 1800) {
            ($mean, $sd) = (50, 9);
        }
        elsif ($year < 1900) {
            ($mean, $sd) = (60, 9);
        }
        else {
            ($mean, $sd) = (80, 9);
        }

        if ($gender eq 'female') {
            $mean += 10;
        }

        max($self->normal_rand($mean * 365, $sd * 365), 0)
    }

    sub gen_move_prob {
        my ($self, $person) = @_;

        my $year = $person->birthdate->year;

        if ($year < 1600) {
            return 0.2;
        }
        else {
            return 0.4;
        }
    }

    sub gen_puberty_age {
        my ($self, $person) = @_;

        my ($year, $gender) = ($person->birthdate->year, $person->gender);
        my ($mean, $sd);

        if ($gender eq 'female') {
            $mean = 11;
        } else {
            $mean = 13;
        }

        if ($year > 1850) {
            $mean += 3;
            $sd = 2;
        } else {
            $sd = 1;
        }

        max($self->normal_rand($mean * 365, $sd * 365), 0)
    }

    sub gen_marriages {
        my ($self, $person) = @_;

        my ($year, $gender) = ($person->birthdate->year, $person->gender);
        my ($mean, $sd);

        if ($year < 1900) {
            ($mean, $sd) = (1.8, 0.4);
        } else {
            ($mean, $sd) = (2.5, 1);
        }

        int($self->normal_rand($mean, $sd))
    }

    sub gen_husband_surname_prob {
        my ($self, $person) = @_;
        my $year = $person->birthdate->year;

        if ($year < 1900) {
            return 0.9;
        } else {
            return 0.7;
        }
    }

    sub gen_dating_time {
        my ($self, $person) = @_;

        my ($year, $gender) = ($person->birthdate->year, $person->gender);
        my ($mean, $sd);

        if ($year < 1700) {
            ($mean, $sd) = (2, 0.5);
        } elsif ($year < 1800) {
            ($mean, $sd) = (2, 1);
        } elsif ($year < 1900) {
            ($mean, $sd) = (3, 1);
        } else {
            ($mean, $sd) = (5, 3);
        }

        max($self->normal_rand($mean * 365, $sd * 365), 1)
    }

    # number of children born in a marriage
    sub gen_fertility {
        my ($self, $person) = @_;

        my ($year, $gender) = ($person->birthdate->year, $person->gender);
        my ($mean, $sd);

        # childless marriage because reasons
        # if (rand() > 0.9) {
        #     return 0;
        # }

        if ($year < 1600) {
            ($mean, $sd) = (4, 3);
        }
        elsif ($year < 1800) {
            ($mean, $sd) = (2, 1);
        }
        else {
            ($mean, $sd) = (1, 1);
        }

        max(int($self->normal_rand($mean, $sd)), 0)
    }

    sub gen_twins_prob {
        my ($self, $person) = @_;
        my $year = $person->birthdate->year;

        if ($year < 1900) {
            return 0.01;
        } else {
            return 0.03;
        }
    }

    sub gen_time_to_child {
        my ($self, $person) = @_;

        my ($year, $gender) = ($person->birthdate->year, $person->gender);
        my ($mean, $sd);

        if ($year < 1700) {
            ($mean, $sd) = (1.5, 0.5);
        }
        elsif ($year < 1800) {
            ($mean, $sd) = (2, 0.5);
        }
        elsif ($year < 1900) {
            ($mean, $sd) = (3, 1);
        }
        else {
            ($mean, $sd) = (5, 2);
        }

        # "1" to make sure spouse assignment happens before this
        max($self->normal_rand($mean * 365, $sd * 365), 1)
    }

    sub gen_life_after_children {
        my ($self, $person) = @_;

        my ($year, $gender) = ($person->birthdate->year, $person->gender);
        my ($mean, $sd);

        if ($year < 1700) {
            ($mean, $sd) = (4, 2);
        }
        else {
            ($mean, $sd) = (10, 4);
        }

        # 1 because I need to have the last child be born before breakup
        max($self->normal_rand($mean * 365, $sd * 365), 1)
    }
}

1;
