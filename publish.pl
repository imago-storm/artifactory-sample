use strict;
use warnings;
use File::Basename qw(dirname);

my $dir = dirname $0;
print "Dir: $dir\n";

my $artifactoryUrl = $ARGV[0] or die "No artifactory url is provided";

my @versions = qw(
    1.2.0
    1.1.0
    1.5.0
    1.6.0
    1.6.1
);

my $releaseRepo = 'libs-release-local';
my $snapshotRepo = 'libs-snapshot-local';
my $artifact = 'sample';

for my $version (@versions) {
    generateProperties($version, $releaseRepo, $artifact);
    publish();
    generateProperties("$version-SNAPSHOT", $snapshotRepo, $artifact);
    publish();
    publish();
    publish();
    publish();
    generateProperties("$version-H5-SNAPSHOT", $snapshotRepo, $artifact);
    publish();
}


sub publish {
    my $output = `gradle build publish`;
    if ($? != 0) {
        die $output;
    }
    print $output . "\n";
}

sub generateProperties {
    my ($version, $repo, $artifactId) = @_;

    open my $fh, '>' . $dir . '/gradle.properties' or die "Cannot open gradle.properties: $!";
    my $url = $artifactoryUrl;
    if ($url !~ /\/$/) {
        $url .= "/";
    }
    $url .= $repo;
    print $fh "artifactoryUrl=$url\n";
    print $fh "externalVersion=$version\n";
    print $fh "externalArtifactId=$artifactId\n";
    close $fh;
}
