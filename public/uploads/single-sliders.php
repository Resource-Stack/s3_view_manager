<?php if ( ! defined( 'ABSPATH' ) ) { die( 'Direct access forbidden.' ); }
/**
 * The Template for displaying sliders preview
 * Slider preview uses full-width page without any elements
 */

add_filter('gomoto_navbar_layout', function() { return 'disabled'; } );
add_filter('gomoto_pageheader_layout', function() { return 'disabled'; } );
add_filter('gomoto_footer_cols_num', function() { return 0; } );
add_filter('gomoto_copyright_layout', function() { return 'disabled'; } );

remove_action( 'gomoto_wrapper_open', 'gomoto_wrapper_open' );
remove_action( 'gomoto_wrapper_close', 'gomoto_wrapper_close' );

if ( function_exists( 'FW' ) ) {

	add_filter ('gomoto_current_scheme', function() {
		global $wp_query;	

		$current_page_scheme = fw_get_db_post_option( $wp_query->get_queried_object_id(), 'color-scheme' );
		if ($current_page_scheme == 'default') {

			$current_page_scheme = 1; 
		}
		return $current_page_scheme; 
	} );
}

get_header();

?>
<div class="lte-text-page lte-slider-preview">
	<?php
	while ( have_posts() ) : 

		the_post();

		get_template_part( 'tmpl/content', 'page' );

	endwhile;
	?>
</div>
<?php

get_footer();
