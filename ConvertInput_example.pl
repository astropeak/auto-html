use ConvertInput qw(build_element_tree);
use Aspk::debug qw(printHash);

my $t=build_element_tree("./input");
print "\nbuild_element_tree:\n";
printHash($t);


# The two functions also works
# my $rn=ConvertInput::createGridTree("./input");
# print "\nAfter created:\n";
# printHash($rn);

# ConvertInput::calculateWidthAndHeight({node=>$rn});
# print "\nAfter calculating:\n";
# printHash($rn);