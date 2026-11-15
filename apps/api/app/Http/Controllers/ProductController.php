<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductStoreRequest;
use App\Http\Requests\ProductUpdateRequest;
use App\Models\Product;

class ProductController extends Controller
{
    public function index()
    {
        return Product::orderBy('position')
            ->orderBy('id')
            ->paginate(12);
    }

    public function store(ProductStoreRequest $request)
    {
        $product = Product::create($request->validated());

        return response()->json($product, 201);
    }

    public function show(Product $product)
    {
        return $product;
    }

    public function update(
        ProductUpdateRequest $request,
        Product $product
    ) {
        $product->update($request->validated());

        return $product->refresh();
    }

    public function destroy(Product $product)
    {
        $product->delete();

        return response()->noContent();
    }
}