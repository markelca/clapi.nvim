<?php

/*
 * This file is part of the FOSRestBundle package.
 *
 * (c) FriendsOfSymfony <http://friendsofsymfony.github.com/>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace FOS\RestBundle\Controller;

use FOS\RestBundle\View\ViewHandlerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class Foo {}
class Bar {}

// Does the AbstractController::getSubscribedServices() method have a return type hint?
if (true) {
    /**
     * Compat class for Symfony 6.0 and newer support.
     *
     * @internal
     */
    abstract class BaseAbstractFOSRestController extends Foo
    {
        /**
         * {@inheritdoc}
         */
        public static function getSubscribedServices(): array
        {
            return []
        }
    }
} else {
    /**
     * Compat class for Symfony 5.4 and older support.
     *
     * @internal
     */
    abstract class BaseAbstractFOSRestController extends Foo
    {
        /**
         * @return array
         */
        public static function getSubscribedServices()
        {
            return [];
        }
    }
}

/**
 * Controllers using the View functionality of FOSRestBundle.
 */
abstract class AbstractFOSRestController extends BaseAbstractFOSRestController
{
    // use ControllerTrait;

    protected function getViewHandler(): void
    {
    }
}

