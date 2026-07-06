# Task 1: Backend - Database Migrations

## Overview
Create database migrations for `expense_categories` and `sudden_expenses` tables, and add `plan_budget` column to `trips` table.

## Files to Create/Modify

### 1. Create: `backend/database/migrations/2026_07_06_000001_create_expense_categories_table.php`

```php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expense_categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('icon');
            $table->string('description')->nullable();
            $table->boolean('is_custom')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expense_categories');
    }
};
```

### 2. Create: `backend/database/migrations/2026_07_06_000002_create_sudden_expenses_table.php`

```php
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sudden_expenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trip_id')->constrained('trips')->onDelete('cascade');
            $table->foreignId('expense_category_id')->nullable()->constrained('expense_categories');
            $table->string('name');
            $table->decimal('amount', 12, 2);
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sudden_expenses');
    }
};
```

### 3. Modify: `backend/database/migrations/2026_07_04_000001_create_trips_table.php`

Add after `share_code` column:
```php
$table->decimal('plan_budget', 14, 2)->nullable()->after('share_code');
```

## Acceptance Criteria

- [ ] Migration for `expense_categories` table created
- [ ] Migration for `sudden_expenses` table created
- [ ] `trips` table has `plan_budget` column added
- [ ] `php artisan migrate` runs without errors

## Notes

- Run `php artisan migrate` after creating migrations to verify
- Use exact timestamp format: `2026_07_06_000001` and `2026_07_06_000002`
