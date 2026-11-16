<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProductUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id' => [
                'sometimes',
                'nullable',
                'integer',
                'exists:categories,id',
            ],
            'name' => [
                'sometimes',
                'required',
                'string',
                'max:255',
            ],
            'description' => [
                'sometimes',
                'nullable',
                'string',
            ],
            'image_account' => [
                'sometimes',
                'required',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],
            'image_inventory' => [
                'sometimes',
                'required',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],
            'price' => [
                'sometimes',
                'required',
                'numeric',
                'min:0.01',
            ],
            'stock' => [
                'sometimes',
                'required',
                'integer',
                'min:0',
            ],
            'position' => [
                'sometimes',
                'required',
                'integer',
                'min:0',
            ],
            'enabled' => [
                'sometimes',
                'required',
                'boolean',
            ],
        ];
    }
}
