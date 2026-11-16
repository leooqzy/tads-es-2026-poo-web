<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone', 20)
                ->nullable()
                ->after('role');

            $table->text('cpf')
                ->nullable()
                ->after('phone');

            $table->char('cpf_hash', 64)
                ->nullable()
                ->unique()
                ->after('cpf');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique(['cpf_hash']);
            
            $table->dropColumn([
                'phone',
                'cpf',
                'cpf_hash',
            ]);
        });
    }
};