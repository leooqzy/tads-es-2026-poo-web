<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductStoreRequest;
use App\Http\Requests\ProductUpdateRequest;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::query();

        // Administradores podem visualizar todos os anúncios.
        // Os demais usuários visualizam somente os ativos.
        if ($request->user()->role !== 'admin') {
            $query->where('enabled', true);
        }

        return $query
            ->orderBy('position')
            ->orderBy('id')
            ->paginate(12);
    }

    public function mine(Request $request)
    {
        return $request->user()
            ->products()
            ->orderBy('position')
            ->orderBy('id')
            ->paginate(12);
    }

    public function store(ProductStoreRequest $request)
    {
        $product = $request->user()
            ->products()
            ->create($request->validated());

        return response()->json($product, 201);
    }

    public function show(Request $request, Product $product)
    {
        $user = $request->user();

        if (
            !$product->enabled &&
            $user->role !== 'admin' &&
            $product->user_id !== $user->id
        ) {
            abort(404, 'Anúncio não encontrado.');
        }

        return $product;
    }

    public function update(
        ProductUpdateRequest $request,
        Product $product
    ) {
        $this->authorizeOwnerOrAdmin($request, $product);

        $product->update($request->validated());

        return $product->refresh();
    }

    public function destroy(Request $request, Product $product)
    {
        $this->authorizeOwnerOrAdmin($request, $product);

        $product->delete();

        return response()->noContent();
    }

    private function authorizeOwnerOrAdmin(
        Request $request,
        Product $product
    ): void {
        $user = $request->user();

        $isAdmin = $user->role === 'admin';
        $isOwner = $product->user_id !== null
            && (int) $product->user_id === (int) $user->id;

        abort_unless(
            $isAdmin || $isOwner,
            403,
            'Você não tem permissão para modificar este anúncio.'
        );
    }
}