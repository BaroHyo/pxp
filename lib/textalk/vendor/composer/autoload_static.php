<?php

// autoload_static.php @generated by Composer

namespace Composer\Autoload;

class ComposerStaticInitad92299fe87a905755a74b00a3c4fcc7
{
    public static $prefixLengthsPsr4 = array (
        'W' => 
        array (
            'WebSocket\\' => 10,
        ),
    );

    public static $prefixDirsPsr4 = array (
        'WebSocket\\' => 
        array (
            0 => __DIR__ . '/..' . '/textalk/websocket/lib',
        ),
    );

    public static function getInitializer(ClassLoader $loader)
    {
        return \Closure::bind(function () use ($loader) {
            $loader->prefixLengthsPsr4 = ComposerStaticInitad92299fe87a905755a74b00a3c4fcc7::$prefixLengthsPsr4;
            $loader->prefixDirsPsr4 = ComposerStaticInitad92299fe87a905755a74b00a3c4fcc7::$prefixDirsPsr4;

        }, null, ClassLoader::class);
    }
}