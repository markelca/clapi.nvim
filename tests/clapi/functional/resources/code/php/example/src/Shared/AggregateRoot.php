<?php

declare(strict_types=1);

namespace App\Shared;

final class AggregateRoot
{
    private array $domainEvents = [];

    final public function pullDomainEvents(): array
    {
        $domainEvents = $this->domainEvents;
        $this->domainEvents = [];

        return $domainEvents;
    }

    final protected function record(mixed $domainEvent): void
    {
        $this->domainEvents[] = $domainEvent;
    }

}
