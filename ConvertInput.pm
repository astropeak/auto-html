# Convert input to a tree representation for internal use.
#
# How to run:
# perl convert-input.pl input
package ConvertInput;
use Aspk::Tree;
use Aspk::Utils;
use Aspk::Debug;

use Exporter;

@ISA=qw(Exporter);
@EXPORT_OK=qw(build_element_tree);

sub get_input {
    my ($file) = @_;
    open my $fh, '<', $file or die "Can' open file $file";

    my @all_input_lines = <$fh>;
    my $regexp_id = qr/(?:[rc][0-9]{1,10}){1,100}/;
    my @grid= grep {/^\s*$regexp_id\s*$/} @all_input_lines;

    my @property= grep {/^\s*($regexp_id|root)\.(\w+)/} @all_input_lines;
    @property= map {/^\s*($regexp_id|root)\.(\w+)\s+([^\r\n]*)\s*$/;
                    {id=>$1, name=>$2, value=>eval $3}} @property;
    my %ppp;
    foreach (@property){
        $ppp{$_->{id}}->{$_->{name}} = $_->{value};
    }

    dbgm \@grid \%ppp;
    return {grid=>\@grid, property=>\%ppp};
}

sub build_element_tree{
    my ($file, $width, $height) = @_;
    my $input = get_input($file);
    dbgl $input;

    my $t = createGridTree($input->{grid}, $width, $height);
    calculateWidthAndHeight({node=>$t, property=>$input->{property}});

    # add all property
    $t->traverse({prefunc=>
                      sub{
                          my $para = shift;
                          my $data = $para->{data};
                          my $id = $data->{id};

                          while (my ($k, $v) = each %{$input->{property}->{$id}}) {
                              $data->{$k} = $v;
                          }
                  }});

    dbgm $t;
    return $t;
}

sub createGridTree{
    my ($grid_info, $width, $height) = @_;

    # print_obj(\@g);
    # chomp @g;
    # print @g;
    # print "\nTTTT:\n";

    my $rn = Aspk::Tree->new({data=>{id=>"root",width=>$width,height=>$height}});
    my %elements=();
    foreach my $i (@{$grid_info}){
        # chomp $i;
        # print;
        # $i =~ s/\n$//;

        $i =~ m/(.*)([rc][0-9]{1,10})[ \n]*/; ## After matched, seems $i will be corrupted.
        my ($parent, $child)=($1,$2);
        $i=$parent.$child;
        my $parentNode;
        if ($parent eq ""){
            $parentNode=$rn;
        } else {
            die "Parent node not exist for element $i." if (!exists($elements{$parent}));
            $parentNode=$elements{$parent};
        }
        # print "i: $i, parent: $parent, child: $child \n";
        $elements{$i} = Aspk::Tree->new({data=>{id=>$i},
                                         parent=>$parentNode});

    }
    # foreach my $j (keys(%elements)){
    # print "CCC: key: $j, value: $elements{$j}->{data}->{id}. DDD. \n";
    # }
    return $rn;
}


sub calculateWidthAndHeight{
    dbgl "Enter calculateWidthAndHeight\n";

    my $para=shift;
    my $node =$para->{node};
    my $property =$para->{property};
    my $data=$node->prop(data);
    my $children=$node->prop(children);
    if (@{$children}>0) {
        my $tmp = $property->{$node->prop(data)->{id}};
        dbgl $node->prop(data)->{id};
        dbgl($tmp->{divide});
        my @divides = @{$tmp->{divide}} || map {1} @{$children};
        if (exists $tmp->{divide}) {
            @divides = map {$_} @{$tmp->{divide}};
        } else {
            @divides = map {1} @{$children};
        }

        dbgl \@divides, $children;

        die "Divides size not match. " if @divides != @{$children};
        my $total = Aspk::Utils::reduce(@divides);
        my @ddd = map {$_/$total} @divides;

        if (@{$children}[0]->prop(data)->{id} =~ m/.*c[0-9]{1,10}$/) {
            # node is column
            for(my $i=0;$i<@{$children};$i++) {
                die "Parent width not given: $data->{id}." if (!exists($data->{width}));
                $children->[$i]->prop(data)->{width} = $data->{width} * $ddd[$i];
                $children->[$i]->prop(data)->{height} = $data->{height};
            }
        } else {
            # parent is row
            for(my $i=0;$i<@{$children};$i++) {
                # die "Parent width not given: $data->{id}." if (!exists($data->{width}));
                $children->[$i]->prop(data)->{width} = $data->{width};
                $children->[$i]->prop(data)->{height} = $data->{height} * $ddd[$i];
            }
        }

        foreach my $n (@{$children}){
            calculateWidthAndHeight({node=>$n, property=>$property});
        }
    }
}
