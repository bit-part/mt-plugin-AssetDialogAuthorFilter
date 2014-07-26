# AssetDialogAuthorFilter
# Copyright (c) bit part LLC - http://bit-part.net/
package MT::Plugin::AssetDialogAuthorFilter;
use strict;
use base qw( MT::Plugin );

our $VERSION = '1.1.1';

my $plugin = MT::Plugin::AssetDialogAuthorFilter->new({
    id          => 'AssetDialogAuthorFilter',
    name        => 'AssetDialogAuthorFilter',
    description => '<__trans phrase="Filter by a login user at a dialog of assets in edit entry.">',
    version     => $VERSION,
    author_name => '<__trans phrase="bit part LLC">',
    author_link => 'http://bit-part.net/',
    plugin_link => 'https://github.com/bit-part/mt-plugin-AssetDialogAuthorFilter',
    doc_link    => 'https://github.com/bit-part/mt-plugin-AssetDialogAuthorFilter/blob/master/README.md',
    l10n_class  => 'AssetDialogAuthorFilter::L10N',
});
MT->add_plugin($plugin);

sub init {
    my $core = MT->component('core');
    my $registry = $core->registry('applications', 'cms', 'methods');
    $registry->{dialog_list_asset} = '$AssetDialogAuthorFilter::AssetDialogAuthorFilter::Plugin::_dialog_list_asset',;
}

1;
