
<?php

use App\Http\Controllers\AdminDashboardController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReviewController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

// Autenticação pública
Route::post('auth/register', [AuthController::class, 'register']);
Route::post('auth/login', [AuthController::class, 'login']);

// Imagem da conta
Route::get(
    'product-images/products/accounts/{filename}',
    function (string $filename) {
        abort_unless(
            preg_match('/^[A-Za-z0-9._-]+$/', $filename),
            404
        );

        $path = 'products/accounts/'.$filename;

        abort_unless(
            Storage::disk('public')->exists($path),
            404,
            'Imagem não encontrada.'
        );

        return response()->file(
            Storage::disk('public')->path($path)
        );
    }
)->where('filename', '[A-Za-z0-9._-]+');

// Imagem do inventário
Route::get(
    'product-images/products/inventories/{filename}',
    function (string $filename) {
        abort_unless(
            preg_match('/^[A-Za-z0-9._-]+$/', $filename),
            404
        );

        $path = 'products/inventories/'.$filename;

        abort_unless(
            Storage::disk('public')->exists($path),
            404,
            'Imagem não encontrada.'
        );

        return response()->file(
            Storage::disk('public')->path($path)
        );
    }
)->where('filename', '[A-Za-z0-9._-]+');

Route::middleware('auth:sanctum')->group(function () {

    Route::middleware('seller-or-admin')->group(function () {
        Route::get('products/mine', [ProductController::class, 'mine']);

        Route::apiResource('products', ProductController::class)
            ->only(['store', 'update', 'destroy']);
    });

    Route::apiResource('products', ProductController::class)
        ->only(['index', 'show']);

    Route::apiResource('categories', CategoryController::class)
        ->only(['index', 'show']);

    Route::middleware('admin')->group(function () {
        Route::apiResource('categories', CategoryController::class)
            ->only(['store', 'update', 'destroy']);

        Route::apiResource('customers', CustomerController::class);

        Route::apiResource('orders', OrderController::class);

        Route::apiResource('reviews', ReviewController::class);

        Route::get(
            'admin/dashboard',
            [AdminDashboardController::class, 'index']
        );
    });
});
