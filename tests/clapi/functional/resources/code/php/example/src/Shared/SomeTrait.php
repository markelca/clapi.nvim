<?php

declare(strict_types=1);

namespace App\Shared;

trait SomeTrait {
    public function publicTraitFunction(): void {}
    private function privateTraitFunction(): void {}
    protected function protectedTraitFunction(): void {}
}
