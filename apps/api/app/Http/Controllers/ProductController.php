<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductStoreRequest;
use App\Http\Requests\ProductUpdateRequest;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::query();

        // Administradores visualizam todos os anúncios.
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
        $data = $request->validated();

        // Salva a imagem da conta.
        $data['image_account'] = $request
            ->file('image_account')
            ->store('products/accounts', 'public');

        // Salva a imagem do inventário.
        $data['image_inventory'] = $request
            ->file('image_inventory')
            ->store('products/inventories', 'public');

        // Mantém o anúncio vinculado ao vendedor autenticado.
        $product = $request->user()
            ->products()
            ->create($data);

        return response()->json($product, 201);
    }

    public function show(Request $request, Product $product)
    {
        $user = $request->user();

        if (
            !$product->enabled &&
            $user->role !== 'admin' &&
            (int) $product->user_id !== (int) $user->id
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

        $data = $request->validated();

        $oldAccountImage = $product->image_account;
        $oldInventoryImage = $product->image_inventory;

        // Substitui a imagem da conta somente se uma nova foi enviada.
        if ($request->hasFile('image_account')) {
            $data['image_account'] = $request
                ->file('image_account')
                ->store('products/accounts', 'public');
        }

        // Substitui a imagem do inventário somente se uma nova foi enviada.
        if ($request->hasFile('image_inventory')) {
            $data['image_inventory'] = $request
                ->file('image_inventory')
                ->store('products/inventories', 'public');
        }

        $product->update($data);

        // Remove os arquivos antigos após salvar as substituições.
        if (
            $request->hasFile('image_account') &&
            $oldAccountImage
        ) {
            Storage::disk('public')->delete($oldAccountImage);
        }

        if (
            $request->hasFile('image_inventory') &&
            $oldInventoryImage
        ) {
            Storage::disk('public')->delete($oldInventoryImage);
        }

        return $product->refresh();
    }

    public function destroy(Request $request, Product $product)
    {
        $this->authorizeOwnerOrAdmin($request, $product);

        // Remove as imagens armazenadas.
        if ($product->image_account) {
            Storage::disk('public')->delete($product->image_account);
        }

        if ($product->image_inventory) {
            Storage::disk('public')->delete($product->image_inventory);
        }

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
