
<?php

use App\Http\Middleware\EnsureUserIsAdmin;
use App\Http\Middleware\EnsureSellerOrAdmin;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Middleware\HandleCors;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {

        // Registra o CORS antes das demais requisições.
        $middleware->prepend(HandleCors::class);

        $middleware->redirectGuestsTo(
            fn (Request $request) => null
        );

        $middleware->alias([
            'admin' => EnsureUserIsAdmin::class,
            'seller-or-admin' => EnsureSellerOrAdmin::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {

        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );

        $exceptions->render(function (
            AuthenticationException $e,
            Request $request
        ) {
            return response()->json([
                'message' => 'Unauthenticated.',
            ], 401);
        });
    })
    ->create();
