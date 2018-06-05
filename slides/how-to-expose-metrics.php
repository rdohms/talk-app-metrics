<?php
declare(strict_types=1);

use Prometheus\RenderTextFormat;
use Prometheus\Storage\APC;

require_once 'vendor/autoload.php';

$adapter = new APC();

$renderer = new RenderTextFormat();
$result = $renderer->render($adapter->collect());

echo $result;
