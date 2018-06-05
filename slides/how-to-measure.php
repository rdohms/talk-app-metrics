<?php

use Prometheus\Counter;
use Prometheus\Histogram;
use Prometheus\RenderTextFormat;
use Prometheus\Storage\APC;

require_once 'vendor/autoload.php';

$adapter   = new APC();
$histogram = new Histogram(
    $adapter,
    'my_app',
    'response_time_ms',
    'This measures ....',
    ['status', 'url'],
    [0, 10, 50, 100]
);

$histogram->observe(15, ['200', '/url']);


$counter = new Counter($adapter, 'my_app', 'count_total', 'How many...', ['status', 'url']);

$counter->inc(['200', '/url']);
$counter->incBy(5, ['200', '/url']);



$renderer = new RenderTextFormat();
$result = $renderer->render($adapter->collect());

echo $result;
