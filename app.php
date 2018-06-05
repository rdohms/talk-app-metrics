<?php

use Prometheus\Counter;
use Prometheus\Histogram;
use Prometheus\RenderTextFormat;
use Prometheus\Storage\APC;

require_once 'vendor/autoload.php';

if ($_SERVER['REQUEST_URI'] === '/index') {
    echo file_get_contents(__DIR__ . '/index.html');
    die;
}

$statuses    = [200, 401, 500];
$urls        = ['/metrics', '/url', '/feedback'];
$requestTime = random_int(2, 100);
$status      = $statuses[array_rand($statuses)];
$url         = $urls[array_rand($urls)];

$adapter = new APC();

$histogram = new Histogram(
    $adapter,
    'my_app',
    'response_time_ms',
    'This measures ....',
    ['status', 'url'],
    [0, 10, 50, 100]
);
$histogram->observe($requestTime, [$status, $url]);

$counter = new Counter($adapter, 'my_app', 'count_total', 'How many...', ['status', 'url']);
$counter->inc(['200', '/url']);
$counter->incBy(5, [$status, $url]);

// Render results
$renderer = new RenderTextFormat();
$result   = $renderer->render($adapter->collect());

header('Content-Type: text/plain');
echo $result;
