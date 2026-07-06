<?php

namespace Database\Seeders;

use App\Models\ExpenseCategory;
use Illuminate\Database\Seeder;

class ExpenseCategorySeeder extends Seeder
{
    public function run(): void
    {
        foreach (ExpenseCategory::defaultCategories() as $category) {
            ExpenseCategory::firstOrCreate(
                ['slug' => $category['slug']],
                $category
            );
        }
    }
}