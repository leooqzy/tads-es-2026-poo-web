<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Order;
use App\Models\Product;
use App\Models\Review;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class AdminDashboardController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'totals' => [
                'products' => Product::count(),
                'active_products' => Product::where('enabled', true)->count(),
                'users' => User::count(),
                'categories' => Category::count(),
                'orders' => Order::count(),
                'reviews' => Review::count(),
            ],
        ]);
    }
}