<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSellerOrAdmin
{
    public function handle(
        Request $request,
        Closure $next
    ): Response {
        $role = $request->user()?->role;

        if (!in_array($role, ['seller', 'admin'], true)) {
            return response()->json([
                'message' => 'Acesso permitido somente para anunciantes.',
            ], 403);
        }

        return $next($request);
    }
}