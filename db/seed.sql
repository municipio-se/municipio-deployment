-- -------------------------------------------------------------
-- TablePlus 5.3.8(500)
--
-- https://tableplus.com/
--
-- Database: dev
-- Generation Time: 2023-08-10 14:47:52.4050
-- -------------------------------------------------------------


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


DROP TABLE IF EXISTS `mun_2_commentmeta`;
CREATE TABLE `mun_2_commentmeta` (
  `meta_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `comment_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `comment_id` (`comment_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_2_comments`;
CREATE TABLE `mun_2_comments` (
  `comment_ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `comment_post_ID` bigint(20) unsigned NOT NULL DEFAULT '0',
  `comment_author` tinytext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `comment_author_email` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_author_url` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_author_IP` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `comment_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `comment_content` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `comment_karma` int(11) NOT NULL DEFAULT '0',
  `comment_approved` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '1',
  `comment_agent` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_type` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'comment',
  `comment_parent` bigint(20) unsigned NOT NULL DEFAULT '0',
  `user_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`comment_ID`),
  KEY `comment_post_ID` (`comment_post_ID`),
  KEY `comment_approved_date_gmt` (`comment_approved`,`comment_date_gmt`),
  KEY `comment_date_gmt` (`comment_date_gmt`),
  KEY `comment_parent` (`comment_parent`),
  KEY `comment_author_email` (`comment_author_email`(10))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_2_links`;
CREATE TABLE `mun_2_links` (
  `link_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `link_url` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_image` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_target` varchar(25) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_description` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_visible` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'Y',
  `link_owner` bigint(20) unsigned NOT NULL DEFAULT '1',
  `link_rating` int(11) NOT NULL DEFAULT '0',
  `link_updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `link_rel` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_notes` mediumtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `link_rss` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`link_id`),
  KEY `link_visible` (`link_visible`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_2_options`;
CREATE TABLE `mun_2_options` (
  `option_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `option_name` varchar(191) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `option_value` longtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `autoload` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'yes',
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `option_name` (`option_name`),
  KEY `autoload` (`autoload`)
) ENGINE=InnoDB AUTO_INCREMENT=134 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_2_postmeta`;
CREATE TABLE `mun_2_postmeta` (
  `meta_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `post_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `post_id` (`post_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_2_posts`;
CREATE TABLE `mun_2_posts` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `post_author` bigint(20) unsigned NOT NULL DEFAULT '0',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content` longtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_title` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_excerpt` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_status` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'publish',
  `comment_status` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'open',
  `ping_status` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'open',
  `post_password` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `post_name` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `to_ping` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `pinged` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_modified_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content_filtered` longtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_parent` bigint(20) unsigned NOT NULL DEFAULT '0',
  `guid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `menu_order` int(11) NOT NULL DEFAULT '0',
  `post_type` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'post',
  `post_mime_type` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_count` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `post_name` (`post_name`(191)),
  KEY `type_status_date` (`post_type`,`post_status`,`post_date`,`ID`),
  KEY `post_parent` (`post_parent`),
  KEY `post_author` (`post_author`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_2_term_relationships`;
CREATE TABLE `mun_2_term_relationships` (
  `object_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `term_taxonomy_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `term_order` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`object_id`,`term_taxonomy_id`),
  KEY `term_taxonomy_id` (`term_taxonomy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_2_term_taxonomy`;
CREATE TABLE `mun_2_term_taxonomy` (
  `term_taxonomy_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `term_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `taxonomy` varchar(32) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `description` longtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `parent` bigint(20) unsigned NOT NULL DEFAULT '0',
  `count` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`term_taxonomy_id`),
  UNIQUE KEY `term_id_taxonomy` (`term_id`,`taxonomy`),
  KEY `taxonomy` (`taxonomy`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_2_termmeta`;
CREATE TABLE `mun_2_termmeta` (
  `meta_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `term_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `term_id` (`term_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_2_terms`;
CREATE TABLE `mun_2_terms` (
  `term_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `slug` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `term_group` bigint(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`term_id`),
  KEY `slug` (`slug`(191)),
  KEY `name` (`name`(191))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_attachment_relationships`;
CREATE TABLE `mun_attachment_relationships` (
  `relation_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `attachment_id` bigint(20) unsigned NOT NULL,
  `object_id` bigint(20) unsigned DEFAULT NULL,
  `relation_type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`relation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_blogmeta`;
CREATE TABLE `mun_blogmeta` (
  `meta_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `blog_id` bigint(20) NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `meta_key` (`meta_key`(191)),
  KEY `blog_id` (`blog_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_blogs`;
CREATE TABLE `mun_blogs` (
  `blog_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `site_id` bigint(20) NOT NULL DEFAULT '0',
  `domain` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `path` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `registered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `last_updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `public` tinyint(2) NOT NULL DEFAULT '1',
  `archived` tinyint(2) NOT NULL DEFAULT '0',
  `mature` tinyint(2) NOT NULL DEFAULT '0',
  `spam` tinyint(2) NOT NULL DEFAULT '0',
  `deleted` tinyint(2) NOT NULL DEFAULT '0',
  `lang_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`blog_id`),
  KEY `domain` (`domain`(50),`path`(5)),
  KEY `lang_id` (`lang_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_broken_links_detector`;
CREATE TABLE `mun_broken_links_detector` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `post_id` bigint(20) DEFAULT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `time` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_commentmeta`;
CREATE TABLE `mun_commentmeta` (
  `meta_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `comment_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `comment_id` (`comment_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_comments`;
CREATE TABLE `mun_comments` (
  `comment_ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `comment_post_ID` bigint(20) unsigned NOT NULL DEFAULT '0',
  `comment_author` tinytext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `comment_author_email` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_author_url` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_author_IP` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `comment_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `comment_content` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `comment_karma` int(11) NOT NULL DEFAULT '0',
  `comment_approved` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '1',
  `comment_agent` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_type` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'comment',
  `comment_parent` bigint(20) unsigned NOT NULL DEFAULT '0',
  `user_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`comment_ID`),
  KEY `comment_post_ID` (`comment_post_ID`),
  KEY `comment_approved_date_gmt` (`comment_approved`,`comment_date_gmt`),
  KEY `comment_date_gmt` (`comment_date_gmt`),
  KEY `comment_parent` (`comment_parent`),
  KEY `comment_author_email` (`comment_author_email`(10))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_content_insights_for_editors`;
CREATE TABLE `mun_content_insights_for_editors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) DEFAULT NULL,
  `url_path` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `week_visitors` int(11) DEFAULT '0',
  `week_pageviews` int(11) DEFAULT '0',
  `month_visitors` int(11) DEFAULT '0',
  `month_pageviews` int(11) DEFAULT '0',
  `updated_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `post_id` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_integrate_occasions`;
CREATE TABLE `mun_integrate_occasions` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` bigint(20) unsigned NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `door_time` datetime DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `exception_information` varchar(400) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `content_mode` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `content` longtext COLLATE utf8mb4_unicode_520_ci,
  `location_mode` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `booking_link` varchar(400) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `location` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_links`;
CREATE TABLE `mun_links` (
  `link_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `link_url` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_image` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_target` varchar(25) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_description` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_visible` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'Y',
  `link_owner` bigint(20) unsigned NOT NULL DEFAULT '1',
  `link_rating` int(11) NOT NULL DEFAULT '0',
  `link_updated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `link_rel` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `link_notes` mediumtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `link_rss` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`link_id`),
  KEY `link_visible` (`link_visible`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_options`;
CREATE TABLE `mun_options` (
  `option_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `option_name` varchar(191) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `option_value` longtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `autoload` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'yes',
  PRIMARY KEY (`option_id`),
  UNIQUE KEY `option_name` (`option_name`),
  KEY `autoload` (`autoload`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_postmeta`;
CREATE TABLE `mun_postmeta` (
  `meta_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `post_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `post_id` (`post_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_posts`;
CREATE TABLE `mun_posts` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `post_author` bigint(20) unsigned NOT NULL DEFAULT '0',
  `post_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_date_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content` longtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_title` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_excerpt` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_status` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'publish',
  `comment_status` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'open',
  `ping_status` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'open',
  `post_password` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `post_name` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `to_ping` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `pinged` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_modified_gmt` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `post_content_filtered` longtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `post_parent` bigint(20) unsigned NOT NULL DEFAULT '0',
  `guid` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `menu_order` int(11) NOT NULL DEFAULT '0',
  `post_type` varchar(20) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'post',
  `post_mime_type` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `comment_count` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `post_name` (`post_name`(191)),
  KEY `type_status_date` (`post_type`,`post_status`,`post_date`,`ID`),
  KEY `post_parent` (`post_parent`),
  KEY `post_author` (`post_author`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_registration_log`;
CREATE TABLE `mun_registration_log` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `IP` varchar(30) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `blog_id` bigint(20) NOT NULL DEFAULT '0',
  `date_registered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`ID`),
  KEY `IP` (`IP`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_search_statistics_log`;
CREATE TABLE `mun_search_statistics_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `query` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `results` bigint(20) NOT NULL DEFAULT '0',
  `site_id` bigint(20) DEFAULT NULL,
  `logged_in` tinyint(1) NOT NULL DEFAULT '0',
  `date_searched` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_signups`;
CREATE TABLE `mun_signups` (
  `signup_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `domain` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `path` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `title` longtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `user_login` varchar(60) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_email` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `registered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `activated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `activation_key` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `meta` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`signup_id`),
  KEY `activation_key` (`activation_key`),
  KEY `user_email` (`user_email`),
  KEY `user_login_email` (`user_login`,`user_email`),
  KEY `domain_path` (`domain`(140),`path`(51))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_site`;
CREATE TABLE `mun_site` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `domain` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `path` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `domain` (`domain`(140),`path`(51))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_sitemeta`;
CREATE TABLE `mun_sitemeta` (
  `meta_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `site_id` bigint(20) NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `meta_key` (`meta_key`(191)),
  KEY `site_id` (`site_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_term_relationships`;
CREATE TABLE `mun_term_relationships` (
  `object_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `term_taxonomy_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `term_order` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`object_id`,`term_taxonomy_id`),
  KEY `term_taxonomy_id` (`term_taxonomy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_term_taxonomy`;
CREATE TABLE `mun_term_taxonomy` (
  `term_taxonomy_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `term_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `taxonomy` varchar(32) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `description` longtext COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `parent` bigint(20) unsigned NOT NULL DEFAULT '0',
  `count` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`term_taxonomy_id`),
  UNIQUE KEY `term_id_taxonomy` (`term_id`,`taxonomy`),
  KEY `taxonomy` (`taxonomy`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_termmeta`;
CREATE TABLE `mun_termmeta` (
  `meta_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `term_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`meta_id`),
  KEY `term_id` (`term_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_terms`;
CREATE TABLE `mun_terms` (
  `term_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `slug` varchar(200) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `term_group` bigint(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`term_id`),
  KEY `slug` (`slug`(191)),
  KEY `name` (`name`(191))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_usermeta`;
CREATE TABLE `mun_usermeta` (
  `umeta_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `meta_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `meta_value` longtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`umeta_id`),
  KEY `user_id` (`user_id`),
  KEY `meta_key` (`meta_key`(191))
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

DROP TABLE IF EXISTS `mun_users`;
CREATE TABLE `mun_users` (
  `ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_login` varchar(60) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_pass` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_nicename` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_email` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_url` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_registered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `user_activation_key` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `user_status` int(11) NOT NULL DEFAULT '0',
  `display_name` varchar(250) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '',
  `spam` tinyint(2) NOT NULL DEFAULT '0',
  `deleted` tinyint(2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `user_login_key` (`user_login`),
  KEY `user_nicename` (`user_nicename`),
  KEY `user_email` (`user_email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

INSERT INTO `mun_2_comments` (`comment_ID`, `comment_post_ID`, `comment_author`, `comment_author_email`, `comment_author_url`, `comment_author_IP`, `comment_date`, `comment_date_gmt`, `comment_content`, `comment_karma`, `comment_approved`, `comment_agent`, `comment_type`, `comment_parent`, `user_id`) VALUES
(1, 1, 'A WordPress Commenter', 'wapuu@wordpress.example', 'https://dev.local.municipio.tech/', '', '2023-08-09 17:40:57', '2023-08-09 17:40:57', 'Hi, this is a comment.\nTo get started with moderating, editing, and deleting comments, please visit the Comments screen in the dashboard.\nCommenter avatars come from <a href=\"https://en.gravatar.com/\">Gravatar</a>.', 0, '1', '', 'comment', 0, 0);

INSERT INTO `mun_2_options` (`option_id`, `option_name`, `option_value`, `autoload`) VALUES
(1, 'siteurl', 'https://dev.local.municipio.tech/wp', 'yes'),
(2, 'home', 'https://dev.local.municipio.tech/dev-one', 'yes'),
(3, 'blogname', 'Municipio Dev One', 'yes'),
(4, 'blogdescription', '', 'yes'),
(5, 'users_can_register', '0', 'yes'),
(6, 'admin_email', 'superadmin@local.municipio.tech', 'yes'),
(7, 'start_of_week', '1', 'yes'),
(8, 'use_balanceTags', '0', 'yes'),
(9, 'use_smilies', '1', 'yes'),
(10, 'require_name_email', '1', 'yes'),
(11, 'comments_notify', '1', 'yes'),
(12, 'posts_per_rss', '10', 'yes'),
(13, 'rss_use_excerpt', '0', 'yes'),
(14, 'mailserver_url', 'mail.example.com', 'yes'),
(15, 'mailserver_login', 'login@example.com', 'yes'),
(16, 'mailserver_pass', 'password', 'yes'),
(17, 'mailserver_port', '110', 'yes'),
(18, 'default_category', '1', 'yes'),
(19, 'default_comment_status', 'open', 'yes'),
(20, 'default_ping_status', 'open', 'yes'),
(21, 'default_pingback_flag', '1', 'yes'),
(22, 'posts_per_page', '10', 'yes'),
(23, 'date_format', 'F j, Y', 'yes'),
(24, 'time_format', 'g:i a', 'yes'),
(25, 'links_updated_date_format', 'F j, Y g:i a', 'yes'),
(26, 'comment_moderation', '0', 'yes'),
(27, 'moderation_notify', '1', 'yes'),
(28, 'permalink_structure', '/%year%/%monthnum%/%day%/%postname%/', 'yes'),
(29, 'rewrite_rules', 'a:94:{s:11:\"^wp-json/?$\";s:22:\"index.php?rest_route=/\";s:14:\"^wp-json/(.*)?\";s:33:\"index.php?rest_route=/$matches[1]\";s:21:\"^index.php/wp-json/?$\";s:22:\"index.php?rest_route=/\";s:24:\"^index.php/wp-json/(.*)?\";s:33:\"index.php?rest_route=/$matches[1]\";s:17:\"^wp-sitemap\\.xml$\";s:23:\"index.php?sitemap=index\";s:17:\"^wp-sitemap\\.xsl$\";s:36:\"index.php?sitemap-stylesheet=sitemap\";s:23:\"^wp-sitemap-index\\.xsl$\";s:34:\"index.php?sitemap-stylesheet=index\";s:48:\"^wp-sitemap-([a-z]+?)-([a-z\\d_-]+?)-(\\d+?)\\.xml$\";s:75:\"index.php?sitemap=$matches[1]&sitemap-subtype=$matches[2]&paged=$matches[3]\";s:34:\"^wp-sitemap-([a-z]+?)-(\\d+?)\\.xml$\";s:47:\"index.php?sitemap=$matches[1]&paged=$matches[2]\";s:52:\"blog/category/(.+?)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:52:\"index.php?category_name=$matches[1]&feed=$matches[2]\";s:47:\"blog/category/(.+?)/(feed|rdf|rss|rss2|atom)/?$\";s:52:\"index.php?category_name=$matches[1]&feed=$matches[2]\";s:28:\"blog/category/(.+?)/embed/?$\";s:46:\"index.php?category_name=$matches[1]&embed=true\";s:40:\"blog/category/(.+?)/page/?([0-9]{1,})/?$\";s:53:\"index.php?category_name=$matches[1]&paged=$matches[2]\";s:22:\"blog/category/(.+?)/?$\";s:35:\"index.php?category_name=$matches[1]\";s:49:\"blog/tag/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?tag=$matches[1]&feed=$matches[2]\";s:44:\"blog/tag/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?tag=$matches[1]&feed=$matches[2]\";s:25:\"blog/tag/([^/]+)/embed/?$\";s:36:\"index.php?tag=$matches[1]&embed=true\";s:37:\"blog/tag/([^/]+)/page/?([0-9]{1,})/?$\";s:43:\"index.php?tag=$matches[1]&paged=$matches[2]\";s:19:\"blog/tag/([^/]+)/?$\";s:25:\"index.php?tag=$matches[1]\";s:50:\"blog/type/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?post_format=$matches[1]&feed=$matches[2]\";s:45:\"blog/type/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?post_format=$matches[1]&feed=$matches[2]\";s:26:\"blog/type/([^/]+)/embed/?$\";s:44:\"index.php?post_format=$matches[1]&embed=true\";s:38:\"blog/type/([^/]+)/page/?([0-9]{1,})/?$\";s:51:\"index.php?post_format=$matches[1]&paged=$matches[2]\";s:20:\"blog/type/([^/]+)/?$\";s:33:\"index.php?post_format=$matches[1]\";s:48:\".*wp-(atom|rdf|rss|rss2|feed|commentsrss2)\\.php$\";s:18:\"index.php?feed=old\";s:20:\".*wp-app\\.php(/.*)?$\";s:19:\"index.php?error=403\";s:18:\".*wp-register.php$\";s:23:\"index.php?register=true\";s:32:\"feed/(feed|rdf|rss|rss2|atom)/?$\";s:27:\"index.php?&feed=$matches[1]\";s:27:\"(feed|rdf|rss|rss2|atom)/?$\";s:27:\"index.php?&feed=$matches[1]\";s:8:\"embed/?$\";s:21:\"index.php?&embed=true\";s:20:\"page/?([0-9]{1,})/?$\";s:28:\"index.php?&paged=$matches[1]\";s:41:\"comments/feed/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?&feed=$matches[1]&withcomments=1\";s:36:\"comments/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?&feed=$matches[1]&withcomments=1\";s:17:\"comments/embed/?$\";s:21:\"index.php?&embed=true\";s:44:\"search/(.+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:40:\"index.php?s=$matches[1]&feed=$matches[2]\";s:39:\"search/(.+)/(feed|rdf|rss|rss2|atom)/?$\";s:40:\"index.php?s=$matches[1]&feed=$matches[2]\";s:20:\"search/(.+)/embed/?$\";s:34:\"index.php?s=$matches[1]&embed=true\";s:32:\"search/(.+)/page/?([0-9]{1,})/?$\";s:41:\"index.php?s=$matches[1]&paged=$matches[2]\";s:14:\"search/(.+)/?$\";s:23:\"index.php?s=$matches[1]\";s:47:\"author/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?author_name=$matches[1]&feed=$matches[2]\";s:42:\"author/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?author_name=$matches[1]&feed=$matches[2]\";s:23:\"author/([^/]+)/embed/?$\";s:44:\"index.php?author_name=$matches[1]&embed=true\";s:35:\"author/([^/]+)/page/?([0-9]{1,})/?$\";s:51:\"index.php?author_name=$matches[1]&paged=$matches[2]\";s:17:\"author/([^/]+)/?$\";s:33:\"index.php?author_name=$matches[1]\";s:69:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/feed/(feed|rdf|rss|rss2|atom)/?$\";s:80:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&feed=$matches[4]\";s:64:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/(feed|rdf|rss|rss2|atom)/?$\";s:80:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&feed=$matches[4]\";s:45:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/embed/?$\";s:74:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&embed=true\";s:57:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/page/?([0-9]{1,})/?$\";s:81:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&paged=$matches[4]\";s:39:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/?$\";s:63:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]\";s:56:\"([0-9]{4})/([0-9]{1,2})/feed/(feed|rdf|rss|rss2|atom)/?$\";s:64:\"index.php?year=$matches[1]&monthnum=$matches[2]&feed=$matches[3]\";s:51:\"([0-9]{4})/([0-9]{1,2})/(feed|rdf|rss|rss2|atom)/?$\";s:64:\"index.php?year=$matches[1]&monthnum=$matches[2]&feed=$matches[3]\";s:32:\"([0-9]{4})/([0-9]{1,2})/embed/?$\";s:58:\"index.php?year=$matches[1]&monthnum=$matches[2]&embed=true\";s:44:\"([0-9]{4})/([0-9]{1,2})/page/?([0-9]{1,})/?$\";s:65:\"index.php?year=$matches[1]&monthnum=$matches[2]&paged=$matches[3]\";s:26:\"([0-9]{4})/([0-9]{1,2})/?$\";s:47:\"index.php?year=$matches[1]&monthnum=$matches[2]\";s:43:\"([0-9]{4})/feed/(feed|rdf|rss|rss2|atom)/?$\";s:43:\"index.php?year=$matches[1]&feed=$matches[2]\";s:38:\"([0-9]{4})/(feed|rdf|rss|rss2|atom)/?$\";s:43:\"index.php?year=$matches[1]&feed=$matches[2]\";s:19:\"([0-9]{4})/embed/?$\";s:37:\"index.php?year=$matches[1]&embed=true\";s:31:\"([0-9]{4})/page/?([0-9]{1,})/?$\";s:44:\"index.php?year=$matches[1]&paged=$matches[2]\";s:13:\"([0-9]{4})/?$\";s:26:\"index.php?year=$matches[1]\";s:58:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:68:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:88:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:83:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:83:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:64:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/attachment/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:53:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/embed/?$\";s:91:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&embed=true\";s:57:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/trackback/?$\";s:85:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&tb=1\";s:77:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:97:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&feed=$matches[5]\";s:72:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:97:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&feed=$matches[5]\";s:65:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/page/?([0-9]{1,})/?$\";s:98:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&paged=$matches[5]\";s:72:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)/comment-page-([0-9]{1,})/?$\";s:98:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&cpage=$matches[5]\";s:61:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/([^/]+)(?:/([0-9]+))?/?$\";s:97:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&name=$matches[4]&page=$matches[5]\";s:47:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:57:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:77:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:72:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:72:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:53:\"[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}/[^/]+/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:64:\"([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/comment-page-([0-9]{1,})/?$\";s:81:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&cpage=$matches[4]\";s:51:\"([0-9]{4})/([0-9]{1,2})/comment-page-([0-9]{1,})/?$\";s:65:\"index.php?year=$matches[1]&monthnum=$matches[2]&cpage=$matches[3]\";s:38:\"([0-9]{4})/comment-page-([0-9]{1,})/?$\";s:44:\"index.php?year=$matches[1]&cpage=$matches[2]\";s:27:\".?.+?/attachment/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:37:\".?.+?/attachment/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:57:\".?.+?/attachment/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:52:\".?.+?/attachment/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:52:\".?.+?/attachment/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:33:\".?.+?/attachment/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:16:\"(.?.+?)/embed/?$\";s:41:\"index.php?pagename=$matches[1]&embed=true\";s:20:\"(.?.+?)/trackback/?$\";s:35:\"index.php?pagename=$matches[1]&tb=1\";s:40:\"(.?.+?)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:47:\"index.php?pagename=$matches[1]&feed=$matches[2]\";s:35:\"(.?.+?)/(feed|rdf|rss|rss2|atom)/?$\";s:47:\"index.php?pagename=$matches[1]&feed=$matches[2]\";s:28:\"(.?.+?)/page/?([0-9]{1,})/?$\";s:48:\"index.php?pagename=$matches[1]&paged=$matches[2]\";s:35:\"(.?.+?)/comment-page-([0-9]{1,})/?$\";s:48:\"index.php?pagename=$matches[1]&cpage=$matches[2]\";s:24:\"(.?.+?)(?:/([0-9]+))?/?$\";s:47:\"index.php?pagename=$matches[1]&page=$matches[2]\";}', 'yes'),
(30, 'hack_file', '0', 'yes'),
(31, 'blog_charset', 'UTF-8', 'yes'),
(32, 'moderation_keys', '', 'no'),
(33, 'active_plugins', 'a:0:{}', 'yes'),
(34, 'category_base', '', 'yes'),
(35, 'ping_sites', 'http://rpc.pingomatic.com/', 'yes'),
(36, 'comment_max_links', '2', 'yes'),
(37, 'gmt_offset', '0', 'yes'),
(38, 'default_email_category', '1', 'yes'),
(39, 'recently_edited', '', 'no'),
(40, 'template', 'municipio', 'yes'),
(41, 'stylesheet', 'municipio', 'yes'),
(42, 'comment_registration', '0', 'yes'),
(43, 'html_type', 'text/html', 'yes'),
(44, 'use_trackback', '0', 'yes'),
(45, 'default_role', 'subscriber', 'yes'),
(46, 'db_version', '53496', 'yes'),
(47, 'uploads_use_yearmonth_folders', '1', 'yes'),
(48, 'upload_path', '/Users/seno1000/www/public/dev/wp-content/uploads/networks/1', 'yes'),
(49, 'blog_public', '1', 'yes'),
(50, 'default_link_category', '2', 'yes'),
(51, 'show_on_front', 'posts', 'yes'),
(52, 'tag_base', '', 'yes'),
(53, 'show_avatars', '1', 'yes'),
(54, 'avatar_rating', 'G', 'yes'),
(55, 'upload_url_path', 'https://dev.local.municipio.tech/wp-content/uploads/networks/1', 'yes'),
(56, 'thumbnail_size_w', '150', 'yes'),
(57, 'thumbnail_size_h', '150', 'yes'),
(58, 'thumbnail_crop', '1', 'yes'),
(59, 'medium_size_w', '300', 'yes'),
(60, 'medium_size_h', '300', 'yes'),
(61, 'avatar_default', 'mystery', 'yes'),
(62, 'large_size_w', '1024', 'yes'),
(63, 'large_size_h', '1024', 'yes'),
(64, 'image_default_link_type', 'none', 'yes'),
(65, 'image_default_size', '', 'yes'),
(66, 'image_default_align', '', 'yes'),
(67, 'close_comments_for_old_posts', '0', 'yes'),
(68, 'close_comments_days_old', '14', 'yes'),
(69, 'thread_comments', '1', 'yes'),
(70, 'thread_comments_depth', '5', 'yes'),
(71, 'page_comments', '0', 'yes'),
(72, 'comments_per_page', '50', 'yes'),
(73, 'default_comments_page', 'newest', 'yes'),
(74, 'comment_order', 'asc', 'yes'),
(75, 'sticky_posts', 'a:0:{}', 'yes'),
(76, 'widget_categories', 'a:0:{}', 'yes'),
(77, 'widget_text', 'a:0:{}', 'yes'),
(78, 'widget_rss', 'a:0:{}', 'yes'),
(79, 'uninstall_plugins', 'a:2:{s:27:\"media-usage/media-usage.php\";s:27:\"MediaTracker\\App::uninstall\";s:27:\"redirection/redirection.php\";a:2:{i:0;s:17:\"Redirection_Admin\";i:1;s:16:\"plugin_uninstall\";}}', 'no'),
(80, 'timezone_string', '', 'yes'),
(81, 'page_for_posts', '0', 'yes'),
(82, 'page_on_front', '0', 'yes'),
(83, 'default_post_format', '0', 'yes'),
(84, 'link_manager_enabled', '0', 'yes'),
(85, 'finished_splitting_shared_terms', '1', 'yes'),
(86, 'site_icon', '0', 'yes'),
(87, 'medium_large_size_w', '768', 'yes'),
(88, 'medium_large_size_h', '0', 'yes'),
(89, 'wp_page_for_privacy_policy', '0', 'yes'),
(90, 'show_comments_cookies_opt_in', '1', 'yes'),
(91, 'admin_email_lifespan', '1707154857', 'yes'),
(92, 'disallowed_keys', '', 'no'),
(93, 'comment_previously_approved', '1', 'yes'),
(94, 'auto_plugin_theme_update_emails', 'a:0:{}', 'no'),
(95, 'auto_update_core_dev', 'enabled', 'yes'),
(96, 'auto_update_core_minor', 'enabled', 'yes'),
(97, 'auto_update_core_major', 'enabled', 'yes'),
(98, 'wp_force_deactivated_plugins', 'a:0:{}', 'yes'),
(99, 'WPLANG', '', 'yes'),
(100, 'mun_2_user_roles', 'a:5:{s:13:\"administrator\";a:2:{s:4:\"name\";s:13:\"Administrator\";s:12:\"capabilities\";a:61:{s:13:\"switch_themes\";b:1;s:11:\"edit_themes\";b:1;s:16:\"activate_plugins\";b:1;s:12:\"edit_plugins\";b:1;s:10:\"edit_users\";b:1;s:10:\"edit_files\";b:1;s:14:\"manage_options\";b:1;s:17:\"moderate_comments\";b:1;s:17:\"manage_categories\";b:1;s:12:\"manage_links\";b:1;s:12:\"upload_files\";b:1;s:6:\"import\";b:1;s:15:\"unfiltered_html\";b:1;s:10:\"edit_posts\";b:1;s:17:\"edit_others_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:10:\"edit_pages\";b:1;s:4:\"read\";b:1;s:8:\"level_10\";b:1;s:7:\"level_9\";b:1;s:7:\"level_8\";b:1;s:7:\"level_7\";b:1;s:7:\"level_6\";b:1;s:7:\"level_5\";b:1;s:7:\"level_4\";b:1;s:7:\"level_3\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:17:\"edit_others_pages\";b:1;s:20:\"edit_published_pages\";b:1;s:13:\"publish_pages\";b:1;s:12:\"delete_pages\";b:1;s:19:\"delete_others_pages\";b:1;s:22:\"delete_published_pages\";b:1;s:12:\"delete_posts\";b:1;s:19:\"delete_others_posts\";b:1;s:22:\"delete_published_posts\";b:1;s:20:\"delete_private_posts\";b:1;s:18:\"edit_private_posts\";b:1;s:18:\"read_private_posts\";b:1;s:20:\"delete_private_pages\";b:1;s:18:\"edit_private_pages\";b:1;s:18:\"read_private_pages\";b:1;s:12:\"delete_users\";b:1;s:12:\"create_users\";b:1;s:17:\"unfiltered_upload\";b:1;s:14:\"edit_dashboard\";b:1;s:14:\"update_plugins\";b:1;s:14:\"delete_plugins\";b:1;s:15:\"install_plugins\";b:1;s:13:\"update_themes\";b:1;s:14:\"install_themes\";b:1;s:11:\"update_core\";b:1;s:10:\"list_users\";b:1;s:12:\"remove_users\";b:1;s:13:\"promote_users\";b:1;s:18:\"edit_theme_options\";b:1;s:13:\"delete_themes\";b:1;s:6:\"export\";b:1;}}s:6:\"editor\";a:2:{s:4:\"name\";s:6:\"Editor\";s:12:\"capabilities\";a:34:{s:17:\"moderate_comments\";b:1;s:17:\"manage_categories\";b:1;s:12:\"manage_links\";b:1;s:12:\"upload_files\";b:1;s:15:\"unfiltered_html\";b:1;s:10:\"edit_posts\";b:1;s:17:\"edit_others_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:10:\"edit_pages\";b:1;s:4:\"read\";b:1;s:7:\"level_7\";b:1;s:7:\"level_6\";b:1;s:7:\"level_5\";b:1;s:7:\"level_4\";b:1;s:7:\"level_3\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:17:\"edit_others_pages\";b:1;s:20:\"edit_published_pages\";b:1;s:13:\"publish_pages\";b:1;s:12:\"delete_pages\";b:1;s:19:\"delete_others_pages\";b:1;s:22:\"delete_published_pages\";b:1;s:12:\"delete_posts\";b:1;s:19:\"delete_others_posts\";b:1;s:22:\"delete_published_posts\";b:1;s:20:\"delete_private_posts\";b:1;s:18:\"edit_private_posts\";b:1;s:18:\"read_private_posts\";b:1;s:20:\"delete_private_pages\";b:1;s:18:\"edit_private_pages\";b:1;s:18:\"read_private_pages\";b:1;}}s:6:\"author\";a:2:{s:4:\"name\";s:6:\"Author\";s:12:\"capabilities\";a:10:{s:12:\"upload_files\";b:1;s:10:\"edit_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:4:\"read\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:12:\"delete_posts\";b:1;s:22:\"delete_published_posts\";b:1;}}s:11:\"contributor\";a:2:{s:4:\"name\";s:11:\"Contributor\";s:12:\"capabilities\";a:5:{s:10:\"edit_posts\";b:1;s:4:\"read\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:12:\"delete_posts\";b:1;}}s:10:\"subscriber\";a:2:{s:4:\"name\";s:10:\"Subscriber\";s:12:\"capabilities\";a:2:{s:4:\"read\";b:1;s:7:\"level_0\";b:1;}}}', 'yes'),
(101, 'post_count', '1', 'yes'),
(102, 'widget_block', 'a:6:{i:2;a:1:{s:7:\"content\";s:19:\"<!-- wp:search /-->\";}i:3;a:1:{s:7:\"content\";s:154:\"<!-- wp:group --><div class=\"wp-block-group\"><!-- wp:heading --><h2>Recent Posts</h2><!-- /wp:heading --><!-- wp:latest-posts /--></div><!-- /wp:group -->\";}i:4;a:1:{s:7:\"content\";s:227:\"<!-- wp:group --><div class=\"wp-block-group\"><!-- wp:heading --><h2>Recent Comments</h2><!-- /wp:heading --><!-- wp:latest-comments {\"displayAvatar\":false,\"displayDate\":false,\"displayExcerpt\":false} /--></div><!-- /wp:group -->\";}i:5;a:1:{s:7:\"content\";s:146:\"<!-- wp:group --><div class=\"wp-block-group\"><!-- wp:heading --><h2>Archives</h2><!-- /wp:heading --><!-- wp:archives /--></div><!-- /wp:group -->\";}i:6;a:1:{s:7:\"content\";s:150:\"<!-- wp:group --><div class=\"wp-block-group\"><!-- wp:heading --><h2>Categories</h2><!-- /wp:heading --><!-- wp:categories /--></div><!-- /wp:group -->\";}s:12:\"_multiwidget\";i:1;}', 'yes'),
(103, 'sidebars_widgets', 'a:4:{s:19:\"wp_inactive_widgets\";a:0:{}s:9:\"sidebar-1\";a:3:{i:0;s:7:\"block-2\";i:1;s:7:\"block-3\";i:2;s:7:\"block-4\";}s:9:\"sidebar-2\";a:2:{i:0;s:7:\"block-5\";i:1;s:7:\"block-6\";}s:13:\"array_version\";i:3;}', 'yes'),
(104, 'acf_version', '6.1.8', 'yes'),
(105, 'redirection_options', 'a:27:{s:7:\"support\";b:0;s:5:\"token\";s:32:\"03a9fd6a49dba6ea6897ebc87f8f74bf\";s:12:\"monitor_post\";i:0;s:13:\"monitor_types\";a:0:{}s:19:\"associated_redirect\";s:0:\"\";s:11:\"auto_target\";s:0:\"\";s:15:\"expire_redirect\";i:7;s:10:\"expire_404\";i:7;s:12:\"log_external\";b:0;s:10:\"log_header\";b:0;s:10:\"track_hits\";b:1;s:7:\"modules\";a:0:{}s:10:\"newsletter\";b:0;s:14:\"redirect_cache\";i:1;s:10:\"ip_logging\";i:1;s:13:\"last_group_id\";i:0;s:8:\"rest_api\";i:0;s:5:\"https\";b:0;s:7:\"headers\";a:0:{}s:8:\"database\";s:0:\"\";s:8:\"relocate\";s:0:\"\";s:16:\"preferred_domain\";s:0:\"\";s:7:\"aliases\";a:0:{}s:10:\"flag_query\";s:5:\"exact\";s:9:\"flag_case\";b:0;s:13:\"flag_trailing\";b:0;s:10:\"flag_regex\";b:0;}', 'yes'),
(106, 'username_changer_settings', 'a:0:{}', 'yes'),
(107, 'cron', 'a:3:{i:1691667677;a:3:{s:18:\"wp_https_detection\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}s:34:\"wp_privacy_delete_old_export_files\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:6:\"hourly\";s:4:\"args\";a:0:{}s:8:\"interval\";i:3600;}}s:30:\"broken-links-detector-external\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}i:1691754077;a:1:{s:30:\"wp_site_health_scheduled_check\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:6:\"weekly\";s:4:\"args\";a:0:{}s:8:\"interval\";i:604800;}}}s:7:\"version\";i:2;}', 'yes'),
(108, 'widget_pages', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(109, 'widget_calendar', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(110, 'widget_archives', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(111, 'widget_media_audio', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(112, 'widget_media_image', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(113, 'widget_media_gallery', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(114, 'widget_media_video', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(115, 'widget_meta', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(116, 'widget_search', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(117, 'widget_recent-posts', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(118, 'widget_recent-comments', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(119, 'widget_tag_cloud', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(120, 'widget_nav_menu', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(121, 'widget_custom_html', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(122, 'widget_modularity-module', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(123, 'acfe', 'a:2:{s:7:\"version\";s:7:\"0.8.8.7\";s:7:\"modules\";a:4:{s:11:\"block_types\";a:0:{}s:13:\"options_pages\";a:0:{}s:10:\"post_types\";a:0:{}s:10:\"taxonomies\";a:0:{}}}', 'yes'),
(125, 'the_seo_framework_initial_db_version', '4270', 'no'),
(126, 'autodescription-site-settings', 'a:125:{s:18:\"alter_search_query\";i:1;s:19:\"alter_archive_query\";i:1;s:24:\"alter_archive_query_type\";s:8:\"in_query\";s:23:\"alter_search_query_type\";s:8:\"in_query\";s:13:\"cache_sitemap\";i:1;s:22:\"display_seo_bar_tables\";i:1;s:23:\"display_seo_bar_metabox\";i:0;s:15:\"seo_bar_symbols\";i:0;s:21:\"display_pixel_counter\";i:1;s:25:\"display_character_counter\";i:1;s:16:\"canonical_scheme\";s:9:\"automatic\";s:17:\"timestamps_format\";s:1:\"1\";s:19:\"disabled_post_types\";a:0:{}s:19:\"disabled_taxonomies\";a:0:{}s:10:\"site_title\";s:0:\"\";s:15:\"title_separator\";s:6:\"hyphen\";s:14:\"title_location\";s:5:\"right\";s:19:\"title_rem_additions\";i:0;s:18:\"title_rem_prefixes\";i:0;s:16:\"title_strip_tags\";i:1;s:16:\"auto_description\";i:1;s:27:\"auto_descripton_html_method\";s:4:\"fast\";s:14:\"author_noindex\";i:0;s:12:\"date_noindex\";i:1;s:14:\"search_noindex\";i:1;s:12:\"site_noindex\";i:0;s:18:\"noindex_post_types\";a:1:{s:10:\"attachment\";i:1;}s:18:\"noindex_taxonomies\";a:1:{s:11:\"post_format\";i:1;}s:15:\"author_nofollow\";i:0;s:13:\"date_nofollow\";i:0;s:15:\"search_nofollow\";i:0;s:13:\"site_nofollow\";i:0;s:19:\"nofollow_post_types\";a:0:{}s:19:\"nofollow_taxonomies\";a:0:{}s:16:\"author_noarchive\";i:0;s:14:\"date_noarchive\";i:0;s:16:\"search_noarchive\";i:0;s:14:\"site_noarchive\";i:0;s:20:\"noarchive_post_types\";a:0:{}s:20:\"noarchive_taxonomies\";a:0:{}s:25:\"advanced_query_protection\";i:1;s:13:\"paged_noindex\";i:0;s:18:\"home_paged_noindex\";i:0;s:24:\"set_copyright_directives\";i:1;s:18:\"max_snippet_length\";i:-1;s:17:\"max_image_preview\";s:5:\"large\";s:17:\"max_video_preview\";i:-1;s:16:\"homepage_noindex\";i:0;s:17:\"homepage_nofollow\";i:0;s:18:\"homepage_noarchive\";i:0;s:14:\"homepage_title\";s:0:\"\";s:16:\"homepage_tagline\";i:1;s:20:\"homepage_description\";s:0:\"\";s:22:\"homepage_title_tagline\";s:0:\"\";s:19:\"home_title_location\";s:5:\"right\";s:17:\"homepage_og_title\";s:0:\"\";s:23:\"homepage_og_description\";s:0:\"\";s:22:\"homepage_twitter_title\";s:0:\"\";s:28:\"homepage_twitter_description\";s:0:\"\";s:25:\"homepage_social_image_url\";s:0:\"\";s:24:\"homepage_social_image_id\";i:0;s:3:\"pta\";a:0:{}s:13:\"shortlink_tag\";i:0;s:15:\"prev_next_posts\";i:1;s:18:\"prev_next_archives\";i:1;s:19:\"prev_next_frontpage\";i:1;s:18:\"facebook_publisher\";s:0:\"\";s:15:\"facebook_author\";s:0:\"\";s:14:\"facebook_appid\";s:0:\"\";s:17:\"post_publish_time\";i:1;s:16:\"post_modify_time\";i:1;s:12:\"twitter_card\";s:19:\"summary_large_image\";s:12:\"twitter_site\";s:0:\"\";s:15:\"twitter_creator\";s:0:\"\";s:19:\"oembed_use_og_title\";i:0;s:23:\"oembed_use_social_image\";i:1;s:20:\"oembed_remove_author\";i:1;s:7:\"og_tags\";i:1;s:13:\"facebook_tags\";i:1;s:12:\"twitter_tags\";i:1;s:14:\"oembed_scripts\";i:1;s:26:\"social_title_rem_additions\";i:1;s:14:\"multi_og_image\";i:0;s:11:\"theme_color\";s:0:\"\";s:19:\"social_image_fb_url\";s:0:\"\";s:18:\"social_image_fb_id\";i:0;s:19:\"google_verification\";s:0:\"\";s:17:\"bing_verification\";s:0:\"\";s:19:\"yandex_verification\";s:0:\"\";s:18:\"baidu_verification\";s:0:\"\";s:17:\"pint_verification\";s:0:\"\";s:16:\"knowledge_output\";i:1;s:14:\"knowledge_type\";s:12:\"organization\";s:14:\"knowledge_logo\";i:1;s:14:\"knowledge_name\";s:0:\"\";s:18:\"knowledge_logo_url\";s:0:\"\";s:17:\"knowledge_logo_id\";i:0;s:18:\"knowledge_facebook\";s:0:\"\";s:17:\"knowledge_twitter\";s:0:\"\";s:15:\"knowledge_gplus\";s:0:\"\";s:19:\"knowledge_instagram\";s:0:\"\";s:17:\"knowledge_youtube\";s:0:\"\";s:18:\"knowledge_linkedin\";s:0:\"\";s:19:\"knowledge_pinterest\";s:0:\"\";s:20:\"knowledge_soundcloud\";s:0:\"\";s:16:\"knowledge_tumblr\";s:0:\"\";s:15:\"sitemaps_output\";i:1;s:19:\"sitemap_query_limit\";i:1000;s:17:\"sitemaps_modified\";i:1;s:15:\"sitemaps_robots\";i:1;s:13:\"ping_use_cron\";i:1;s:11:\"ping_google\";i:1;s:9:\"ping_bing\";i:1;s:23:\"ping_use_cron_prerender\";i:0;s:14:\"sitemap_styles\";i:1;s:12:\"sitemap_logo\";i:1;s:16:\"sitemap_logo_url\";s:0:\"\";s:15:\"sitemap_logo_id\";i:0;s:18:\"sitemap_color_main\";s:6:\"222222\";s:20:\"sitemap_color_accent\";s:6:\"00a0d2\";s:16:\"excerpt_the_feed\";i:1;s:15:\"source_the_feed\";i:1;s:14:\"index_the_feed\";i:0;s:17:\"ld_json_searchbox\";i:1;s:19:\"ld_json_breadcrumbs\";i:1;}', 'yes'),
(127, 'the_seo_framework_upgraded_db_version', '4270', 'yes'),
(128, 'autodescription-updates-cache', 'a:0:{}', 'yes'),
(129, 'mod_sections_db_version', '1', 'yes'),
(130, 'municipio_db_version', '24', 'yes'),
(131, 'theme_mods_municipio', 'a:34:{s:11:\"color_alpha\";a:1:{s:4:\"base\";s:16:\"rgba(0,0,0,0.55)\";}s:20:\"archive_post_heading\";b:0;s:18:\"archive_post_style\";b:0;s:23:\"archive_post_post_count\";b:0;s:21:\"archive_post_order_by\";b:0;s:28:\"archive_post_order_direction\";b:0;s:34:\"archive_post_taxonomies_to_display\";b:0;s:28:\"archive_post_enabled_filters\";a:0:{}s:30:\"archive_post_number_of_columns\";i:3;s:26:\"archive_attachment_heading\";b:0;s:24:\"archive_attachment_style\";b:0;s:29:\"archive_attachment_post_count\";b:0;s:27:\"archive_attachment_order_by\";b:0;s:34:\"archive_attachment_order_direction\";b:0;s:40:\"archive_attachment_taxonomies_to_display\";b:0;s:34:\"archive_attachment_enabled_filters\";a:0:{}s:36:\"archive_attachment_number_of_columns\";i:3;s:29:\"archive_modal-content_heading\";b:0;s:27:\"archive_modal-content_style\";b:0;s:32:\"archive_modal-content_post_count\";b:0;s:30:\"archive_modal-content_order_by\";b:0;s:37:\"archive_modal-content_order_direction\";b:0;s:43:\"archive_modal-content_taxonomies_to_display\";b:0;s:37:\"archive_modal-content_enabled_filters\";a:0:{}s:39:\"archive_modal-content_number_of_columns\";i:3;s:22:\"archive_author_heading\";b:0;s:20:\"archive_author_style\";b:0;s:25:\"archive_author_post_count\";b:0;s:23:\"archive_author_order_by\";b:0;s:30:\"archive_author_order_direction\";b:0;s:36:\"archive_author_taxonomies_to_display\";b:0;s:30:\"archive_author_enabled_filters\";a:0:{}s:32:\"archive_author_number_of_columns\";i:3;s:18:\"custom_css_post_id\";i:-1;}', 'yes'),
(132, 'gutenberg_editor_mode', 'disabled', 'yes'),
(133, 'kirki_downloaded_font_files', 'a:29:{s:86:\"https://fonts.gstatic.com/s/materialicons/v140/flUhRq6tzZclQEJ-Vdg-IuiaDsNaIhQ8tQ.woff\";s:102:\"/Users/seno1000/www/public/dev/wp-content/fonts/material-icons/flUhRq6tzZclQEJ-Vdg-IuiaDsNaIhQ8tQ.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xFIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xFIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xMIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xMIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xEIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xEIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xLIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xLIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xHIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xHIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xGIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xGIzQXKMnyrYk.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xIIzQXKMny.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xIIzQXKMny.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu72xMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu72xMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu5mxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu5mxMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu7mxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu7mxMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu4WxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu4WxMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu7WxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu7WxMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu7GxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu7GxMKTU1Kvnz.woff\";s:70:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu4mxMKTU1Kg.woff\";s:86:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu4mxMKTU1Kg.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fCRc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fCRc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fABc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fABc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fCBc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fCBc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fBxc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fBxc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fCxc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fCxc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fChc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fChc-AMP6lbBP.woff\";s:74:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fBBc-AMP6lQ.woff\";s:90:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fBBc-AMP6lQ.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfCRc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfCRc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfABc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfABc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfCBc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfCBc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfBxc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfBxc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfCxc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfCxc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfChc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfChc-AMP6lbBP.woff\";s:74:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfBBc-AMP6lQ.woff\";s:90:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfBBc-AMP6lQ.woff\";}', 'yes');

INSERT INTO `mun_2_postmeta` (`meta_id`, `post_id`, `meta_key`, `meta_value`) VALUES
(1, 2, '_wp_page_template', 'default');

INSERT INTO `mun_2_posts` (`ID`, `post_author`, `post_date`, `post_date_gmt`, `post_content`, `post_title`, `post_excerpt`, `post_status`, `comment_status`, `ping_status`, `post_password`, `post_name`, `to_ping`, `pinged`, `post_modified`, `post_modified_gmt`, `post_content_filtered`, `post_parent`, `guid`, `menu_order`, `post_type`, `post_mime_type`, `comment_count`) VALUES
(1, 1, '2023-08-09 17:40:57', '2023-08-09 17:40:57', 'Welcome to <a href=\"https://dev.local.municipio.tech/\">Municipio</a>. This is your first post. Edit or delete it, then start writing!', 'Hello world!', '', 'publish', 'open', 'open', '', 'hello-world', '', '', '2023-08-09 17:40:57', '2023-08-09 17:40:57', '', 0, 'https://dev.local.municipio.tech/dev-one/?p=1', 0, 'post', '', 1),
(2, 1, '2023-08-09 17:40:57', '2023-08-09 17:40:57', '<!-- wp:paragraph -->\n<p>This is an example page. It\'s different from a blog post because it will stay in one place and will show up in your site navigation (in most themes). Most people start with an About page that introduces them to potential site visitors. It might say something like this:</p>\n<!-- /wp:paragraph -->\n\n<!-- wp:quote -->\n<blockquote class=\"wp-block-quote\"><p>Hi there! I\'m a bike messenger by day, aspiring actor by night, and this is my website. I live in Los Angeles, have a great dog named Jack, and I like pi&#241;a coladas. (And gettin\' caught in the rain.)</p></blockquote>\n<!-- /wp:quote -->\n\n<!-- wp:paragraph -->\n<p>...or something like this:</p>\n<!-- /wp:paragraph -->\n\n<!-- wp:quote -->\n<blockquote class=\"wp-block-quote\"><p>The XYZ Doohickey Company was founded in 1971, and has been providing quality doohickeys to the public ever since. Located in Gotham City, XYZ employs over 2,000 people and does all kinds of awesome things for the Gotham community.</p></blockquote>\n<!-- /wp:quote -->\n\n<!-- wp:paragraph -->\n<p>As a new WordPress user, you should go to <a href=\"https://dev.local.municipio.tech/dev-one/wp/wp-admin/\">your dashboard</a> to delete this page and create new pages for your content. Have fun!</p>\n<!-- /wp:paragraph -->', 'Sample Page', '', 'publish', 'closed', 'open', '', 'sample-page', '', '', '2023-08-09 17:40:57', '2023-08-09 17:40:57', '', 0, 'https://dev.local.municipio.tech/dev-one/?page_id=2', 0, 'page', '', 0);

INSERT INTO `mun_2_term_relationships` (`object_id`, `term_taxonomy_id`, `term_order`) VALUES
(1, 1, 0);

INSERT INTO `mun_2_term_taxonomy` (`term_taxonomy_id`, `term_id`, `taxonomy`, `description`, `parent`, `count`) VALUES
(1, 1, 'category', '', 0, 1);

INSERT INTO `mun_2_terms` (`term_id`, `name`, `slug`, `term_group`) VALUES
(1, 'Uncategorized', 'uncategorized', 0);

INSERT INTO `mun_blogs` (`blog_id`, `site_id`, `domain`, `path`, `registered`, `last_updated`, `public`, `archived`, `mature`, `spam`, `deleted`, `lang_id`) VALUES
(1, 1, 'dev.local.municipio.tech', '/', '2023-08-09 14:18:37', '2023-08-10 08:06:53', 1, 0, 0, 0, 0, 0),
(2, 1, 'dev.local.municipio.tech', '/dev-one/', '2023-08-09 17:40:57', '2023-08-09 17:40:57', 1, 0, 0, 0, 0, 0);

INSERT INTO `mun_comments` (`comment_ID`, `comment_post_ID`, `comment_author`, `comment_author_email`, `comment_author_url`, `comment_author_IP`, `comment_date`, `comment_date_gmt`, `comment_content`, `comment_karma`, `comment_approved`, `comment_agent`, `comment_type`, `comment_parent`, `user_id`) VALUES
(1, 1, 'A WordPress Commenter', 'wapuu@wordpress.example', 'https://wordpress.org/', '', '2023-08-09 14:17:44', '2023-08-09 14:17:44', 'Hi, this is a comment.\nTo get started with moderating, editing, and deleting comments, please visit the Comments screen in the dashboard.\nCommenter avatars come from <a href=\"https://en.gravatar.com/\">Gravatar</a>.', 0, '1', '', 'comment', 0, 0);

INSERT INTO `mun_options` (`option_id`, `option_name`, `option_value`, `autoload`) VALUES
(1, 'siteurl', 'https://dev.local.municipio.tech/wp', 'yes'),
(2, 'home', 'https://dev.local.municipio.tech/', 'yes'),
(3, 'blogname', 'Municipio', 'yes'),
(4, 'blogdescription', 'Empowers municipalities and the public sector through an open web platform', 'yes'),
(5, 'users_can_register', '0', 'yes'),
(6, 'admin_email', 'superadmin@local.municipio.tech', 'yes'),
(7, 'start_of_week', '1', 'yes'),
(8, 'use_balanceTags', '0', 'yes'),
(9, 'use_smilies', '1', 'yes'),
(10, 'require_name_email', '1', 'yes'),
(11, 'comments_notify', '1', 'yes'),
(12, 'posts_per_rss', '10', 'yes'),
(13, 'rss_use_excerpt', '0', 'yes'),
(14, 'mailserver_url', 'mail.example.com', 'yes'),
(15, 'mailserver_login', 'login@example.com', 'yes'),
(16, 'mailserver_pass', 'password', 'yes'),
(17, 'mailserver_port', '110', 'yes'),
(18, 'default_category', '1', 'yes'),
(19, 'default_comment_status', 'open', 'yes'),
(20, 'default_ping_status', 'open', 'yes'),
(21, 'default_pingback_flag', '0', 'yes'),
(22, 'posts_per_page', '10', 'yes'),
(23, 'date_format', 'F j, Y', 'yes'),
(24, 'time_format', 'g:i a', 'yes'),
(25, 'links_updated_date_format', 'F j, Y g:i a', 'yes'),
(26, 'comment_moderation', '0', 'yes'),
(27, 'moderation_notify', '1', 'yes'),
(28, 'permalink_structure', '/blog/%postname%/', 'yes'),
(29, 'rewrite_rules', 'a:129:{s:11:\"^wp-json/?$\";s:22:\"index.php?rest_route=/\";s:14:\"^wp-json/(.*)?\";s:33:\"index.php?rest_route=/$matches[1]\";s:21:\"^index.php/wp-json/?$\";s:22:\"index.php?rest_route=/\";s:24:\"^index.php/wp-json/(.*)?\";s:33:\"index.php?rest_route=/$matches[1]\";s:17:\"^wp-sitemap\\.xml$\";s:23:\"index.php?sitemap=index\";s:17:\"^wp-sitemap\\.xsl$\";s:36:\"index.php?sitemap-stylesheet=sitemap\";s:23:\"^wp-sitemap-index\\.xsl$\";s:34:\"index.php?sitemap-stylesheet=index\";s:48:\"^wp-sitemap-([a-z]+?)-([a-z\\d_-]+?)-(\\d+?)\\.xml$\";s:75:\"index.php?sitemap=$matches[1]&sitemap-subtype=$matches[2]&paged=$matches[3]\";s:34:\"^wp-sitemap-([a-z]+?)-(\\d+?)\\.xml$\";s:47:\"index.php?sitemap=$matches[1]&paged=$matches[2]\";s:52:\"blog/category/(.+?)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:52:\"index.php?category_name=$matches[1]&feed=$matches[2]\";s:47:\"blog/category/(.+?)/(feed|rdf|rss|rss2|atom)/?$\";s:52:\"index.php?category_name=$matches[1]&feed=$matches[2]\";s:28:\"blog/category/(.+?)/embed/?$\";s:46:\"index.php?category_name=$matches[1]&embed=true\";s:40:\"blog/category/(.+?)/page/?([0-9]{1,})/?$\";s:53:\"index.php?category_name=$matches[1]&paged=$matches[2]\";s:22:\"blog/category/(.+?)/?$\";s:35:\"index.php?category_name=$matches[1]\";s:49:\"blog/tag/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?tag=$matches[1]&feed=$matches[2]\";s:44:\"blog/tag/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?tag=$matches[1]&feed=$matches[2]\";s:25:\"blog/tag/([^/]+)/embed/?$\";s:36:\"index.php?tag=$matches[1]&embed=true\";s:37:\"blog/tag/([^/]+)/page/?([0-9]{1,})/?$\";s:43:\"index.php?tag=$matches[1]&paged=$matches[2]\";s:19:\"blog/tag/([^/]+)/?$\";s:25:\"index.php?tag=$matches[1]\";s:50:\"blog/type/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?post_format=$matches[1]&feed=$matches[2]\";s:45:\"blog/type/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?post_format=$matches[1]&feed=$matches[2]\";s:26:\"blog/type/([^/]+)/embed/?$\";s:44:\"index.php?post_format=$matches[1]&embed=true\";s:38:\"blog/type/([^/]+)/page/?([0-9]{1,})/?$\";s:51:\"index.php?post_format=$matches[1]&paged=$matches[2]\";s:20:\"blog/type/([^/]+)/?$\";s:33:\"index.php?post_format=$matches[1]\";s:51:\"blog/topic/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:53:\"index.php?feedback_topic=$matches[1]&feed=$matches[2]\";s:46:\"blog/topic/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:53:\"index.php?feedback_topic=$matches[1]&feed=$matches[2]\";s:27:\"blog/topic/([^/]+)/embed/?$\";s:47:\"index.php?feedback_topic=$matches[1]&embed=true\";s:39:\"blog/topic/([^/]+)/page/?([0-9]{1,})/?$\";s:54:\"index.php?feedback_topic=$matches[1]&paged=$matches[2]\";s:21:\"blog/topic/([^/]+)/?$\";s:36:\"index.php?feedback_topic=$matches[1]\";s:37:\"np-redirect/.+?/attachment/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:47:\"np-redirect/.+?/attachment/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:67:\"np-redirect/.+?/attachment/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:62:\"np-redirect/.+?/attachment/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:62:\"np-redirect/.+?/attachment/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:43:\"np-redirect/.+?/attachment/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:26:\"np-redirect/(.+?)/embed/?$\";s:44:\"index.php?np-redirect=$matches[1]&embed=true\";s:30:\"np-redirect/(.+?)/trackback/?$\";s:38:\"index.php?np-redirect=$matches[1]&tb=1\";s:38:\"np-redirect/(.+?)/page/?([0-9]{1,})/?$\";s:51:\"index.php?np-redirect=$matches[1]&paged=$matches[2]\";s:45:\"np-redirect/(.+?)/comment-page-([0-9]{1,})/?$\";s:51:\"index.php?np-redirect=$matches[1]&cpage=$matches[2]\";s:34:\"np-redirect/(.+?)(?:/([0-9]+))?/?$\";s:50:\"index.php?np-redirect=$matches[1]&page=$matches[2]\";s:46:\"blog/modal-content/[^/]+/attachment/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:56:\"blog/modal-content/[^/]+/attachment/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:76:\"blog/modal-content/[^/]+/attachment/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:71:\"blog/modal-content/[^/]+/attachment/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:71:\"blog/modal-content/[^/]+/attachment/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:52:\"blog/modal-content/[^/]+/attachment/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:35:\"blog/modal-content/([^/]+)/embed/?$\";s:46:\"index.php?modal-content=$matches[1]&embed=true\";s:39:\"blog/modal-content/([^/]+)/trackback/?$\";s:40:\"index.php?modal-content=$matches[1]&tb=1\";s:47:\"blog/modal-content/([^/]+)/page/?([0-9]{1,})/?$\";s:53:\"index.php?modal-content=$matches[1]&paged=$matches[2]\";s:54:\"blog/modal-content/([^/]+)/comment-page-([0-9]{1,})/?$\";s:53:\"index.php?modal-content=$matches[1]&cpage=$matches[2]\";s:43:\"blog/modal-content/([^/]+)(?:/([0-9]+))?/?$\";s:52:\"index.php?modal-content=$matches[1]&page=$matches[2]\";s:35:\"blog/modal-content/[^/]+/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:45:\"blog/modal-content/[^/]+/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:65:\"blog/modal-content/[^/]+/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:60:\"blog/modal-content/[^/]+/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:60:\"blog/modal-content/[^/]+/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:41:\"blog/modal-content/[^/]+/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:12:\"robots\\.txt$\";s:18:\"index.php?robots=1\";s:13:\"favicon\\.ico$\";s:19:\"index.php?favicon=1\";s:48:\".*wp-(atom|rdf|rss|rss2|feed|commentsrss2)\\.php$\";s:18:\"index.php?feed=old\";s:20:\".*wp-app\\.php(/.*)?$\";s:19:\"index.php?error=403\";s:16:\".*wp-signup.php$\";s:21:\"index.php?signup=true\";s:18:\".*wp-activate.php$\";s:23:\"index.php?activate=true\";s:18:\".*wp-register.php$\";s:23:\"index.php?register=true\";s:32:\"feed/(feed|rdf|rss|rss2|atom)/?$\";s:27:\"index.php?&feed=$matches[1]\";s:27:\"(feed|rdf|rss|rss2|atom)/?$\";s:27:\"index.php?&feed=$matches[1]\";s:8:\"embed/?$\";s:21:\"index.php?&embed=true\";s:20:\"page/?([0-9]{1,})/?$\";s:28:\"index.php?&paged=$matches[1]\";s:27:\"comment-page-([0-9]{1,})/?$\";s:38:\"index.php?&page_id=9&cpage=$matches[1]\";s:41:\"comments/feed/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?&feed=$matches[1]&withcomments=1\";s:36:\"comments/(feed|rdf|rss|rss2|atom)/?$\";s:42:\"index.php?&feed=$matches[1]&withcomments=1\";s:17:\"comments/embed/?$\";s:21:\"index.php?&embed=true\";s:44:\"search/(.+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:40:\"index.php?s=$matches[1]&feed=$matches[2]\";s:39:\"search/(.+)/(feed|rdf|rss|rss2|atom)/?$\";s:40:\"index.php?s=$matches[1]&feed=$matches[2]\";s:20:\"search/(.+)/embed/?$\";s:34:\"index.php?s=$matches[1]&embed=true\";s:32:\"search/(.+)/page/?([0-9]{1,})/?$\";s:41:\"index.php?s=$matches[1]&paged=$matches[2]\";s:14:\"search/(.+)/?$\";s:23:\"index.php?s=$matches[1]\";s:52:\"blog/author/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?author_name=$matches[1]&feed=$matches[2]\";s:47:\"blog/author/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:50:\"index.php?author_name=$matches[1]&feed=$matches[2]\";s:28:\"blog/author/([^/]+)/embed/?$\";s:44:\"index.php?author_name=$matches[1]&embed=true\";s:40:\"blog/author/([^/]+)/page/?([0-9]{1,})/?$\";s:51:\"index.php?author_name=$matches[1]&paged=$matches[2]\";s:22:\"blog/author/([^/]+)/?$\";s:33:\"index.php?author_name=$matches[1]\";s:74:\"blog/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/feed/(feed|rdf|rss|rss2|atom)/?$\";s:80:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&feed=$matches[4]\";s:69:\"blog/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/(feed|rdf|rss|rss2|atom)/?$\";s:80:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&feed=$matches[4]\";s:50:\"blog/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/embed/?$\";s:74:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&embed=true\";s:62:\"blog/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/page/?([0-9]{1,})/?$\";s:81:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]&paged=$matches[4]\";s:44:\"blog/([0-9]{4})/([0-9]{1,2})/([0-9]{1,2})/?$\";s:63:\"index.php?year=$matches[1]&monthnum=$matches[2]&day=$matches[3]\";s:61:\"blog/([0-9]{4})/([0-9]{1,2})/feed/(feed|rdf|rss|rss2|atom)/?$\";s:64:\"index.php?year=$matches[1]&monthnum=$matches[2]&feed=$matches[3]\";s:56:\"blog/([0-9]{4})/([0-9]{1,2})/(feed|rdf|rss|rss2|atom)/?$\";s:64:\"index.php?year=$matches[1]&monthnum=$matches[2]&feed=$matches[3]\";s:37:\"blog/([0-9]{4})/([0-9]{1,2})/embed/?$\";s:58:\"index.php?year=$matches[1]&monthnum=$matches[2]&embed=true\";s:49:\"blog/([0-9]{4})/([0-9]{1,2})/page/?([0-9]{1,})/?$\";s:65:\"index.php?year=$matches[1]&monthnum=$matches[2]&paged=$matches[3]\";s:31:\"blog/([0-9]{4})/([0-9]{1,2})/?$\";s:47:\"index.php?year=$matches[1]&monthnum=$matches[2]\";s:48:\"blog/([0-9]{4})/feed/(feed|rdf|rss|rss2|atom)/?$\";s:43:\"index.php?year=$matches[1]&feed=$matches[2]\";s:43:\"blog/([0-9]{4})/(feed|rdf|rss|rss2|atom)/?$\";s:43:\"index.php?year=$matches[1]&feed=$matches[2]\";s:24:\"blog/([0-9]{4})/embed/?$\";s:37:\"index.php?year=$matches[1]&embed=true\";s:36:\"blog/([0-9]{4})/page/?([0-9]{1,})/?$\";s:44:\"index.php?year=$matches[1]&paged=$matches[2]\";s:18:\"blog/([0-9]{4})/?$\";s:26:\"index.php?year=$matches[1]\";s:27:\".?.+?/attachment/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:37:\".?.+?/attachment/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:57:\".?.+?/attachment/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:52:\".?.+?/attachment/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:52:\".?.+?/attachment/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:33:\".?.+?/attachment/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:16:\"(.?.+?)/embed/?$\";s:41:\"index.php?pagename=$matches[1]&embed=true\";s:20:\"(.?.+?)/trackback/?$\";s:35:\"index.php?pagename=$matches[1]&tb=1\";s:40:\"(.?.+?)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:47:\"index.php?pagename=$matches[1]&feed=$matches[2]\";s:35:\"(.?.+?)/(feed|rdf|rss|rss2|atom)/?$\";s:47:\"index.php?pagename=$matches[1]&feed=$matches[2]\";s:28:\"(.?.+?)/page/?([0-9]{1,})/?$\";s:48:\"index.php?pagename=$matches[1]&paged=$matches[2]\";s:35:\"(.?.+?)/comment-page-([0-9]{1,})/?$\";s:48:\"index.php?pagename=$matches[1]&cpage=$matches[2]\";s:24:\"(.?.+?)(?:/([0-9]+))?/?$\";s:47:\"index.php?pagename=$matches[1]&page=$matches[2]\";s:32:\"blog/[^/]+/attachment/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:42:\"blog/[^/]+/attachment/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:62:\"blog/[^/]+/attachment/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:57:\"blog/[^/]+/attachment/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:57:\"blog/[^/]+/attachment/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:38:\"blog/[^/]+/attachment/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";s:21:\"blog/([^/]+)/embed/?$\";s:37:\"index.php?name=$matches[1]&embed=true\";s:25:\"blog/([^/]+)/trackback/?$\";s:31:\"index.php?name=$matches[1]&tb=1\";s:45:\"blog/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:43:\"index.php?name=$matches[1]&feed=$matches[2]\";s:40:\"blog/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:43:\"index.php?name=$matches[1]&feed=$matches[2]\";s:33:\"blog/([^/]+)/page/?([0-9]{1,})/?$\";s:44:\"index.php?name=$matches[1]&paged=$matches[2]\";s:40:\"blog/([^/]+)/comment-page-([0-9]{1,})/?$\";s:44:\"index.php?name=$matches[1]&cpage=$matches[2]\";s:29:\"blog/([^/]+)(?:/([0-9]+))?/?$\";s:43:\"index.php?name=$matches[1]&page=$matches[2]\";s:21:\"blog/[^/]+/([^/]+)/?$\";s:32:\"index.php?attachment=$matches[1]\";s:31:\"blog/[^/]+/([^/]+)/trackback/?$\";s:37:\"index.php?attachment=$matches[1]&tb=1\";s:51:\"blog/[^/]+/([^/]+)/feed/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:46:\"blog/[^/]+/([^/]+)/(feed|rdf|rss|rss2|atom)/?$\";s:49:\"index.php?attachment=$matches[1]&feed=$matches[2]\";s:46:\"blog/[^/]+/([^/]+)/comment-page-([0-9]{1,})/?$\";s:50:\"index.php?attachment=$matches[1]&cpage=$matches[2]\";s:27:\"blog/[^/]+/([^/]+)/embed/?$\";s:43:\"index.php?attachment=$matches[1]&embed=true\";}', 'yes'),
(30, 'hack_file', '0', 'yes'),
(31, 'blog_charset', 'UTF-8', 'yes'),
(32, 'moderation_keys', '', 'no'),
(33, 'active_plugins', 'a:0:{}', 'yes'),
(34, 'category_base', '', 'yes'),
(35, 'ping_sites', 'http://rpc.pingomatic.com/', 'yes'),
(36, 'comment_max_links', '2', 'yes'),
(37, 'gmt_offset', '0', 'yes'),
(38, 'default_email_category', '1', 'yes'),
(39, 'recently_edited', '', 'no'),
(40, 'template', 'municipio', 'yes'),
(41, 'stylesheet', 'municipio', 'yes'),
(42, 'comment_registration', '0', 'yes'),
(43, 'html_type', 'text/html', 'yes'),
(44, 'use_trackback', '0', 'yes'),
(45, 'default_role', 'subscriber', 'yes'),
(46, 'db_version', '53496', 'yes'),
(47, 'uploads_use_yearmonth_folders', '1', 'yes'),
(48, 'upload_path', '', 'yes'),
(49, 'blog_public', '0', 'yes'),
(50, 'default_link_category', '2', 'yes'),
(51, 'show_on_front', 'page', 'yes'),
(52, 'tag_base', '', 'yes'),
(53, 'show_avatars', '1', 'yes'),
(54, 'avatar_rating', 'G', 'yes'),
(55, 'upload_url_path', '', 'yes'),
(56, 'thumbnail_size_w', '150', 'yes'),
(57, 'thumbnail_size_h', '150', 'yes'),
(58, 'thumbnail_crop', '1', 'yes'),
(59, 'medium_size_w', '300', 'yes'),
(60, 'medium_size_h', '300', 'yes'),
(61, 'avatar_default', 'mystery', 'yes'),
(62, 'large_size_w', '1024', 'yes'),
(63, 'large_size_h', '1024', 'yes'),
(64, 'image_default_link_type', 'none', 'yes'),
(65, 'image_default_size', '', 'yes'),
(66, 'image_default_align', '', 'yes'),
(67, 'close_comments_for_old_posts', '0', 'yes'),
(68, 'close_comments_days_old', '14', 'yes'),
(69, 'thread_comments', '1', 'yes'),
(70, 'thread_comments_depth', '5', 'yes'),
(71, 'page_comments', '0', 'yes'),
(72, 'comments_per_page', '50', 'yes'),
(73, 'default_comments_page', 'newest', 'yes'),
(74, 'comment_order', 'asc', 'yes'),
(75, 'sticky_posts', 'a:0:{}', 'yes'),
(76, 'widget_categories', 'a:2:{i:1;a:0:{}s:12:\"_multiwidget\";i:1;}', 'yes'),
(77, 'widget_text', 'a:2:{i:1;a:0:{}s:12:\"_multiwidget\";i:1;}', 'yes'),
(78, 'widget_rss', 'a:2:{i:1;a:0:{}s:12:\"_multiwidget\";i:1;}', 'yes'),
(79, 'uninstall_plugins', 'a:2:{s:27:\"media-usage/media-usage.php\";s:27:\"MediaTracker\\App::uninstall\";s:27:\"redirection/redirection.php\";a:2:{i:0;s:17:\"Redirection_Admin\";i:1;s:16:\"plugin_uninstall\";}}', 'no'),
(80, 'timezone_string', '', 'yes'),
(81, 'page_for_posts', '0', 'yes'),
(82, 'page_on_front', '9', 'yes'),
(83, 'default_post_format', '0', 'yes'),
(84, 'link_manager_enabled', '0', 'yes'),
(85, 'finished_splitting_shared_terms', '1', 'yes'),
(86, 'site_icon', '0', 'yes'),
(87, 'medium_large_size_w', '768', 'yes'),
(88, 'medium_large_size_h', '0', 'yes'),
(89, 'wp_page_for_privacy_policy', '3', 'yes'),
(90, 'show_comments_cookies_opt_in', '1', 'yes'),
(91, 'admin_email_lifespan', '1707142664', 'yes'),
(92, 'disallowed_keys', '', 'no'),
(93, 'comment_previously_approved', '1', 'yes'),
(94, 'auto_plugin_theme_update_emails', 'a:0:{}', 'no'),
(95, 'auto_update_core_dev', 'enabled', 'yes'),
(96, 'auto_update_core_minor', 'enabled', 'yes'),
(97, 'auto_update_core_major', 'enabled', 'yes'),
(98, 'wp_force_deactivated_plugins', 'a:0:{}', 'yes'),
(99, 'initial_db_version', '53496', 'yes'),
(100, 'mun_user_roles', 'a:4:{s:13:\"administrator\";a:2:{s:4:\"name\";s:13:\"Administrator\";s:12:\"capabilities\";a:67:{s:13:\"switch_themes\";b:1;s:11:\"edit_themes\";b:1;s:16:\"activate_plugins\";b:1;s:12:\"edit_plugins\";b:1;s:10:\"edit_users\";b:1;s:10:\"edit_files\";b:1;s:14:\"manage_options\";b:1;s:17:\"moderate_comments\";b:1;s:17:\"manage_categories\";b:1;s:12:\"manage_links\";b:1;s:12:\"upload_files\";b:1;s:6:\"import\";b:1;s:15:\"unfiltered_html\";b:1;s:10:\"edit_posts\";b:1;s:17:\"edit_others_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:10:\"edit_pages\";b:1;s:4:\"read\";b:1;s:8:\"level_10\";b:1;s:7:\"level_9\";b:1;s:7:\"level_8\";b:1;s:7:\"level_7\";b:1;s:7:\"level_6\";b:1;s:7:\"level_5\";b:1;s:7:\"level_4\";b:1;s:7:\"level_3\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:17:\"edit_others_pages\";b:1;s:20:\"edit_published_pages\";b:1;s:13:\"publish_pages\";b:1;s:12:\"delete_pages\";b:1;s:19:\"delete_others_pages\";b:1;s:22:\"delete_published_pages\";b:1;s:12:\"delete_posts\";b:1;s:19:\"delete_others_posts\";b:1;s:22:\"delete_published_posts\";b:1;s:20:\"delete_private_posts\";b:1;s:18:\"edit_private_posts\";b:1;s:18:\"read_private_posts\";b:1;s:20:\"delete_private_pages\";b:1;s:18:\"edit_private_pages\";b:1;s:18:\"read_private_pages\";b:1;s:12:\"delete_users\";b:1;s:12:\"create_users\";b:1;s:17:\"unfiltered_upload\";b:1;s:14:\"edit_dashboard\";b:1;s:14:\"update_plugins\";b:1;s:14:\"delete_plugins\";b:1;s:15:\"install_plugins\";b:1;s:13:\"update_themes\";b:1;s:14:\"install_themes\";b:1;s:11:\"update_core\";b:1;s:10:\"list_users\";b:1;s:12:\"remove_users\";b:1;s:13:\"promote_users\";b:1;s:18:\"edit_theme_options\";b:1;s:13:\"delete_themes\";b:1;s:6:\"export\";b:1;s:11:\"edit_module\";b:1;s:12:\"edit_modules\";b:1;s:18:\"edit_other_modules\";b:1;s:15:\"publish_modules\";b:1;s:12:\"read_modules\";b:1;s:13:\"delete_module\";b:1;}}s:6:\"editor\";a:2:{s:4:\"name\";s:6:\"Editor\";s:12:\"capabilities\";a:40:{s:17:\"moderate_comments\";b:1;s:17:\"manage_categories\";b:1;s:12:\"manage_links\";b:1;s:12:\"upload_files\";b:1;s:15:\"unfiltered_html\";b:1;s:10:\"edit_posts\";b:1;s:17:\"edit_others_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:10:\"edit_pages\";b:1;s:4:\"read\";b:1;s:7:\"level_7\";b:1;s:7:\"level_6\";b:1;s:7:\"level_5\";b:1;s:7:\"level_4\";b:1;s:7:\"level_3\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:17:\"edit_others_pages\";b:1;s:20:\"edit_published_pages\";b:1;s:13:\"publish_pages\";b:1;s:12:\"delete_pages\";b:1;s:19:\"delete_others_pages\";b:1;s:22:\"delete_published_pages\";b:1;s:12:\"delete_posts\";b:1;s:19:\"delete_others_posts\";b:1;s:22:\"delete_published_posts\";b:1;s:20:\"delete_private_posts\";b:1;s:18:\"edit_private_posts\";b:1;s:18:\"read_private_posts\";b:1;s:20:\"delete_private_pages\";b:1;s:18:\"edit_private_pages\";b:1;s:18:\"read_private_pages\";b:1;s:11:\"edit_module\";b:1;s:12:\"edit_modules\";b:1;s:18:\"edit_other_modules\";b:1;s:15:\"publish_modules\";b:1;s:12:\"read_modules\";b:1;s:13:\"delete_module\";b:1;}}s:6:\"author\";a:2:{s:4:\"name\";s:6:\"Author\";s:12:\"capabilities\";a:15:{s:12:\"upload_files\";b:1;s:10:\"edit_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:4:\"read\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:12:\"delete_posts\";b:1;s:22:\"delete_published_posts\";b:1;s:11:\"edit_module\";b:1;s:12:\"edit_modules\";b:1;s:18:\"edit_other_modules\";b:1;s:15:\"publish_modules\";b:1;s:12:\"read_modules\";b:1;}}s:10:\"subscriber\";a:2:{s:4:\"name\";s:10:\"Subscriber\";s:12:\"capabilities\";a:2:{s:4:\"read\";b:1;s:7:\"level_0\";b:1;}}}', 'yes'),
(101, 'fresh_site', '0', 'yes'),
(102, 'user_count', '1', 'no'),
(103, 'widget_block', 'a:6:{i:2;a:1:{s:7:\"content\";s:19:\"<!-- wp:search /-->\";}i:3;a:1:{s:7:\"content\";s:154:\"<!-- wp:group --><div class=\"wp-block-group\"><!-- wp:heading --><h2>Recent Posts</h2><!-- /wp:heading --><!-- wp:latest-posts /--></div><!-- /wp:group -->\";}i:4;a:1:{s:7:\"content\";s:227:\"<!-- wp:group --><div class=\"wp-block-group\"><!-- wp:heading --><h2>Recent Comments</h2><!-- /wp:heading --><!-- wp:latest-comments {\"displayAvatar\":false,\"displayDate\":false,\"displayExcerpt\":false} /--></div><!-- /wp:group -->\";}i:5;a:1:{s:7:\"content\";s:146:\"<!-- wp:group --><div class=\"wp-block-group\"><!-- wp:heading --><h2>Archives</h2><!-- /wp:heading --><!-- wp:archives /--></div><!-- /wp:group -->\";}i:6;a:1:{s:7:\"content\";s:150:\"<!-- wp:group --><div class=\"wp-block-group\"><!-- wp:heading --><h2>Categories</h2><!-- /wp:heading --><!-- wp:categories /--></div><!-- /wp:group -->\";}s:12:\"_multiwidget\";i:1;}', 'yes'),
(104, 'sidebars_widgets', 'a:4:{s:19:\"wp_inactive_widgets\";a:0:{}s:9:\"sidebar-1\";a:3:{i:0;s:7:\"block-2\";i:1;s:7:\"block-3\";i:2;s:7:\"block-4\";}s:9:\"sidebar-2\";a:2:{i:0;s:7:\"block-5\";i:1;s:7:\"block-6\";}s:13:\"array_version\";i:3;}', 'yes'),
(105, 'cron', 'a:17:{i:1691590668;a:6:{s:32:\"recovery_mode_clean_expired_keys\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}s:18:\"wp_https_detection\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}s:34:\"wp_privacy_delete_old_export_files\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:6:\"hourly\";s:4:\"args\";a:0:{}s:8:\"interval\";i:3600;}}s:16:\"wp_version_check\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}s:17:\"wp_update_plugins\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}s:16:\"wp_update_themes\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}}i:1691590672;a:3:{s:19:\"wp_scheduled_delete\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}s:25:\"delete_expired_transients\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}s:21:\"wp_update_user_counts\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}}i:1691590675;a:1:{s:30:\"wp_scheduled_auto_draft_delete\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}i:1691590732;a:1:{s:28:\"wp_update_comment_type_batch\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:2:{s:8:\"schedule\";b:0;s:4:\"args\";a:0:{}}}}i:1691590813;a:1:{s:21:\"update_network_counts\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:10:\"twicedaily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:43200;}}}i:1691591918;a:1:{s:25:\"municipio_store_theme_mod\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}i:1691640000;a:1:{s:39:\"ad_integration_cleaning_duplicate_users\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}i:1691643600;a:1:{s:35:\"ad_integration_cleaning_orphan_meta\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}i:1691647200;a:1:{s:36:\"ad_integration_cleaning_capabilities\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}i:1691655212;a:1:{s:26:\"rediscache_discard_metrics\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:6:\"hourly\";s:4:\"args\";a:0:{}s:8:\"interval\";i:3600;}}}i:1691655248;a:2:{s:30:\"broken-links-detector-external\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}s:35:\"content-insights-for-editors-matomo\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}i:1691667455;a:1:{s:22:\"redirection_log_delete\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:5:\"daily\";s:4:\"args\";a:0:{}s:8:\"interval\";i:86400;}}}i:1691668372;a:1:{s:28:\"tsf_sitemap_cron_hook_before\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:2:{s:8:\"schedule\";b:0;s:4:\"args\";a:0:{}}}}i:1691668373;a:1:{s:21:\"tsf_sitemap_cron_hook\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:2:{s:8:\"schedule\";b:0;s:4:\"args\";a:0:{}}}}i:1691668374;a:1:{s:27:\"tsf_sitemap_cron_hook_after\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:2:{s:8:\"schedule\";b:0;s:4:\"args\";a:0:{}}}}i:1691677068;a:1:{s:30:\"wp_site_health_scheduled_check\";a:1:{s:32:\"40cd750bba9870f18aada2478b24840a\";a:3:{s:8:\"schedule\";s:6:\"weekly\";s:4:\"args\";a:0:{}s:8:\"interval\";i:604800;}}}s:7:\"version\";i:2;}', 'yes'),
(106, 'widget_pages', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(107, 'widget_calendar', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(108, 'widget_archives', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(109, 'widget_media_audio', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(110, 'widget_media_image', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(111, 'widget_media_gallery', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(112, 'widget_media_video', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(113, 'widget_meta', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(114, 'widget_search', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(115, 'widget_recent-posts', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(116, 'widget_recent-comments', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(117, 'widget_tag_cloud', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(118, 'widget_nav_menu', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(119, 'widget_custom_html', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(120, 'can_compress_scripts', '0', 'no'),
(121, 'acf_version', '6.1.8', 'yes'),
(122, '_contributor_role_bkp', 'O:7:\"WP_Role\":2:{s:4:\"name\";s:6:\"author\";s:12:\"capabilities\";a:10:{s:12:\"upload_files\";b:1;s:10:\"edit_posts\";b:1;s:20:\"edit_published_posts\";b:1;s:13:\"publish_posts\";b:1;s:4:\"read\";b:1;s:7:\"level_2\";b:1;s:7:\"level_1\";b:1;s:7:\"level_0\";b:1;s:12:\"delete_posts\";b:1;s:22:\"delete_published_posts\";b:1;}}', 'yes'),
(123, 'kirki_downloaded_font_files', 'a:54:{s:86:\"https://fonts.gstatic.com/s/materialicons/v140/flUhRq6tzZclQEJ-Vdg-IuiaDsNaIhQ8tQ.woff\";s:102:\"/Users/seno1000/www/public/dev/wp-content/fonts/material-icons/flUhRq6tzZclQEJ-Vdg-IuiaDsNaIhQ8tQ.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xFIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xFIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xMIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xMIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xEIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xEIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xLIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xLIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xHIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xHIzQXKMnyrYk.woff\";s:75:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xGIzQXKMnyrYk.woff\";s:91:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xGIzQXKMnyrYk.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOkCnqEu92Fr1Mu51xIIzQXKMny.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOkCnqEu92Fr1Mu51xIIzQXKMny.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu72xMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu72xMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu5mxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu5mxMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu7mxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu7mxMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu4WxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu4WxMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu7WxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu7WxMKTU1Kvnz.woff\";s:72:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu7GxMKTU1Kvnz.woff\";s:88:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu7GxMKTU1Kvnz.woff\";s:70:\"https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu4mxMKTU1Kg.woff\";s:86:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOmCnqEu92Fr1Mu4mxMKTU1Kg.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fCRc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fCRc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fABc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fABc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fCBc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fCBc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fBxc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fBxc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fCxc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fCxc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fChc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fChc-AMP6lbBP.woff\";s:74:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fBBc-AMP6lQ.woff\";s:90:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmEU9fBBc-AMP6lQ.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfCRc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfCRc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfABc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfABc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfCBc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfCBc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfBxc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfBxc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfCxc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfCxc-AMP6lbBP.woff\";s:76:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfChc-AMP6lbBP.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfChc-AMP6lbBP.woff\";s:74:\"https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfBBc-AMP6lQ.woff\";s:90:\"/Users/seno1000/www/public/dev/wp-content/fonts/roboto/KFOlCnqEu92Fr1MmWUlfBBc-AMP6lQ.woff\";s:79:\"https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLGT9Z11lE92JQEl8qw.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/poppins/pxiByp8kv8JHgFVrLGT9Z11lE92JQEl8qw.woff\";s:79:\"https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLGT9Z1JlE92JQEl8qw.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/poppins/pxiByp8kv8JHgFVrLGT9Z1JlE92JQEl8qw.woff\";s:76:\"https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLGT9Z1xlE92JQEk.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/poppins/pxiByp8kv8JHgFVrLGT9Z1xlE92JQEk.woff\";s:79:\"https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLBT5Z11lE92JQEl8qw.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/poppins/pxiByp8kv8JHgFVrLBT5Z11lE92JQEl8qw.woff\";s:79:\"https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLBT5Z1JlE92JQEl8qw.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/poppins/pxiByp8kv8JHgFVrLBT5Z1JlE92JQEl8qw.woff\";s:76:\"https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLBT5Z1xlE92JQEk.woff\";s:92:\"/Users/seno1000/www/public/dev/wp-content/fonts/poppins/pxiByp8kv8JHgFVrLBT5Z1xlE92JQEk.woff\";s:70:\"https://fonts.gstatic.com/s/mukta/v14/iJWKBXyXfDDVXbnArXqw023e1Ik.woff\";s:86:\"/Users/seno1000/www/public/dev/wp-content/fonts/mukta/iJWKBXyXfDDVXbnArXqw023e1Ik.woff\";s:70:\"https://fonts.gstatic.com/s/mukta/v14/iJWKBXyXfDDVXbnPrXqw023e1Ik.woff\";s:86:\"/Users/seno1000/www/public/dev/wp-content/fonts/mukta/iJWKBXyXfDDVXbnPrXqw023e1Ik.woff\";s:67:\"https://fonts.gstatic.com/s/mukta/v14/iJWKBXyXfDDVXbnBrXqw023e.woff\";s:83:\"/Users/seno1000/www/public/dev/wp-content/fonts/mukta/iJWKBXyXfDDVXbnBrXqw023e.woff\";s:78:\"https://fonts.gstatic.com/s/notosans/v30/o-0IIpQlx3QUlC5A4PNr6DRGSf6M7VBj.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0IIpQlx3QUlC5A4PNr6DRGSf6M7VBj.woff\";s:78:\"https://fonts.gstatic.com/s/notosans/v30/o-0IIpQlx3QUlC5A4PNr4TRGSf6M7VBj.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0IIpQlx3QUlC5A4PNr4TRGSf6M7VBj.woff\";s:78:\"https://fonts.gstatic.com/s/notosans/v30/o-0IIpQlx3QUlC5A4PNr5DRGSf6M7VBj.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0IIpQlx3QUlC5A4PNr5DRGSf6M7VBj.woff\";s:78:\"https://fonts.gstatic.com/s/notosans/v30/o-0IIpQlx3QUlC5A4PNr6TRGSf6M7VBj.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0IIpQlx3QUlC5A4PNr6TRGSf6M7VBj.woff\";s:78:\"https://fonts.gstatic.com/s/notosans/v30/o-0IIpQlx3QUlC5A4PNr5jRGSf6M7VBj.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0IIpQlx3QUlC5A4PNr5jRGSf6M7VBj.woff\";s:78:\"https://fonts.gstatic.com/s/notosans/v30/o-0IIpQlx3QUlC5A4PNr6jRGSf6M7VBj.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0IIpQlx3QUlC5A4PNr6jRGSf6M7VBj.woff\";s:78:\"https://fonts.gstatic.com/s/notosans/v30/o-0IIpQlx3QUlC5A4PNr6zRGSf6M7VBj.woff\";s:95:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0IIpQlx3QUlC5A4PNr6zRGSf6M7VBj.woff\";s:76:\"https://fonts.gstatic.com/s/notosans/v30/o-0IIpQlx3QUlC5A4PNr5TRGSf6M7Q.woff\";s:93:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0IIpQlx3QUlC5A4PNr5TRGSf6M7Q.woff\";s:82:\"https://fonts.gstatic.com/s/notosans/v30/o-0NIpQlx3QUlC5A4PNjXhFVadyHx2pqPIif.woff\";s:99:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0NIpQlx3QUlC5A4PNjXhFVadyHx2pqPIif.woff\";s:82:\"https://fonts.gstatic.com/s/notosans/v30/o-0NIpQlx3QUlC5A4PNjXhFVYNyHx2pqPIif.woff\";s:99:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0NIpQlx3QUlC5A4PNjXhFVYNyHx2pqPIif.woff\";s:82:\"https://fonts.gstatic.com/s/notosans/v30/o-0NIpQlx3QUlC5A4PNjXhFVZdyHx2pqPIif.woff\";s:99:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0NIpQlx3QUlC5A4PNjXhFVZdyHx2pqPIif.woff\";s:82:\"https://fonts.gstatic.com/s/notosans/v30/o-0NIpQlx3QUlC5A4PNjXhFVaNyHx2pqPIif.woff\";s:99:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0NIpQlx3QUlC5A4PNjXhFVaNyHx2pqPIif.woff\";s:82:\"https://fonts.gstatic.com/s/notosans/v30/o-0NIpQlx3QUlC5A4PNjXhFVZ9yHx2pqPIif.woff\";s:99:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0NIpQlx3QUlC5A4PNjXhFVZ9yHx2pqPIif.woff\";s:82:\"https://fonts.gstatic.com/s/notosans/v30/o-0NIpQlx3QUlC5A4PNjXhFVa9yHx2pqPIif.woff\";s:99:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0NIpQlx3QUlC5A4PNjXhFVa9yHx2pqPIif.woff\";s:82:\"https://fonts.gstatic.com/s/notosans/v30/o-0NIpQlx3QUlC5A4PNjXhFVatyHx2pqPIif.woff\";s:99:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0NIpQlx3QUlC5A4PNjXhFVatyHx2pqPIif.woff\";s:80:\"https://fonts.gstatic.com/s/notosans/v30/o-0NIpQlx3QUlC5A4PNjXhFVZNyHx2pqPA.woff\";s:97:\"/Users/seno1000/www/public/dev/wp-content/fonts/noto-sans/o-0NIpQlx3QUlC5A4PNjXhFVZNyHx2pqPA.woff\";}', 'yes'),
(124, 'municipio_db_version', '24', 'yes'),
(125, 'theme_mods_municipio', 'a:99:{s:11:\"color_alpha\";a:1:{s:4:\"base\";s:22:\"rgba(20, 24, 54, 0.74)\";}s:20:\"archive_post_heading\";s:1:\"0\";s:18:\"archive_post_style\";s:1:\"0\";s:23:\"archive_post_post_count\";s:1:\"0\";s:21:\"archive_post_order_by\";s:1:\"0\";s:28:\"archive_post_order_direction\";s:1:\"0\";s:34:\"archive_post_taxonomies_to_display\";s:1:\"0\";s:28:\"archive_post_enabled_filters\";a:0:{}s:30:\"archive_post_number_of_columns\";s:1:\"3\";s:26:\"archive_attachment_heading\";b:0;s:24:\"archive_attachment_style\";b:0;s:29:\"archive_attachment_post_count\";b:0;s:27:\"archive_attachment_order_by\";b:0;s:34:\"archive_attachment_order_direction\";b:0;s:40:\"archive_attachment_taxonomies_to_display\";b:0;s:34:\"archive_attachment_enabled_filters\";a:0:{}s:36:\"archive_attachment_number_of_columns\";i:3;s:22:\"archive_author_heading\";s:1:\"0\";s:20:\"archive_author_style\";s:1:\"0\";s:25:\"archive_author_post_count\";s:1:\"0\";s:23:\"archive_author_order_by\";b:0;s:30:\"archive_author_order_direction\";b:0;s:36:\"archive_author_taxonomies_to_display\";b:0;s:30:\"archive_author_enabled_filters\";a:0:{}s:32:\"archive_author_number_of_columns\";s:1:\"3\";s:18:\"custom_css_post_id\";i:7;s:21:\"color_palette_primary\";a:3:{s:4:\"base\";s:7:\"#1f265b\";s:4:\"dark\";s:7:\"#0a0f38\";s:5:\"light\";s:7:\"#17207c\";}s:23:\"color_palette_secondary\";a:4:{s:4:\"base\";s:7:\"#ffcb3d\";s:4:\"dark\";s:7:\"#ff773d\";s:5:\"light\";s:7:\"#ffeabc\";s:11:\"contrasting\";s:7:\"#000000\";}s:16:\"color_background\";a:1:{s:10:\"background\";s:7:\"#ffffff\";}s:10:\"color_card\";a:1:{s:10:\"background\";s:19:\"rgba(31,38,91,0.03)\";}s:10:\"color_text\";s:0:\"\";s:12:\"color_border\";s:0:\"\";s:11:\"color_input\";s:0:\"\";s:10:\"color_link\";a:5:{s:4:\"link\";s:7:\"#1f265b\";s:10:\"link_hover\";s:7:\"#1f265b\";s:6:\"active\";s:7:\"#1f265b\";s:7:\"visited\";s:7:\"#1f265b\";s:13:\"visited_hover\";s:7:\"#1f265b\";}s:27:\"color_palette_state_success\";s:0:\"\";s:26:\"color_palette_state_danger\";s:0:\"\";s:27:\"color_palette_state_warning\";s:0:\"\";s:24:\"color_palette_state_info\";s:0:\"\";s:24:\"color_palette_complement\";s:0:\"\";s:22:\"color_palette_monotone\";s:0:\"\";s:15:\"typography_base\";a:3:{s:11:\"font-family\";s:9:\"Noto Sans\";s:7:\"variant\";s:7:\"regular\";s:14:\"letter-spacing\";s:3:\"0px\";}s:18:\"typography_heading\";a:2:{s:11:\"font-family\";s:7:\"Poppins\";s:7:\"variant\";s:3:\"900\";}s:15:\"typography_bold\";a:1:{s:11:\"font-family\";s:9:\"Noto Sans\";}s:17:\"typography_italic\";a:4:{s:11:\"font-family\";s:6:\"Roboto\";s:7:\"variant\";s:6:\"italic\";s:10:\"font-style\";s:6:\"italic\";s:11:\"font-weight\";s:3:\"400\";}s:13:\"typography_h1\";a:4:{s:11:\"font-family\";s:7:\"Poppins\";s:7:\"variant\";s:3:\"500\";s:9:\"font-size\";s:4:\"40px\";s:11:\"line-height\";s:3:\"1.3\";}s:13:\"typography_h2\";a:3:{s:11:\"font-family\";s:7:\"Poppins\";s:7:\"variant\";s:3:\"500\";s:9:\"font-size\";s:4:\"32px\";}s:13:\"typography_h3\";a:3:{s:11:\"font-family\";s:7:\"Poppins\";s:7:\"variant\";s:3:\"500\";s:9:\"font-size\";s:4:\"22px\";}s:13:\"typography_h4\";a:3:{s:11:\"font-family\";s:7:\"Poppins\";s:7:\"variant\";s:3:\"500\";s:9:\"font-size\";s:4:\"18px\";}s:13:\"typography_h5\";a:3:{s:11:\"font-family\";s:7:\"Poppins\";s:7:\"variant\";s:3:\"500\";s:9:\"font-size\";s:4:\"18px\";}s:13:\"typography_h6\";a:3:{s:11:\"font-family\";s:7:\"Poppins\";s:7:\"variant\";s:3:\"500\";s:9:\"font-size\";s:4:\"18px\";}s:15:\"typography_lead\";a:1:{s:11:\"font-family\";s:9:\"Noto Sans\";}s:15:\"typography_body\";a:1:{s:11:\"font-family\";s:5:\"Mukta\";}s:17:\"typography_button\";a:2:{s:11:\"font-family\";s:9:\"Noto Sans\";s:7:\"variant\";s:3:\"700\";}s:18:\"typography_caption\";a:2:{s:11:\"font-family\";s:9:\"Noto Sans\";s:7:\"variant\";s:7:\"regular\";}s:15:\"typography_meta\";a:2:{s:11:\"font-family\";s:9:\"Noto Sans\";s:7:\"variant\";s:7:\"regular\";}s:9:\"container\";s:4:\"1280\";s:9:\"radius_xs\";s:1:\"0\";s:9:\"radius_sm\";s:1:\"0\";s:9:\"radius_md\";s:1:\"0\";s:9:\"radius_lg\";s:1:\"0\";s:14:\"flat_ui_design\";s:4:\"flat\";s:18:\"drop_shadow_amount\";s:1:\"0\";s:23:\"casual_header_alignment\";s:13:\"casual-center\";s:22:\"header_logotype_height\";s:1:\"9\";s:25:\"siteselector_color_source\";s:6:\"custom\";s:13:\"custom_colors\";a:2:{s:10:\"background\";s:7:\"#ececec\";s:11:\"contrasting\";s:7:\"#000000\";}s:24:\"quicklinks_custom_colors\";s:0:\"\";s:27:\"button_primary_color_active\";b:1;s:20:\"color_button_primary\";a:1:{s:4:\"base\";s:7:\"#2e4fba\";}s:22:\"color_button_secondary\";s:0:\"\";s:20:\"color_button_default\";s:0:\"\";s:12:\"button_shape\";s:4:\"pill\";s:19:\"nav_v_color_sidebar\";s:0:\"\";s:18:\"nav_v_color_drawer\";s:0:\"\";s:28:\"nav_v_color_drawer_secondary\";s:0:\"\";s:19:\"nav_v_color_primary\";s:0:\"\";s:19:\"nav_h_color_primary\";s:0:\"\";s:20:\"nav_v_color_language\";s:0:\"\";s:20:\"nav_v_color_floating\";s:0:\"\";s:28:\"hamburger_menu_custom_colors\";s:0:\"\";s:27:\"hero_slider_typography_base\";a:4:{s:9:\"font-size\";s:4:\"16px\";s:11:\"font-family\";s:6:\"Roboto\";s:11:\"font-weight\";s:3:\"400\";s:10:\"font-style\";s:6:\"normal\";}s:30:\"hero_slider_typography_heading\";a:4:{s:9:\"font-size\";s:4:\"32px\";s:11:\"font-family\";s:6:\"Roboto\";s:11:\"font-weight\";s:3:\"400\";s:10:\"font-style\";s:6:\"normal\";}s:12:\"footer_style\";s:7:\"columns\";s:14:\"footer_padding\";s:2:\"10\";s:22:\"footer_height_logotype\";s:1:\"7\";s:25:\"footer_logotype_alignment\";s:12:\"align-center\";s:20:\"footer_header_border\";b:0;s:14:\"footer_columns\";s:1:\"3\";s:17:\"footer_color_text\";s:7:\"#ffffff\";s:17:\"footer_background\";a:5:{s:16:\"background-color\";s:7:\"#1f265b\";s:16:\"background-image\";s:68:\"https://dev.local.municipio.tech/wp-content/uploads/2023/08/blob.svg\";s:17:\"background-repeat\";s:9:\"no-repeat\";s:19:\"background-position\";s:8:\"left top\";s:15:\"background-size\";s:4:\"auto\";}s:23:\"footer_subfooter_colors\";a:2:{s:10:\"background\";s:7:\"#1d224a\";s:4:\"text\";s:7:\"#ffffff\";}s:24:\"footer_subfooter_content\";a:3:{i:0;a:3:{s:5:\"title\";s:0:\"\";s:7:\"content\";s:33:\"How we process your personal data\";s:4:\"link\";s:1:\"#\";}i:1;a:3:{s:5:\"title\";s:0:\"\";s:7:\"content\";s:22:\"Availability statement\";s:4:\"link\";s:1:\"#\";}i:2;a:3:{s:5:\"title\";s:31:\"Made with ❤️ in Helsingborg\";s:7:\"content\";s:0:\"\";s:4:\"link\";s:0:\"\";}}s:14:\"divider_colors\";s:0:\"\";s:20:\"divider_frame_colors\";s:0:\"\";s:27:\"hero_content_align_vertical\";s:6:\"center\";s:29:\"hero_content_align_horizontal\";s:6:\"center\";s:19:\"field_custom_colors\";s:0:\"\";s:19:\"drawer_screen_sizes\";a:4:{i:0;s:2:\"xs\";i:1;s:2:\"sm\";i:2;s:2:\"md\";i:3;s:2:\"lg\";}s:11:\"load_design\";s:32:\"4c74ad42a29dfb214e2eb53d8b49049d\";}', 'yes'),
(126, 'gutenberg_editor_mode', 'disabled', 'yes'),
(130, 'kirki_notices', 'a:1:{s:15:\"discount_notice\";i:1;}', 'yes'),
(131, 'WPLANG', '', 'yes'),
(132, 'new_admin_email', 'superadmin@local.municipio.tech', 'yes'),
(133, 'recently_activated', 'a:0:{}', 'yes'),
(134, 'broken-links-detector-db-version', '1.0.1', 'yes'),
(135, 'event_manager_integration_version', '1.2', 'yes'),
(136, 'redirection_options', 'a:27:{s:7:\"support\";b:0;s:5:\"token\";s:32:\"8adba1b6eabb64920df8d510eb5e7fc3\";s:12:\"monitor_post\";i:0;s:13:\"monitor_types\";a:0:{}s:19:\"associated_redirect\";s:0:\"\";s:11:\"auto_target\";s:0:\"\";s:15:\"expire_redirect\";i:7;s:10:\"expire_404\";i:7;s:12:\"log_external\";b:0;s:10:\"log_header\";b:0;s:10:\"track_hits\";b:1;s:7:\"modules\";a:0:{}s:10:\"newsletter\";b:0;s:14:\"redirect_cache\";i:1;s:10:\"ip_logging\";i:1;s:13:\"last_group_id\";i:0;s:8:\"rest_api\";i:0;s:5:\"https\";b:0;s:7:\"headers\";a:0:{}s:8:\"database\";s:0:\"\";s:8:\"relocate\";s:0:\"\";s:16:\"preferred_domain\";s:0:\"\";s:7:\"aliases\";a:0:{}s:10:\"flag_query\";s:5:\"exact\";s:9:\"flag_case\";b:0;s:13:\"flag_trailing\";b:0;s:10:\"flag_regex\";b:0;}', 'yes'),
(137, 'autodescription-updates-cache', 'a:2:{s:26:\"check_seo_plugin_conflicts\";i:0;s:18:\"persistent_notices\";a:0:{}}', 'yes'),
(138, 'search-statistics-db-version', '2', 'yes'),
(139, 'username_changer_settings', 'a:0:{}', 'yes'),
(140, 'widget_api-alarm-widget', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(141, 'widget_display_events', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(142, 'widget_modularity-module', 'a:1:{s:12:\"_multiwidget\";i:1;}', 'yes'),
(143, 'acfe', 'a:2:{s:7:\"version\";s:7:\"0.8.8.7\";s:7:\"modules\";a:4:{s:11:\"block_types\";a:0:{}s:13:\"options_pages\";a:0:{}s:10:\"post_types\";a:0:{}s:10:\"taxonomies\";a:0:{}}}', 'yes'),
(145, 'the_seo_framework_initial_db_version', '4270', 'no'),
(146, 'autodescription-site-settings', 'a:125:{s:18:\"alter_search_query\";i:1;s:19:\"alter_archive_query\";i:1;s:24:\"alter_archive_query_type\";s:8:\"in_query\";s:23:\"alter_search_query_type\";s:8:\"in_query\";s:13:\"cache_sitemap\";i:1;s:22:\"display_seo_bar_tables\";i:1;s:23:\"display_seo_bar_metabox\";i:0;s:15:\"seo_bar_symbols\";i:0;s:21:\"display_pixel_counter\";i:1;s:25:\"display_character_counter\";i:1;s:16:\"canonical_scheme\";s:9:\"automatic\";s:17:\"timestamps_format\";s:1:\"1\";s:19:\"disabled_post_types\";a:0:{}s:19:\"disabled_taxonomies\";a:0:{}s:10:\"site_title\";s:0:\"\";s:15:\"title_separator\";s:6:\"hyphen\";s:14:\"title_location\";s:5:\"right\";s:19:\"title_rem_additions\";i:0;s:18:\"title_rem_prefixes\";i:0;s:16:\"title_strip_tags\";i:1;s:16:\"auto_description\";i:1;s:27:\"auto_descripton_html_method\";s:4:\"fast\";s:14:\"author_noindex\";i:0;s:12:\"date_noindex\";i:1;s:14:\"search_noindex\";i:1;s:12:\"site_noindex\";i:0;s:18:\"noindex_post_types\";a:1:{s:10:\"attachment\";i:1;}s:18:\"noindex_taxonomies\";a:1:{s:11:\"post_format\";i:1;}s:15:\"author_nofollow\";i:0;s:13:\"date_nofollow\";i:0;s:15:\"search_nofollow\";i:0;s:13:\"site_nofollow\";i:0;s:19:\"nofollow_post_types\";a:0:{}s:19:\"nofollow_taxonomies\";a:0:{}s:16:\"author_noarchive\";i:0;s:14:\"date_noarchive\";i:0;s:16:\"search_noarchive\";i:0;s:14:\"site_noarchive\";i:0;s:20:\"noarchive_post_types\";a:0:{}s:20:\"noarchive_taxonomies\";a:0:{}s:25:\"advanced_query_protection\";i:1;s:13:\"paged_noindex\";i:0;s:18:\"home_paged_noindex\";i:0;s:24:\"set_copyright_directives\";i:1;s:18:\"max_snippet_length\";i:-1;s:17:\"max_image_preview\";s:5:\"large\";s:17:\"max_video_preview\";i:-1;s:16:\"homepage_noindex\";i:0;s:17:\"homepage_nofollow\";i:0;s:18:\"homepage_noarchive\";i:0;s:14:\"homepage_title\";s:0:\"\";s:16:\"homepage_tagline\";i:1;s:20:\"homepage_description\";s:0:\"\";s:22:\"homepage_title_tagline\";s:0:\"\";s:19:\"home_title_location\";s:5:\"right\";s:17:\"homepage_og_title\";s:0:\"\";s:23:\"homepage_og_description\";s:0:\"\";s:22:\"homepage_twitter_title\";s:0:\"\";s:28:\"homepage_twitter_description\";s:0:\"\";s:25:\"homepage_social_image_url\";s:0:\"\";s:24:\"homepage_social_image_id\";i:0;s:3:\"pta\";a:6:{s:5:\"event\";a:14:{s:8:\"doctitle\";s:0:\"\";s:18:\"title_no_blog_name\";i:0;s:11:\"description\";s:0:\"\";s:8:\"og_title\";s:0:\"\";s:14:\"og_description\";s:0:\"\";s:8:\"tw_title\";s:0:\"\";s:14:\"tw_description\";s:0:\"\";s:16:\"social_image_url\";s:0:\"\";s:15:\"social_image_id\";i:0;s:9:\"canonical\";s:0:\"\";s:7:\"noindex\";i:0;s:8:\"nofollow\";i:0;s:9:\"noarchive\";i:0;s:8:\"redirect\";s:0:\"\";}s:11:\"job-listing\";a:14:{s:8:\"doctitle\";s:0:\"\";s:18:\"title_no_blog_name\";i:0;s:11:\"description\";s:0:\"\";s:8:\"og_title\";s:0:\"\";s:14:\"og_description\";s:0:\"\";s:8:\"tw_title\";s:0:\"\";s:14:\"tw_description\";s:0:\"\";s:16:\"social_image_url\";s:0:\"\";s:15:\"social_image_id\";i:0;s:9:\"canonical\";s:0:\"\";s:7:\"noindex\";i:0;s:8:\"nofollow\";i:0;s:9:\"noarchive\";i:0;s:8:\"redirect\";s:0:\"\";}s:8:\"my-pages\";a:14:{s:8:\"doctitle\";s:0:\"\";s:18:\"title_no_blog_name\";i:0;s:11:\"description\";s:0:\"\";s:8:\"og_title\";s:0:\"\";s:14:\"og_description\";s:0:\"\";s:8:\"tw_title\";s:0:\"\";s:14:\"tw_description\";s:0:\"\";s:16:\"social_image_url\";s:0:\"\";s:15:\"social_image_id\";i:0;s:9:\"canonical\";s:0:\"\";s:7:\"noindex\";i:0;s:8:\"nofollow\";i:0;s:9:\"noarchive\";i:0;s:8:\"redirect\";s:0:\"\";}s:7:\"project\";a:14:{s:8:\"doctitle\";s:0:\"\";s:18:\"title_no_blog_name\";i:0;s:11:\"description\";s:0:\"\";s:8:\"og_title\";s:0:\"\";s:14:\"og_description\";s:0:\"\";s:8:\"tw_title\";s:0:\"\";s:14:\"tw_description\";s:0:\"\";s:16:\"social_image_url\";s:0:\"\";s:15:\"social_image_id\";i:0;s:9:\"canonical\";s:0:\"\";s:7:\"noindex\";i:0;s:8:\"nofollow\";i:0;s:9:\"noarchive\";i:0;s:8:\"redirect\";s:0:\"\";}s:9:\"challenge\";a:14:{s:8:\"doctitle\";s:0:\"\";s:18:\"title_no_blog_name\";i:0;s:11:\"description\";s:0:\"\";s:8:\"og_title\";s:0:\"\";s:14:\"og_description\";s:0:\"\";s:8:\"tw_title\";s:0:\"\";s:14:\"tw_description\";s:0:\"\";s:16:\"social_image_url\";s:0:\"\";s:15:\"social_image_id\";i:0;s:9:\"canonical\";s:0:\"\";s:7:\"noindex\";i:0;s:8:\"nofollow\";i:0;s:9:\"noarchive\";i:0;s:8:\"redirect\";s:0:\"\";}s:8:\"platform\";a:14:{s:8:\"doctitle\";s:0:\"\";s:18:\"title_no_blog_name\";i:0;s:11:\"description\";s:0:\"\";s:8:\"og_title\";s:0:\"\";s:14:\"og_description\";s:0:\"\";s:8:\"tw_title\";s:0:\"\";s:14:\"tw_description\";s:0:\"\";s:16:\"social_image_url\";s:0:\"\";s:15:\"social_image_id\";i:0;s:9:\"canonical\";s:0:\"\";s:7:\"noindex\";i:0;s:8:\"nofollow\";i:0;s:9:\"noarchive\";i:0;s:8:\"redirect\";s:0:\"\";}}s:13:\"shortlink_tag\";i:0;s:15:\"prev_next_posts\";i:1;s:18:\"prev_next_archives\";i:1;s:19:\"prev_next_frontpage\";i:1;s:18:\"facebook_publisher\";s:0:\"\";s:15:\"facebook_author\";s:0:\"\";s:14:\"facebook_appid\";s:0:\"\";s:17:\"post_publish_time\";i:1;s:16:\"post_modify_time\";i:1;s:12:\"twitter_card\";s:19:\"summary_large_image\";s:12:\"twitter_site\";s:0:\"\";s:15:\"twitter_creator\";s:0:\"\";s:19:\"oembed_use_og_title\";i:0;s:23:\"oembed_use_social_image\";i:1;s:20:\"oembed_remove_author\";i:1;s:7:\"og_tags\";i:1;s:13:\"facebook_tags\";i:1;s:12:\"twitter_tags\";i:1;s:14:\"oembed_scripts\";i:1;s:26:\"social_title_rem_additions\";i:1;s:14:\"multi_og_image\";i:0;s:11:\"theme_color\";s:0:\"\";s:19:\"social_image_fb_url\";s:0:\"\";s:18:\"social_image_fb_id\";i:0;s:19:\"google_verification\";s:0:\"\";s:17:\"bing_verification\";s:0:\"\";s:19:\"yandex_verification\";s:0:\"\";s:18:\"baidu_verification\";s:0:\"\";s:17:\"pint_verification\";s:0:\"\";s:16:\"knowledge_output\";i:1;s:14:\"knowledge_type\";s:12:\"organization\";s:14:\"knowledge_logo\";i:1;s:14:\"knowledge_name\";s:0:\"\";s:18:\"knowledge_logo_url\";s:0:\"\";s:17:\"knowledge_logo_id\";i:0;s:18:\"knowledge_facebook\";s:0:\"\";s:17:\"knowledge_twitter\";s:0:\"\";s:15:\"knowledge_gplus\";s:0:\"\";s:19:\"knowledge_instagram\";s:0:\"\";s:17:\"knowledge_youtube\";s:0:\"\";s:18:\"knowledge_linkedin\";s:0:\"\";s:19:\"knowledge_pinterest\";s:0:\"\";s:20:\"knowledge_soundcloud\";s:0:\"\";s:16:\"knowledge_tumblr\";s:0:\"\";s:15:\"sitemaps_output\";i:1;s:19:\"sitemap_query_limit\";i:1000;s:17:\"sitemaps_modified\";i:1;s:15:\"sitemaps_robots\";i:1;s:13:\"ping_use_cron\";i:1;s:11:\"ping_google\";i:1;s:9:\"ping_bing\";i:1;s:23:\"ping_use_cron_prerender\";i:0;s:14:\"sitemap_styles\";i:1;s:12:\"sitemap_logo\";i:1;s:16:\"sitemap_logo_url\";s:0:\"\";s:15:\"sitemap_logo_id\";i:0;s:18:\"sitemap_color_main\";s:6:\"222222\";s:20:\"sitemap_color_accent\";s:6:\"00a0d2\";s:16:\"excerpt_the_feed\";i:1;s:15:\"source_the_feed\";i:1;s:14:\"index_the_feed\";i:0;s:17:\"ld_json_searchbox\";i:1;s:19:\"ld_json_breadcrumbs\";i:1;}', 'yes'),
(147, 'the_seo_framework_upgraded_db_version', '4270', 'yes'),
(148, 'nestedpages_menu', '2', 'yes'),
(149, 'nestedpages_posttypes', 'a:1:{s:4:\"page\";a:1:{s:12:\"replace_menu\";b:1;}}', 'yes'),
(150, 'nestedpages_version', '3.1.4', 'yes'),
(151, 'nestedpages_menusync', 'nosync', 'yes'),
(152, 'mod_sections_db_version', '1', 'yes'),
(153, 'options_gutenberg_editor_mode', 'template', 'no'),
(154, '_options_gutenberg_editor_mode', 'field_619fa3a2befb9', 'no'),
(155, 'options_gdpr_enable_attachment_consent_field', '0', 'no'),
(156, '_options_gdpr_enable_attachment_consent_field', 'field_5ac3343da499d', 'no'),
(157, 'options_favicons', '', 'no'),
(158, '_options_favicons', 'field_56cc3f64c0b41', 'no'),
(159, 'modularity-options', 'a:3:{s:18:\"enabled-post-types\";a:1:{i:0;s:4:\"page\";}s:13:\"enabled-areas\";a:12:{s:5:\"index\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:10:\"front-page\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:6:\"single\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:7:\"archive\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:13:\"archive-event\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:4:\"page\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:13:\"page-centered\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:15:\"page-two-column\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:6:\"author\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:6:\"search\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:23:\"page-centered.blade.php\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}s:18:\"one-page.blade.php\";a:10:{i:0;s:21:\"above-columns-sidebar\";i:1;s:14:\"bottom-sidebar\";i:2;s:16:\"content-area-top\";i:3;s:12:\"content-area\";i:4;s:11:\"slider-area\";i:5;s:12:\"left-sidebar\";i:6;s:19:\"left-sidebar-bottom\";i:7;s:19:\"content-area-bottom\";i:8;s:13:\"right-sidebar\";i:9;s:11:\"top-sidebar\";}}s:15:\"enabled-modules\";a:37:{i:0;s:15:\"mod-breadcrumbs\";i:1;s:18:\"mod-contact-banner\";i:2;s:12:\"mod-contacts\";i:3;s:11:\"mod-curator\";i:4;s:11:\"mod-divider\";i:5;s:13:\"mod-subscribe\";i:6;s:13:\"mod-fileslist\";i:7;s:8:\"mod-form\";i:8;s:11:\"mod-gallery\";i:9;s:8:\"mod-hero\";i:10;s:10:\"mod-iframe\";i:11;s:9:\"mod-image\";i:12;s:9:\"mod-index\";i:13;s:13:\"mod-inlaylist\";i:14;s:12:\"mod-logogrid\";i:15;s:7:\"mod-map\";i:16;s:9:\"mod-modal\";i:17;s:10:\"mod-notice\";i:18;s:19:\"mod-open-street-map\";i:19;s:9:\"mod-posts\";i:20;s:12:\"mod-products\";i:21;s:7:\"mod-rss\";i:22;s:13:\"mod-recommend\";i:23;s:10:\"mod-script\";i:24;s:16:\"mod-section-card\";i:25;s:20:\"mod-section-featured\";i:26;s:16:\"mod-section-full\";i:27;s:17:\"mod-section-split\";i:28;s:9:\"mod-sites\";i:29;s:10:\"mod-slider\";i:30;s:10:\"mod-spacer\";i:31;s:9:\"mod-table\";i:32;s:20:\"mod-testimonial-card\";i:33;s:8:\"mod-text\";i:34;s:12:\"mod-timeline\";i:35;s:9:\"mod-video\";i:36;s:12:\"mod-wpwidget\";}}', 'yes'),
(160, 'options_disable_default_blog_post_type', '1', 'no'),
(161, '_options_disable_default_blog_post_type', 'field_56c6baa16b6ed', 'no'),
(162, 'options_disable_default_page_post_type', '0', 'no'),
(163, '_options_disable_default_page_post_type', 'field_56c6bf6a28bb4', 'no'),
(164, 'options_avabile_dynamic_post_types', '', 'no'),
(165, '_options_avabile_dynamic_post_types', 'field_56b347f3ffb6c', 'no');

INSERT INTO `mun_postmeta` (`meta_id`, `post_id`, `meta_key`, `meta_value`) VALUES
(1, 2, '_wp_page_template', 'default'),
(2, 3, '_wp_page_template', 'default'),
(3, 5, '_wp_attached_file', '2023/08/blob.svg'),
(4, 5, 'sideloaded_identifier', '8915d7160163f02f1557fcf3c4b82d36'),
(5, 5, '_wp_attachment_metadata', 'a:1:{s:8:\"filesize\";i:644;}'),
(6, 5, '_source_url', 'https://media.helsingborg.se/uploads/networks/4/sites/199/2023/08/blob.svg'),
(7, 6, '_wp_trash_meta_status', 'publish'),
(8, 6, '_wp_trash_meta_time', '1691592929'),
(9, 9, '_edit_last', '1'),
(10, 9, '_wp_page_template', 'default'),
(11, 9, 'post_single_show_featured_image', '0'),
(12, 9, '_post_single_show_featured_image', 'field_56c33e148efe3'),
(13, 9, 'exclude_from_google_translate', '0'),
(14, 9, '_exclude_from_google_translate', 'field_646c5d27c7ebf'),
(15, 9, 'hide_in_menu', '0'),
(16, 9, '_hide_in_menu', 'field_56d83d2777785'),
(17, 9, 'custom_menu_title', ''),
(18, 9, '_custom_menu_title', 'field_56d83d4e77786'),
(19, 9, 'quicklinks_placement', 'default'),
(20, 9, '_quicklinks_placement', 'field_64227ca019e18'),
(21, 10, 'post_single_show_featured_image', '0'),
(22, 10, '_post_single_show_featured_image', 'field_56c33e148efe3'),
(23, 10, 'exclude_from_google_translate', '0'),
(24, 10, '_exclude_from_google_translate', 'field_646c5d27c7ebf'),
(25, 10, 'hide_in_menu', '0'),
(26, 10, '_hide_in_menu', 'field_56d83d2777785'),
(27, 10, 'custom_menu_title', ''),
(28, 10, '_custom_menu_title', 'field_56d83d4e77786'),
(29, 10, 'quicklinks_placement', 'default'),
(30, 10, '_quicklinks_placement', 'field_64227ca019e18'),
(31, 9, '_edit_lock', '1691592944:1'),
(32, 11, 'post_single_show_featured_image', '0'),
(33, 11, '_post_single_show_featured_image', 'field_56c33e148efe3'),
(34, 11, 'exclude_from_google_translate', '0'),
(35, 11, '_exclude_from_google_translate', 'field_646c5d27c7ebf'),
(36, 11, 'hide_in_menu', '0'),
(37, 11, '_hide_in_menu', 'field_56d83d2777785'),
(38, 11, 'custom_menu_title', ''),
(39, 11, '_custom_menu_title', 'field_56d83d4e77786'),
(40, 11, 'quicklinks_placement', 'default'),
(41, 11, '_quicklinks_placement', 'field_64227ca019e18'),
(42, 2, '_wp_trash_meta_status', 'publish'),
(43, 2, '_wp_trash_meta_time', '1691652982'),
(44, 2, '_wp_desired_post_slug', 'sample-page'),
(45, 3, '_wp_trash_meta_status', 'draft'),
(46, 3, '_wp_trash_meta_time', '1691652989'),
(47, 3, '_wp_desired_post_slug', 'privacy-policy'),
(48, 14, '_edit_lock', '1691654479:1'),
(49, 14, '_edit_last', '1'),
(50, 15, '_edit_lock', '1691654369:1'),
(51, 15, '_edit_last', '1'),
(52, 15, '_wp_page_template', 'default'),
(53, 15, 'post_single_show_featured_image', '0'),
(54, 15, '_post_single_show_featured_image', 'field_56c33e148efe3'),
(55, 15, 'exclude_from_google_translate', '0'),
(56, 15, '_exclude_from_google_translate', 'field_646c5d27c7ebf'),
(57, 15, 'hide_in_menu', '0'),
(58, 15, '_hide_in_menu', 'field_56d83d2777785'),
(59, 15, 'custom_menu_title', ''),
(60, 15, '_custom_menu_title', 'field_56d83d4e77786'),
(61, 15, 'quicklinks_placement', 'default'),
(62, 15, '_quicklinks_placement', 'field_64227ca019e18'),
(63, 16, 'post_single_show_featured_image', '0'),
(64, 16, '_post_single_show_featured_image', 'field_56c33e148efe3'),
(65, 16, 'exclude_from_google_translate', '0'),
(66, 16, '_exclude_from_google_translate', 'field_646c5d27c7ebf'),
(67, 16, 'hide_in_menu', '0'),
(68, 16, '_hide_in_menu', 'field_56d83d2777785'),
(69, 16, 'custom_menu_title', ''),
(70, 16, '_custom_menu_title', 'field_56d83d4e77786'),
(71, 16, 'quicklinks_placement', 'default'),
(72, 16, '_quicklinks_placement', 'field_64227ca019e18'),
(73, 17, '_edit_lock', '1691654400:1'),
(74, 17, '_edit_last', '1'),
(75, 17, '_wp_page_template', 'one-page.blade.php'),
(76, 17, 'post_single_show_featured_image', '0'),
(77, 17, '_post_single_show_featured_image', 'field_56c33e148efe3'),
(78, 17, 'exclude_from_google_translate', '0'),
(79, 17, '_exclude_from_google_translate', 'field_646c5d27c7ebf'),
(80, 17, 'hide_in_menu', '0'),
(81, 17, '_hide_in_menu', 'field_56d83d2777785'),
(82, 17, 'custom_menu_title', ''),
(83, 17, '_custom_menu_title', 'field_56d83d4e77786'),
(84, 17, 'quicklinks_placement', 'default'),
(85, 17, '_quicklinks_placement', 'field_64227ca019e18'),
(86, 18, 'post_single_show_featured_image', '0'),
(87, 18, '_post_single_show_featured_image', 'field_56c33e148efe3'),
(88, 18, 'exclude_from_google_translate', '0'),
(89, 18, '_exclude_from_google_translate', 'field_646c5d27c7ebf'),
(90, 18, 'hide_in_menu', '0'),
(91, 18, '_hide_in_menu', 'field_56d83d2777785'),
(92, 18, 'custom_menu_title', ''),
(93, 18, '_custom_menu_title', 'field_56d83d4e77786'),
(94, 18, 'quicklinks_placement', 'default'),
(95, 18, '_quicklinks_placement', 'field_64227ca019e18'),
(96, 19, '_edit_lock', '1691654677:1'),
(97, 19, '_edit_last', '1'),
(98, 19, '_wp_page_template', 'default'),
(99, 19, 'post_single_show_featured_image', '0'),
(100, 19, '_post_single_show_featured_image', 'field_56c33e148efe3'),
(101, 19, 'exclude_from_google_translate', '0'),
(102, 19, '_exclude_from_google_translate', 'field_646c5d27c7ebf'),
(103, 19, 'hide_in_menu', '0'),
(104, 19, '_hide_in_menu', 'field_56d83d2777785'),
(105, 19, 'custom_menu_title', ''),
(106, 19, '_custom_menu_title', 'field_56d83d4e77786'),
(107, 19, 'quicklinks_placement', 'default'),
(108, 19, '_quicklinks_placement', 'field_64227ca019e18'),
(109, 20, 'post_single_show_featured_image', '0'),
(110, 20, '_post_single_show_featured_image', 'field_56c33e148efe3'),
(111, 20, 'exclude_from_google_translate', '0'),
(112, 20, '_exclude_from_google_translate', 'field_646c5d27c7ebf'),
(113, 20, 'hide_in_menu', '0'),
(114, 20, '_hide_in_menu', 'field_56d83d2777785'),
(115, 20, 'custom_menu_title', ''),
(116, 20, '_custom_menu_title', 'field_56d83d4e77786'),
(117, 20, 'quicklinks_placement', 'default'),
(118, 20, '_quicklinks_placement', 'field_64227ca019e18'),
(119, 14, '_wp_trash_meta_status', 'draft'),
(120, 14, '_wp_trash_meta_time', '1691654833'),
(121, 14, '_wp_desired_post_slug', '');

INSERT INTO `mun_posts` (`ID`, `post_author`, `post_date`, `post_date_gmt`, `post_content`, `post_title`, `post_excerpt`, `post_status`, `comment_status`, `ping_status`, `post_password`, `post_name`, `to_ping`, `pinged`, `post_modified`, `post_modified_gmt`, `post_content_filtered`, `post_parent`, `guid`, `menu_order`, `post_type`, `post_mime_type`, `comment_count`) VALUES
(1, 1, '2023-08-09 14:17:44', '2023-08-09 14:17:44', '<!-- wp:paragraph -->\n<p>Welcome to WordPress. This is your first post. Edit or delete it, then start writing!</p>\n<!-- /wp:paragraph -->', 'Hello world!', '', 'publish', 'open', 'open', '', 'hello-world', '', '', '2023-08-09 14:17:44', '2023-08-09 14:17:44', '', 0, 'https://dev.local.municipio.tech/wp/?p=1', 0, 'post', '', 1),
(2, 1, '2023-08-09 14:17:44', '2023-08-09 14:17:44', '<!-- wp:paragraph -->\n<p>This is an example page. It\'s different from a blog post because it will stay in one place and will show up in your site navigation (in most themes). Most people start with an About page that introduces them to potential site visitors. It might say something like this:</p>\n<!-- /wp:paragraph -->\n\n<!-- wp:quote -->\n<blockquote class=\"wp-block-quote\"><p>Hi there! I\'m a bike messenger by day, aspiring actor by night, and this is my website. I live in Los Angeles, have a great dog named Jack, and I like pi&#241;a coladas. (And gettin\' caught in the rain.)</p></blockquote>\n<!-- /wp:quote -->\n\n<!-- wp:paragraph -->\n<p>...or something like this:</p>\n<!-- /wp:paragraph -->\n\n<!-- wp:quote -->\n<blockquote class=\"wp-block-quote\"><p>The XYZ Doohickey Company was founded in 1971, and has been providing quality doohickeys to the public ever since. Located in Gotham City, XYZ employs over 2,000 people and does all kinds of awesome things for the Gotham community.</p></blockquote>\n<!-- /wp:quote -->\n\n<!-- wp:paragraph -->\n<p>As a new WordPress user, you should go to <a href=\"https://dev.local.municipio.tech/wp/wp-admin/\">your dashboard</a> to delete this page and create new pages for your content. Have fun!</p>\n<!-- /wp:paragraph -->', 'Sample Page', '', 'trash', 'closed', 'open', '', 'sample-page__trashed', '', '', '2023-08-10 07:36:22', '2023-08-10 07:36:22', '', 0, 'https://dev.local.municipio.tech/wp/?page_id=2', 0, 'page', '', 0),
(3, 1, '2023-08-09 14:17:44', '2023-08-09 14:17:44', '<!-- wp:heading --><h2>Who we are</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>Our website address is: https://dev.local.municipio.tech/wp.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Comments</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>When visitors leave comments on the site we collect the data shown in the comments form, and also the visitor&#8217;s IP address and browser user agent string to help spam detection.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>An anonymized string created from your email address (also called a hash) may be provided to the Gravatar service to see if you are using it. The Gravatar service privacy policy is available here: https://automattic.com/privacy/. After approval of your comment, your profile picture is visible to the public in the context of your comment.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Media</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you upload images to the website, you should avoid uploading images with embedded location data (EXIF GPS) included. Visitors to the website can download and extract any location data from images on the website.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Cookies</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you leave a comment on our site you may opt-in to saving your name, email address and website in cookies. These are for your convenience so that you do not have to fill in your details again when you leave another comment. These cookies will last for one year.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>If you visit our login page, we will set a temporary cookie to determine if your browser accepts cookies. This cookie contains no personal data and is discarded when you close your browser.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>When you log in, we will also set up several cookies to save your login information and your screen display choices. Login cookies last for two days, and screen options cookies last for a year. If you select &quot;Remember Me&quot;, your login will persist for two weeks. If you log out of your account, the login cookies will be removed.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>If you edit or publish an article, an additional cookie will be saved in your browser. This cookie includes no personal data and simply indicates the post ID of the article you just edited. It expires after 1 day.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Embedded content from other websites</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>Articles on this site may include embedded content (e.g. videos, images, articles, etc.). Embedded content from other websites behaves in the exact same way as if the visitor has visited the other website.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>These websites may collect data about you, use cookies, embed additional third-party tracking, and monitor your interaction with that embedded content, including tracking your interaction with the embedded content if you have an account and are logged in to that website.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Who we share your data with</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you request a password reset, your IP address will be included in the reset email.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>How long we retain your data</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you leave a comment, the comment and its metadata are retained indefinitely. This is so we can recognize and approve any follow-up comments automatically instead of holding them in a moderation queue.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>For users that register on our website (if any), we also store the personal information they provide in their user profile. All users can see, edit, or delete their personal information at any time (except they cannot change their username). Website administrators can also see and edit that information.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>What rights you have over your data</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you have an account on this site, or have left comments, you can request to receive an exported file of the personal data we hold about you, including any data you have provided to us. You can also request that we erase any personal data we hold about you. This does not include any data we are obliged to keep for administrative, legal, or security purposes.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Where your data is sent</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>Visitor comments may be checked through an automated spam detection service.</p><!-- /wp:paragraph -->', 'Privacy Policy', '', 'trash', 'closed', 'open', '', 'privacy-policy__trashed', '', '', '2023-08-10 07:36:29', '2023-08-10 07:36:29', '', 0, 'https://dev.local.municipio.tech/wp/?page_id=3', 0, 'page', '', 0),
(4, 1, '2023-08-09 14:17:55', '0000-00-00 00:00:00', '', 'Auto Draft', '', 'auto-draft', 'open', 'open', '', '', '', '', '2023-08-09 14:17:55', '0000-00-00 00:00:00', '', 0, 'https://dev.local.municipio.tech/wp/?p=4', 0, 'post', '', 0),
(5, 1, '2023-08-09 14:55:16', '2023-08-09 14:55:16', '', 'blob', '', 'inherit', 'open', 'closed', '', 'blob', '', '', '2023-08-09 14:55:16', '2023-08-09 14:55:16', '', 0, 'http://dev.local.municipio.tech/wp-content/uploads/2023/08/blob.svg', 0, 'attachment', 'image/svg+xml', 0),
(6, 1, '2023-08-09 14:55:28', '2023-08-09 14:55:28', '{\n    \"custom_css[municipio]\": {\n        \"value\": \".c-header {\\n\\tbackground: #fafafa; \\n}\\n\\n.c-button.c-button--md,\\n.c-button:after{\\n\\tborder-radius: 48px; \\n}\\n\\n.c-logotypegrid .c-logotypegrid__logo {\\n\\tmax-width: 210px;\\n}\\n\\n.c-hero.c-hero--overlay .c-hero__overlay {\\n    backdrop-filter: blur(6px);\\n}\\n\\npre {\\n\\t    white-space: break-spaces;\\n    padding: 16px 24px;\\n    background: #eee;\\n}\\n\\n.c-segment__content-card.c-card--flat {\\nbackground-color: #eee !important; \\n}\",\n        \"type\": \"custom_css\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_post_heading\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_post_style\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_post_post_count\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_post_number_of_columns\": {\n        \"value\": \"3\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_post_taxonomies_to_display\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_post_order_by\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_post_order_direction\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_author_heading\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_author_style\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_author_post_count\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::archive_author_number_of_columns\": {\n        \"value\": \"3\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_primary\": {\n        \"value\": {\n            \"base\": \"#1f265b\",\n            \"dark\": \"#0a0f38\",\n            \"light\": \"#17207c\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_primary[base]\": {\n        \"value\": \"#1f265b\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_primary[dark]\": {\n        \"value\": \"#0a0f38\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_primary[light]\": {\n        \"value\": \"#17207c\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_secondary\": {\n        \"value\": {\n            \"base\": \"#ffcb3d\",\n            \"dark\": \"#ff773d\",\n            \"light\": \"#ffeabc\",\n            \"contrasting\": \"#000000\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_secondary[base]\": {\n        \"value\": \"#ffcb3d\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_secondary[dark]\": {\n        \"value\": \"#ff773d\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_secondary[light]\": {\n        \"value\": \"#ffeabc\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_secondary[contrasting]\": {\n        \"value\": \"#000000\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_background\": {\n        \"value\": {\n            \"background\": \"#ffffff\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_background[background]\": {\n        \"value\": \"#ffffff\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_card\": {\n        \"value\": {\n            \"background\": \"rgba(31,38,91,0.03)\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_card[background]\": {\n        \"value\": \"rgba(31,38,91,0.03)\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_text\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_border\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_input\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_link\": {\n        \"value\": {\n            \"link\": \"#1f265b\",\n            \"link_hover\": \"#1f265b\",\n            \"active\": \"#1f265b\",\n            \"visited\": \"#1f265b\",\n            \"visited_hover\": \"#1f265b\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_link[link]\": {\n        \"value\": \"#1f265b\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_link[link_hover]\": {\n        \"value\": \"#1f265b\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_link[active]\": {\n        \"value\": \"#1f265b\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_link[visited]\": {\n        \"value\": \"#1f265b\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_link[visited_hover]\": {\n        \"value\": \"#1f265b\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_alpha\": {\n        \"value\": {\n            \"base\": \"rgba(20, 24, 54, 0.74)\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_alpha[base]\": {\n        \"value\": \"rgba(20, 24, 54, 0.74)\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_state_success\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_state_danger\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_state_warning\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_state_info\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_complement\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_palette_monotone\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_base\": {\n        \"value\": {\n            \"font-size\": \"16px\",\n            \"font-family\": \"Noto Sans\",\n            \"variant\": \"regular\",\n            \"line-height\": \"1.625\",\n            \"letter-spacing\": \"0px\",\n            \"text-transform\": \"none\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 400\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_base[font-family]\": {\n        \"value\": \"Noto Sans\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_base[variant]\": {\n        \"value\": \"regular\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_base[letter-spacing]\": {\n        \"value\": \"0px\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_heading\": {\n        \"value\": {\n            \"font-family\": \"Poppins\",\n            \"variant\": \"900\",\n            \"text-transform\": \"none\",\n            \"line-height\": \"1.33\",\n            \"letter-spacing\": \".0125em\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 900\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_heading[font-family]\": {\n        \"value\": \"Poppins\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_heading[variant]\": {\n        \"value\": \"900\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_bold\": {\n        \"value\": {\n            \"font-family\": \"Noto Sans\",\n            \"variant\": \"700\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 700\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_bold[font-family]\": {\n        \"value\": \"Noto Sans\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_italic\": {\n        \"value\": {\n            \"font-family\": \"Roboto\",\n            \"variant\": \"italic\",\n            \"font-style\": \"italic\",\n            \"font-weight\": 400\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h1\": {\n        \"value\": {\n            \"font-size\": \"40px\",\n            \"font-family\": \"Poppins\",\n            \"variant\": \"500\",\n            \"line-height\": \"1.3\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 500\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h1[font-family]\": {\n        \"value\": \"Poppins\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h1[variant]\": {\n        \"value\": \"500\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h1[font-size]\": {\n        \"value\": \"40px\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h1[line-height]\": {\n        \"value\": \"1.3\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h2\": {\n        \"value\": {\n            \"font-size\": \"32px\",\n            \"font-family\": \"Poppins\",\n            \"variant\": \"500\",\n            \"line-height\": \"\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 500\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h2[font-family]\": {\n        \"value\": \"Poppins\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h2[variant]\": {\n        \"value\": \"500\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h2[font-size]\": {\n        \"value\": \"32px\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h3\": {\n        \"value\": {\n            \"font-size\": \"22px\",\n            \"font-family\": \"Poppins\",\n            \"variant\": \"500\",\n            \"line-height\": \"\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 500\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h3[font-family]\": {\n        \"value\": \"Poppins\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h3[variant]\": {\n        \"value\": \"500\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h3[font-size]\": {\n        \"value\": \"22px\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h4\": {\n        \"value\": {\n            \"font-size\": \"18px\",\n            \"font-family\": \"Poppins\",\n            \"variant\": \"500\",\n            \"line-height\": \"\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 500\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h4[font-family]\": {\n        \"value\": \"Poppins\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h4[variant]\": {\n        \"value\": \"500\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h4[font-size]\": {\n        \"value\": \"18px\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h5\": {\n        \"value\": {\n            \"font-size\": \"18px\",\n            \"font-family\": \"Poppins\",\n            \"variant\": \"500\",\n            \"line-height\": \"\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 500\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h5[font-family]\": {\n        \"value\": \"Poppins\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h5[variant]\": {\n        \"value\": \"500\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h5[font-size]\": {\n        \"value\": \"18px\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h6\": {\n        \"value\": {\n            \"font-size\": \"18px\",\n            \"font-family\": \"Poppins\",\n            \"variant\": \"500\",\n            \"line-height\": \"\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 500\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h6[font-family]\": {\n        \"value\": \"Poppins\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h6[variant]\": {\n        \"value\": \"500\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_h6[font-size]\": {\n        \"value\": \"18px\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_lead\": {\n        \"value\": {\n            \"font-size\": \"18px\",\n            \"font-family\": \"Noto Sans\",\n            \"variant\": \"500\",\n            \"line-height\": \"1.625\",\n            \"text-transform\": \"none\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 500\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_lead[font-family]\": {\n        \"value\": \"Noto Sans\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_body\": {\n        \"value\": {\n            \"font-size\": \"16px\",\n            \"font-family\": \"Mukta\",\n            \"variant\": \"\",\n            \"line-height\": \"1.625\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 400\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_body[font-family]\": {\n        \"value\": \"Mukta\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_button\": {\n        \"value\": {\n            \"font-size\": \"1em\",\n            \"font-family\": \"Noto Sans\",\n            \"variant\": \"700\",\n            \"line-height\": \"1\",\n            \"text-transform\": \"none\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 700\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_button[font-family]\": {\n        \"value\": \"Noto Sans\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_button[variant]\": {\n        \"value\": \"700\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_caption\": {\n        \"value\": {\n            \"font-size\": \"14px\",\n            \"font-family\": \"Noto Sans\",\n            \"variant\": \"regular\",\n            \"line-height\": \"1.25\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 400\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_caption[font-family]\": {\n        \"value\": \"Noto Sans\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_caption[variant]\": {\n        \"value\": \"regular\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_meta\": {\n        \"value\": {\n            \"font-size\": \"12px\",\n            \"font-family\": \"Noto Sans\",\n            \"variant\": \"regular\",\n            \"line-height\": \"1.625\",\n            \"text-transform\": \"none\",\n            \"font-style\": \"normal\",\n            \"font-weight\": 400\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_meta[font-family]\": {\n        \"value\": \"Noto Sans\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::typography_meta[variant]\": {\n        \"value\": \"regular\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::container\": {\n        \"value\": \"1280\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::radius_xs\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::radius_sm\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::radius_md\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::radius_lg\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::flat_ui_design\": {\n        \"value\": \"flat\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::drop_shadow_amount\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::casual_header_alignment\": {\n        \"value\": \"casual-center\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::header_logotype_height\": {\n        \"value\": \"9\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::siteselector_color_source\": {\n        \"value\": \"custom\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::custom_colors\": {\n        \"value\": {\n            \"background\": \"#ececec\",\n            \"contrasting\": \"#000000\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::custom_colors[background]\": {\n        \"value\": \"#ececec\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::custom_colors[contrasting]\": {\n        \"value\": \"#000000\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::quicklinks_custom_colors\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::button_primary_color_active\": {\n        \"value\": \"1\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_button_primary\": {\n        \"value\": {\n            \"base\": \"#2e4fba\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_button_primary[base]\": {\n        \"value\": \"#2e4fba\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_button_secondary\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::color_button_default\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::button_shape\": {\n        \"value\": \"pill\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::nav_v_color_sidebar\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::nav_v_color_drawer\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::nav_v_color_drawer_secondary\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::nav_v_color_primary\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::nav_h_color_primary\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::nav_v_color_language\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::nav_v_color_floating\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::hamburger_menu_custom_colors\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::hero_slider_typography_base\": {\n        \"value\": {\n            \"font-size\": \"16px\",\n            \"font-family\": \"Roboto\",\n            \"font-weight\": 400,\n            \"font-style\": \"normal\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::hero_slider_typography_heading\": {\n        \"value\": {\n            \"font-size\": \"32px\",\n            \"font-family\": \"Roboto\",\n            \"font-weight\": 400,\n            \"font-style\": \"normal\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_style\": {\n        \"value\": \"columns\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_padding\": {\n        \"value\": \"10\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_height_logotype\": {\n        \"value\": \"7\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_logotype_alignment\": {\n        \"value\": \"align-center\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_header_border\": {\n        \"value\": \"0\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_columns\": {\n        \"value\": \"3\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_color_text\": {\n        \"value\": \"#ffffff\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_background\": {\n        \"value\": {\n            \"background-color\": \"#1f265b\",\n            \"background-image\": \"https://dev.local.municipio.tech/wp-content/uploads/2023/08/blob.svg\",\n            \"background-repeat\": \"no-repeat\",\n            \"background-position\": \"left top\",\n            \"background-size\": \"auto\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_background[background-color]\": {\n        \"value\": \"#1f265b\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_background[background-image]\": {\n        \"value\": \"https://dev.local.municipio.tech/wp-content/uploads/2023/08/blob.svg\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_background[background-repeat]\": {\n        \"value\": \"no-repeat\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_background[background-position]\": {\n        \"value\": \"left top\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_background[background-size]\": {\n        \"value\": \"auto\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_subfooter_colors\": {\n        \"value\": {\n            \"background\": \"#1d224a\",\n            \"text\": \"#ffffff\"\n        },\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_subfooter_colors[background]\": {\n        \"value\": \"#1d224a\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_subfooter_colors[text]\": {\n        \"value\": \"#ffffff\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::footer_subfooter_content\": {\n        \"value\": [\n            {\n                \"title\": null,\n                \"content\": \"How we process your personal data\",\n                \"link\": \"#\"\n            },\n            {\n                \"title\": null,\n                \"content\": \"Availability statement\",\n                \"link\": \"#\"\n            },\n            {\n                \"title\": \"Made with \\u2764\\ufe0f in Helsingborg\",\n                \"content\": null,\n                \"link\": null\n            }\n        ],\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::divider_colors\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::divider_frame_colors\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::hero_content_align_vertical\": {\n        \"value\": \"center\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::hero_content_align_horizontal\": {\n        \"value\": \"center\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::field_custom_colors\": {\n        \"value\": \"\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::drawer_screen_sizes\": {\n        \"value\": [\n            \"xs\",\n            \"sm\",\n            \"md\",\n            \"lg\"\n        ],\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    },\n    \"municipio::load_design\": {\n        \"value\": \"4c74ad42a29dfb214e2eb53d8b49049d\",\n        \"type\": \"theme_mod\",\n        \"user_id\": 1,\n        \"date_modified_gmt\": \"2023-08-09 14:55:28\"\n    }\n}', '', '', 'trash', 'closed', 'closed', '', 'ff02839f-d565-48c5-8179-2184808f5f4a', '', '', '2023-08-09 14:55:28', '2023-08-09 14:55:28', '', 0, 'https://dev.local.municipio.tech/wp/blog/2023/08/09/ff02839f-d565-48c5-8179-2184808f5f4a/', 0, 'customize_changeset', '', 0),
(7, 1, '2023-08-09 14:55:28', '2023-08-09 14:55:28', '.c-header {\n	background: #fafafa; \n}\n\n.c-button.c-button--md,\n.c-button:after{\n	border-radius: 48px; \n}\n\n.c-logotypegrid .c-logotypegrid__logo {\n	max-width: 210px;\n}\n\n.c-hero.c-hero--overlay .c-hero__overlay {\n    backdrop-filter: blur(6px);\n}\n\npre {\n	    white-space: break-spaces;\n    padding: 16px 24px;\n    background: #eee;\n}\n\n.c-segment__content-card.c-card--flat {\nbackground-color: #eee !important; \n}', 'municipio', '', 'publish', 'closed', 'closed', '', 'municipio', '', '', '2023-08-09 14:55:28', '2023-08-09 14:55:28', '', 0, 'https://dev.local.municipio.tech/wp/blog/2023/08/09/municipio/', 0, 'custom_css', '', 0),
(8, 1, '2023-08-09 14:55:28', '2023-08-09 14:55:28', '.c-header {\n	background: #fafafa; \n}\n\n.c-button.c-button--md,\n.c-button:after{\n	border-radius: 48px; \n}\n\n.c-logotypegrid .c-logotypegrid__logo {\n	max-width: 210px;\n}\n\n.c-hero.c-hero--overlay .c-hero__overlay {\n    backdrop-filter: blur(6px);\n}\n\npre {\n	    white-space: break-spaces;\n    padding: 16px 24px;\n    background: #eee;\n}\n\n.c-segment__content-card.c-card--flat {\nbackground-color: #eee !important; \n}', 'municipio', '', 'inherit', 'closed', 'closed', '', '7-revision-v1', '', '', '2023-08-09 14:55:28', '2023-08-09 14:55:28', '', 7, 'https://dev.local.municipio.tech/wp/?p=8', 0, 'revision', '', 0),
(9, 1, '2023-08-09 14:56:39', '2023-08-09 14:56:39', 'Welcome aboard to the Municipio development platform! 🚀 You\'re about to embark on a journey of local development, enhancing the Municipio platform. Give yourself a high-five for taking this exciting step! 🖐️ Your skills are sure to shine as you contribute to the platform\'s growth. Happy coding! 💻🎉', 'Home', '', 'publish', 'closed', 'closed', '', 'home', '', '', '2023-08-09 14:57:59', '2023-08-09 14:57:59', '', 0, 'https://dev.local.municipio.tech/wp/?page_id=9', 0, 'page', '', 0),
(10, 1, '2023-08-09 14:56:39', '2023-08-09 14:56:39', '', 'Home', '', 'inherit', 'closed', 'closed', '', '9-revision-v1', '', '', '2023-08-09 14:56:39', '2023-08-09 14:56:39', '', 9, 'https://dev.local.municipio.tech/wp/?p=10', 0, 'revision', '', 0),
(11, 1, '2023-08-09 14:57:59', '2023-08-09 14:57:59', 'Welcome aboard to the Municipio development platform! 🚀 You\'re about to embark on a journey of local development, enhancing the Municipio platform. Give yourself a high-five for taking this exciting step! 🖐️ Your skills are sure to shine as you contribute to the platform\'s growth. Happy coding! 💻🎉', 'Home', '', 'inherit', 'closed', 'closed', '', '9-revision-v1', '', '', '2023-08-09 14:57:59', '2023-08-09 14:57:59', '', 9, 'https://dev.local.municipio.tech/wp/?p=11', 0, 'revision', '', 0),
(12, 1, '2023-08-10 07:36:22', '2023-08-10 07:36:22', '<!-- wp:paragraph -->\n<p>This is an example page. It\'s different from a blog post because it will stay in one place and will show up in your site navigation (in most themes). Most people start with an About page that introduces them to potential site visitors. It might say something like this:</p>\n<!-- /wp:paragraph -->\n\n<!-- wp:quote -->\n<blockquote class=\"wp-block-quote\"><p>Hi there! I\'m a bike messenger by day, aspiring actor by night, and this is my website. I live in Los Angeles, have a great dog named Jack, and I like pi&#241;a coladas. (And gettin\' caught in the rain.)</p></blockquote>\n<!-- /wp:quote -->\n\n<!-- wp:paragraph -->\n<p>...or something like this:</p>\n<!-- /wp:paragraph -->\n\n<!-- wp:quote -->\n<blockquote class=\"wp-block-quote\"><p>The XYZ Doohickey Company was founded in 1971, and has been providing quality doohickeys to the public ever since. Located in Gotham City, XYZ employs over 2,000 people and does all kinds of awesome things for the Gotham community.</p></blockquote>\n<!-- /wp:quote -->\n\n<!-- wp:paragraph -->\n<p>As a new WordPress user, you should go to <a href=\"https://dev.local.municipio.tech/wp/wp-admin/\">your dashboard</a> to delete this page and create new pages for your content. Have fun!</p>\n<!-- /wp:paragraph -->', 'Sample Page', '', 'inherit', 'closed', 'closed', '', '2-revision-v1', '', '', '2023-08-10 07:36:22', '2023-08-10 07:36:22', '', 2, 'https://dev.local.municipio.tech/?p=12', 0, 'revision', '', 0),
(13, 1, '2023-08-10 07:36:29', '2023-08-10 07:36:29', '<!-- wp:heading --><h2>Who we are</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>Our website address is: https://dev.local.municipio.tech/wp.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Comments</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>When visitors leave comments on the site we collect the data shown in the comments form, and also the visitor&#8217;s IP address and browser user agent string to help spam detection.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>An anonymized string created from your email address (also called a hash) may be provided to the Gravatar service to see if you are using it. The Gravatar service privacy policy is available here: https://automattic.com/privacy/. After approval of your comment, your profile picture is visible to the public in the context of your comment.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Media</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you upload images to the website, you should avoid uploading images with embedded location data (EXIF GPS) included. Visitors to the website can download and extract any location data from images on the website.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Cookies</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you leave a comment on our site you may opt-in to saving your name, email address and website in cookies. These are for your convenience so that you do not have to fill in your details again when you leave another comment. These cookies will last for one year.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>If you visit our login page, we will set a temporary cookie to determine if your browser accepts cookies. This cookie contains no personal data and is discarded when you close your browser.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>When you log in, we will also set up several cookies to save your login information and your screen display choices. Login cookies last for two days, and screen options cookies last for a year. If you select &quot;Remember Me&quot;, your login will persist for two weeks. If you log out of your account, the login cookies will be removed.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>If you edit or publish an article, an additional cookie will be saved in your browser. This cookie includes no personal data and simply indicates the post ID of the article you just edited. It expires after 1 day.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Embedded content from other websites</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>Articles on this site may include embedded content (e.g. videos, images, articles, etc.). Embedded content from other websites behaves in the exact same way as if the visitor has visited the other website.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>These websites may collect data about you, use cookies, embed additional third-party tracking, and monitor your interaction with that embedded content, including tracking your interaction with the embedded content if you have an account and are logged in to that website.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Who we share your data with</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you request a password reset, your IP address will be included in the reset email.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>How long we retain your data</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you leave a comment, the comment and its metadata are retained indefinitely. This is so we can recognize and approve any follow-up comments automatically instead of holding them in a moderation queue.</p><!-- /wp:paragraph --><!-- wp:paragraph --><p>For users that register on our website (if any), we also store the personal information they provide in their user profile. All users can see, edit, or delete their personal information at any time (except they cannot change their username). Website administrators can also see and edit that information.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>What rights you have over your data</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>If you have an account on this site, or have left comments, you can request to receive an exported file of the personal data we hold about you, including any data you have provided to us. You can also request that we erase any personal data we hold about you. This does not include any data we are obliged to keep for administrative, legal, or security purposes.</p><!-- /wp:paragraph --><!-- wp:heading --><h2>Where your data is sent</h2><!-- /wp:heading --><!-- wp:paragraph --><p><strong class=\"privacy-policy-tutorial\">Suggested text: </strong>Visitor comments may be checked through an automated spam detection service.</p><!-- /wp:paragraph -->', 'Privacy Policy', '', 'inherit', 'closed', 'closed', '', '3-revision-v1', '', '', '2023-08-10 07:36:29', '2023-08-10 07:36:29', '', 3, 'https://dev.local.municipio.tech/?p=13', 0, 'revision', '', 0),
(14, 1, '2023-08-10 08:07:13', '2023-08-10 08:07:13', '', 'Single page', '', 'trash', 'closed', 'closed', '', '__trashed', '', '', '2023-08-10 08:07:13', '2023-08-10 08:07:13', '', 0, 'https://dev.local.municipio.tech/?page_id=14', 0, 'page', '', 0),
(15, 1, '2023-08-10 08:01:44', '2023-08-10 08:01:44', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.\r\n\r\n<!--more-->\r\n\r\nEtiam porta sem malesuada magna mollis euismod. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. Nulla vitae elit libero, a pharetra augue. Vestibulum id ligula porta felis euismod semper. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Aenean lacinia bibendum nulla sed consectetur. Maecenas sed diam eget risus varius blandit sit amet non magna.', 'Single page', '', 'publish', 'closed', 'closed', '', 'single-page', '', '', '2023-08-10 08:01:44', '2023-08-10 08:01:44', '', 0, 'https://dev.local.municipio.tech/?page_id=15', 0, 'page', '', 0),
(16, 1, '2023-08-10 08:01:44', '2023-08-10 08:01:44', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.\r\n\r\n<!--more-->\r\n\r\nEtiam porta sem malesuada magna mollis euismod. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. Nulla vitae elit libero, a pharetra augue. Vestibulum id ligula porta felis euismod semper. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Aenean lacinia bibendum nulla sed consectetur. Maecenas sed diam eget risus varius blandit sit amet non magna.', 'Single page', '', 'inherit', 'closed', 'closed', '', '15-revision-v1', '', '', '2023-08-10 08:01:44', '2023-08-10 08:01:44', '', 15, 'https://dev.local.municipio.tech/?p=16', 0, 'revision', '', 0),
(17, 1, '2023-08-10 08:02:12', '2023-08-10 08:02:12', '', 'Onepage', '', 'publish', 'closed', 'closed', '', 'one-page', '', '', '2023-08-10 08:02:12', '2023-08-10 08:02:12', '', 0, 'https://dev.local.municipio.tech/?page_id=17', 0, 'page', '', 0),
(18, 1, '2023-08-10 08:02:12', '2023-08-10 08:02:12', '', 'Onepage', '', 'inherit', 'closed', 'closed', '', '17-revision-v1', '', '', '2023-08-10 08:02:12', '2023-08-10 08:02:12', '', 17, 'https://dev.local.municipio.tech/?p=18', 0, 'revision', '', 0),
(19, 1, '2023-08-10 08:06:52', '2023-08-10 08:06:52', 'Nullam quis risus eget urna mollis ornare vel eu leo. Donec id elit non mi porta gravida at eget metus. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Donec sed odio dui. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\r\n\r\nNulla vitae elit libero, a pharetra augue. Curabitur blandit tempus porttitor. Sed posuere consectetur est at lobortis. Cras mattis consectetur purus sit amet fermentum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec id elit non mi porta gravida at eget metus. Integer posuere erat a ante venenatis dapibus posuere velit aliquet.', 'Single page - Center', '', 'publish', 'closed', 'closed', '', 'single-page-center', '', '', '2023-08-10 08:06:52', '2023-08-10 08:06:52', '', 0, 'https://dev.local.municipio.tech/?page_id=19', 0, 'page', '', 0),
(20, 1, '2023-08-10 08:06:52', '2023-08-10 08:06:52', 'Nullam quis risus eget urna mollis ornare vel eu leo. Donec id elit non mi porta gravida at eget metus. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Donec sed odio dui. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\r\n\r\nNulla vitae elit libero, a pharetra augue. Curabitur blandit tempus porttitor. Sed posuere consectetur est at lobortis. Cras mattis consectetur purus sit amet fermentum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec id elit non mi porta gravida at eget metus. Integer posuere erat a ante venenatis dapibus posuere velit aliquet.', 'Single page - Center', '', 'inherit', 'closed', 'closed', '', '19-revision-v1', '', '', '2023-08-10 08:06:52', '2023-08-10 08:06:52', '', 19, 'https://dev.local.municipio.tech/?p=20', 0, 'revision', '', 0),
(21, 1, '2023-08-10 08:07:13', '2023-08-10 08:07:13', '', 'Single page', '', 'inherit', 'closed', 'closed', '', '14-revision-v1', '', '', '2023-08-10 08:07:13', '2023-08-10 08:07:13', '', 14, 'https://dev.local.municipio.tech/?p=21', 0, 'revision', '', 0);

INSERT INTO `mun_registration_log` (`ID`, `email`, `IP`, `blog_id`, `date_registered`) VALUES
(1, 'superadmin@local.municipio.tech', '127.0.0.1', 2, '2023-08-09 17:40:57');

INSERT INTO `mun_site` (`id`, `domain`, `path`) VALUES
(1, 'dev.local.municipio.tech', '/wp/');

INSERT INTO `mun_sitemeta` (`meta_id`, `site_id`, `meta_key`, `meta_value`) VALUES
(1, 1, 'site_name', 'Municipio'),
(2, 1, 'admin_email', 'superadmin@local.municipio.tech'),
(3, 1, 'admin_user_id', '1'),
(4, 1, 'registration', 'none'),
(5, 1, 'upload_filetypes', 'jpg jpeg png gif webp mov avi mpg 3gp 3g2 midi mid pdf doc ppt odt pptx docx pps ppsx xls xlsx key mp3 ogg flac m4a wav mp4 m4v webm ogv flv'),
(6, 1, 'blog_upload_space', '100'),
(7, 1, 'fileupload_maxk', '1500'),
(8, 1, 'site_admins', 'a:1:{i:0;s:10:\"superadmin\";}'),
(9, 1, 'allowedthemes', 'a:1:{s:9:\"municipio\";b:1;}'),
(10, 1, 'illegal_names', 'a:9:{i:0;s:3:\"www\";i:1;s:3:\"web\";i:2;s:4:\"root\";i:3;s:5:\"admin\";i:4;s:4:\"main\";i:5;s:6:\"invite\";i:6;s:13:\"administrator\";i:7;s:5:\"files\";i:8;s:4:\"blog\";}'),
(11, 1, 'wpmu_upgrade_site', '53496'),
(12, 1, 'welcome_email', 'Howdy USERNAME,\n\nYour new SITE_NAME site has been successfully set up at:\nBLOG_URL\n\nYou can log in to the administrator account with the following information:\n\nUsername: USERNAME\nPassword: PASSWORD\nLog in here: BLOG_URLwp-login.php\n\nWe hope you enjoy your new site. Thanks!\n\n--The Team @ SITE_NAME'),
(13, 1, 'first_post', 'Welcome to %s. This is your first post. Edit or delete it, then start writing!'),
(14, 1, 'siteurl', 'https://dev.local.municipio.tech/wp/'),
(15, 1, 'add_new_users', '0'),
(16, 1, 'upload_space_check_disabled', '1'),
(17, 1, 'subdomain_install', ''),
(18, 1, 'ms_files_rewriting', '0'),
(19, 1, 'user_count', '1'),
(20, 1, 'initial_db_version', '53496'),
(21, 1, 'active_sitewide_plugins', 'a:36:{s:34:\"advanced-custom-fields-pro/acf.php\";i:1691591597;s:35:\"acf-ux-collapse/acf-ux-collapse.php\";i:1691655210;s:53:\"active-directory-api-wp-integration/adintegration.php\";i:1691655210;s:29:\"acf-extended/acf-extended.php\";i:1691655210;s:39:\"attachment-revisions/media-replacer.php\";i:1691655210;s:33:\"better-post-ui/better-post-ui.php\";i:1691655210;s:45:\"broken-link-detector/broken-link-detector.php\";i:1691655210;s:39:\"content-scheduler/content-scheduler.php\";i:1691655210;s:41:\"custom-short-links/custom-short-links.php\";i:1691655210;s:38:\"customer-feedback/CustomerFeedback.php\";i:1691655210;s:41:\"easy-to-read-alternative/easy-reading.php\";i:1691655210;s:25:\"fakerpress/fakerpress.php\";i:1691655210;s:23:\"force-ssl/force-ssl.php\";i:1691655210;s:33:\"lix-calculator/lix-calculator.php\";i:1691655210;s:27:\"media-usage/media-usage.php\";i:1691655210;s:25:\"modularity/modularity.php\";i:1691655210;s:55:\"modularity-contact-banner/modularity-contact-banner.php\";i:1691655210;s:51:\"modularity-form-builder/modularity-form-builder.php\";i:1691655210;s:57:\"modularity-open-street-map/modularity-open-street-map.php\";i:1691655210;s:43:\"modularity-products/modularity-products.php\";i:1691655210;s:45:\"modularity-recommend/modularity-recommend.php\";i:1691655210;s:43:\"modularity-sections/modularity-sections.php\";i:1691655210;s:51:\"modularity-testimonials/modularity-testimonials.php\";i:1691655210;s:43:\"modularity-timeline/modularity-timeline.php\";i:1691655210;s:58:\"multisite-role-propagation/multisite-role-popagination.php\";i:1691655210;s:31:\"wp-nested-pages/nestedpages.php\";i:1691655210;s:27:\"redirection/redirection.php\";i:1691655210;s:45:\"redirection-extended/redirection-extended.php\";i:1691655210;s:27:\"redis-cache/redis-cache.php\";i:1691655211;s:33:\"search-notices/search-notices.php\";i:1691655211;s:35:\"autodescription/autodescription.php\";i:1691655211;s:33:\"user-switching/user-switching.php\";i:1691655211;s:37:\"username-changer/username-changer.php\";i:1691655211;s:47:\"wp-page-for-post-type/wp-page-for-post-type.php\";i:1691655211;s:37:\"wp-page-for-term/wp-page-for-term.php\";i:1691655211;s:45:\"wp-search-statistics/wp-search-statistics.php\";i:1691655212;}'),
(22, 1, 'WPLANG', 'en_US'),
(23, 1, 'main_site', '1'),
(24, 1, 'can_compress_scripts', '0'),
(25, 1, 'site_meta_supported', '1'),
(26, 1, 'recently_activated', 'a:15:{s:47:\"api-alarm-integration/api-alarm-integration.php\";i:1691666898;s:61:\"content-insights-for-editors/content-insights-for-editors.php\";i:1691666898;s:59:\"api-event-manager-integration/event-manager-integration.php\";i:1691666898;s:45:\"gdi-modularity-cases/gdi-modularity-cases.php\";i:1691666898;s:51:\"gdi-modularity-invoices/gdi-modularity-invoices.php\";i:1691666898;s:69:\"gdi-modularity-my-pages-about-me/gdi-modularity-my-pages-about-me.php\";i:1691666898;s:29:\"job-listings/job-listings.php\";i:1691666898;s:15:\"kirki/kirki.php\";i:1691666898;s:29:\"mod-my-pages/mod-my-pages.php\";i:1691666898;s:49:\"modularity-noticeboard/modularity-noticeboard.php\";i:1691666898;s:39:\"modularity-guides/modularity-guides.php\";i:1691666898;s:61:\"modularity-interactive-img-map/modularity-interactive-map.php\";i:1691666898;s:49:\"modularity-json-render/modularity-json-render.php\";i:1691666898;s:25:\"like-posts/like-posts.php\";i:1691666898;s:63:\"api-project-manager-integration/project-manager-integration.php\";i:1691666898;}'),
(27, 1, 'wp_force_deactivated_plugins', 'a:0:{}'),
(28, 1, 'registrationnotification', 'yes'),
(29, 1, 'welcome_user_email', 'Howdy USERNAME,\n\nYour new account is set up.\n\nYou can log in with the following information:\nUsername: USERNAME\nPassword: PASSWORD\nLOGINLINK\n\nThanks!\n\n--The Team @ SITE_NAME'),
(30, 1, 'blog_count', '2');

INSERT INTO `mun_term_relationships` (`object_id`, `term_taxonomy_id`, `term_order`) VALUES
(1, 1, 0);

INSERT INTO `mun_term_taxonomy` (`term_taxonomy_id`, `term_id`, `taxonomy`, `description`, `parent`, `count`) VALUES
(1, 1, 'category', '', 0, 1),
(2, 2, 'nav_menu', '', 0, 0);

INSERT INTO `mun_terms` (`term_id`, `name`, `slug`, `term_group`) VALUES
(1, 'Uncategorized', 'uncategorized', 0),
(2, 'Nested Pages', 'nested-pages', 0);

INSERT INTO `mun_usermeta` (`umeta_id`, `user_id`, `meta_key`, `meta_value`) VALUES
(1, 1, 'nickname', 'superadmin'),
(2, 1, 'first_name', ''),
(3, 1, 'last_name', ''),
(4, 1, 'description', ''),
(5, 1, 'rich_editing', 'true'),
(6, 1, 'syntax_highlighting', 'true'),
(7, 1, 'comment_shortcuts', 'false'),
(8, 1, 'admin_color', 'fresh'),
(9, 1, 'use_ssl', '0'),
(10, 1, 'show_admin_bar_front', 'true'),
(11, 1, 'locale', ''),
(12, 1, 'mun_capabilities', 'a:1:{s:13:\"administrator\";b:1;}'),
(13, 1, 'mun_user_level', '10'),
(14, 1, 'dismissed_wp_pointers', ''),
(15, 1, 'show_welcome_panel', '0'),
(16, 1, 'session_tokens', 'a:3:{s:64:\"ea0f7a71506ba90c3bb5f1b5687d0afe4ce1e8bac6847ed16289ed272c01780d\";a:4:{s:10:\"expiration\";i:1691763472;s:2:\"ip\";s:9:\"127.0.0.1\";s:2:\"ua\";s:117:\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36\";s:5:\"login\";i:1691590672;}s:64:\"9534a37b936e52ed71ccf238e8a0278fd26dc5de0cc598fdb6c9a7d59a05f9d9\";a:4:{s:10:\"expiration\";i:1691763611;s:2:\"ip\";s:9:\"127.0.0.1\";s:2:\"ua\";s:117:\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36\";s:5:\"login\";i:1691590811;}s:64:\"18dc47cf595ac6ddc9fbedf7c6cdb48279271793bb9d62981d62e7e5129aac20\";a:4:{s:10:\"expiration\";i:1691775542;s:2:\"ip\";s:9:\"127.0.0.1\";s:2:\"ua\";s:117:\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36\";s:5:\"login\";i:1691602742;}}'),
(17, 1, 'mun_dashboard_quick_press_last_post_id', '4'),
(18, 1, 'community-events-location', 'a:1:{s:2:\"ip\";s:9:\"127.0.0.0\";}'),
(19, 1, 'source_domain', 'dev.local.municipio.tech'),
(20, 1, 'primary_blog', '1'),
(21, 1, 'last_login', '1691602742'),
(22, 1, 'mun_2_capabilities', 'a:1:{s:13:\"administrator\";b:1;}'),
(23, 1, 'mun_2_user_level', '10'),
(24, 1, 'roc_dismissed_pro_release_notice', '1');

INSERT INTO `mun_users` (`ID`, `user_login`, `user_pass`, `user_nicename`, `user_email`, `user_url`, `user_registered`, `user_activation_key`, `user_status`, `display_name`, `spam`, `deleted`) VALUES
(1, 'superadmin', '$P$ByXfZnTXst5H0l6Q6.LzOOrs2S8EQk/', 'superadmin', 'superadmin@local.municipio.tech', 'https://dev.local.municipio.tech/wp', '2023-08-09 14:17:44', '', 0, 'superadmin', 0, 0);



/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;