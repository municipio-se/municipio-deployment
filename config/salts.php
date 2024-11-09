<?php

/**
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the
 * {@link https://api.wordpress.org/secret-key/1.1/salt/
 * WordPress.org secret-key service}
 *
 * You can change these at any point in time to invalidate all
 * existing cookies. This will force all users to have to log in again.
 *
 * IT IS STRONGLY RECOMMENDED THAT YOU DO CHANGE THESE
 * VALUES AS THEY ARE CRITICAL FOR A SECURE IMPLEMENTATION.
 * THESE VALUES SHOULD BE DIFFERENT FOR EACH INSTALLATION AND
 * BE TREATED AS A SECRET.
 *
 * @since 2.6.0
 */

 define('AUTH_KEY',         '!V>},<[?sZlpjDhLk!bFVdqggLCKZjz> *2<2.GI)b32=y6U9/B-chN+sAU`2sZR');
 define('SECURE_AUTH_KEY',  'E{,t*46+:f/PoE9?So-E84BCL.q~BCdW?vfeuXN$1v.|gi>~;>|+z)Gag<A&F`P-');
 define('LOGGED_IN_KEY',    'Y8(P:SR0!o?pTM<0+|nI!:H?Q:n<Y&5MNh=oY-5<;5t7<M!WZQii4g{r,[YwJ/a8');
 define('NONCE_KEY',        '}+XzlTRw)0``;IUnpPwaPZZID D&5$`Jomx$u4BgB>0IR6E+9G]=TBj@-/#~[)M^');
 define('AUTH_SALT',        'c`7xl_|/5[GUzJR5>R4Et/#PD>K1=H@{;4@Gtc7-CyJ4(fm{Q1p.N1p!F-oITlmc');
 define('SECURE_AUTH_SALT', '_VjPZRhftzw-v+[JAb*_pm [5=Sju$!91Tn!,P>cMS+.m;lIf<YIzg`aJVoDB0gJ');
 define('LOGGED_IN_SALT',   'RQ>lUEK%wf?G)1|C`!6;*1sV~gQOra ) k*2ax;d+y>] w.eTq?{g&zJ[4S9;3@~');
 define('NONCE_SALT',       'Lolx_):]e~Th:;m$/xGh6ZT968@kd7}PuH%h[5X8Kb5F46$Fc]5B7nZ2!gS?/5O`');