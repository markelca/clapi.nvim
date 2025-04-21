<?php

declare(strict_types=1);

namespace App;

use App\Shared\AggregateRoot;
use App\Shared\SomeTrait;

final class Course extends AggregateRoot
{
    use SomeTrait;

    private $att = [];

    public function __construct(private readonly int $id, private string $name, private readonly float $duration)
    {
    }

    public function foo(): void
    {
    }

    private function bar(): string
    {
        return "bar";
    }

    public function fizz(): int
    {
        return 0;

    }

}
